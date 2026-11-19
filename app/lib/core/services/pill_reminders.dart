import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/core/l10n/l10n.dart';
import 'package:nousdeux/core/services/local_notifications.dart';
import 'package:nousdeux/domain/entities/pill_entities.dart';
import 'package:nousdeux/domain/pill/pill_schedule.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/pill_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

// The daily pill reminders (docs/PILL.md, Task 5): one-shot notifications
// for the next weeks, so a day off is skipped and a ticked day loses its
// second reminder. They are planned again whenever the app starts or comes
// back, the settings change, or a pill is ticked.

/// Notification ids 1000 to 1099 are the pill's: two per day ahead, a
/// heads-up on the morning a pack starts again, the last one asking to open
/// the app, then the one « Dans 30 min » adds.
const pillReminderFirstId = 1000;
const pillNewPackFirstId = 1060;
const pillKeepAliveId = 1098;
const pillSnoozeId = 1099;

/// The buttons: « Prise » (opens the app to save it) and « Dans 30 min ».
const pillTakenAction = 'pill_taken';
const pillSnoozeAction = 'pill_snooze';

/// Days planned ahead. Two a day, plus the last one, the period reminder and
/// a snooze, stays under iOS's 64 pending notifications. Past them, the
/// last one asks to open the app, which plans the next ones.
const pillPlanDays = 30;

/// One reminder to schedule.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
    required this.iosCategory,
    required this.actions,
  });

  final int id;
  final tz.TZDateTime at;
  final String title;
  final String body;

  /// What the tap and the buttons need: the day, and the texts and buttons
  /// to show again for « Dans 30 min ».
  final String payload;
  final String iosCategory;
  final List<LocalAction> actions;
}

String _date(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// [now]'s wall-clock time read in the phone's zone (`tz.local`).
tz.TZDateTime _local(DateTime now) => tz.TZDateTime(
  tz.local,
  now.year,
  now.month,
  now.day,
  now.hour,
  now.minute,
  now.second,
);

/// The iOS category for a text style and language: it holds the buttons'
/// labels, which iOS registers at start.
String pillCategory(ReminderText style, String lang) =>
    'pill_${style.wire}_${AppLanguages.resolve(lang)}';

List<LocalAction> pillActions(ReminderText style, String lang) {
  final l = l10nFor(lang);
  return [
    LocalAction(pillTakenAction, l.pillActionTaken(style.wire), opensApp: true),
    LocalAction(pillSnoozeAction, l.pillActionSnooze, opensApp: false),
  ];
}

/// Every pill category, in every language and style, for the start.
List<DarwinNotificationCategory> pillDarwinCategories() => [
  for (final lang in AppLanguages.supported)
    for (final style in ReminderText.values)
      DarwinNotificationCategory(
        pillCategory(style, lang),
        actions: [
          for (final a in pillActions(style, lang))
            DarwinNotificationAction.plain(
              a.id,
              a.label,
              options: {
                if (a.opensApp) DarwinNotificationActionOption.foreground,
              },
            ),
        ],
      ),
];

String _clock(TimeOfDayValue t, String lang) => DateFormat.jm(
  AppLanguages.dateLocale(lang),
).format(DateTime(2000, 1, 1, t.hour, t.minute));

/// A pill day's first reminder as it shows (the settings preview it): the
/// clear text names the pill and its number, or the new pack on day 1 of a
/// 21 + 7 or 28 pack; the discreet one only the time.
({String title, String body}) pillFirstReminder(
  PillSettings settings,
  DateTime day,
  String lang,
) {
  final l = l10nFor(lang);
  final style = settings.reminderText;
  final schedule = settings.schedule;
  final number = schedule.pillNumber(day) ?? 1;
  final newPack = number == 1 && schedule.type != PackType.continuous;
  return (
    title: l.pillReminderTitle(style.wire),
    body: style == ReminderText.clear
        ? newPack
              ? l.pillReminderBodyNewPack
              : l.pillReminderBodyClear(number)
        : l.pillReminderBodyDiscreet(_clock(settings.reminderTime, lang)),
  );
}

/// When a 21 + 7 pack starts again after its break, a heads-up at 9:00
/// (Evah, 2026-11-19), unless the reminder itself rings by 10:00.
const _newPackHeadsUp = (hour: 9, minute: 0);
const _newPackHeadsUpUnlessBy = (hour: 10, minute: 0);

/// The reminders for the next [days] days from [now]: at the reminder time
/// and 30 minutes later on each pill day not yet noted, none on days off,
/// none already past. Day 1 of a 21 + 7 or 28 pack says a new pack starts,
/// and after a break a heads-up comes that morning. The discreet text names
/// neither the pill nor its number.
List<PlannedReminder> planPillReminders({
  required PillSettings settings,
  required List<PillIntake> intakes,
  required DateTime now,
  required String lang,
  int days = pillPlanDays,
}) {
  if (!settings.reminderOn) return const [];
  final l = l10nFor(lang);
  final style = settings.reminderText;
  final t = settings.reminderTime;
  final clock = _clock(t, lang);
  final noted = {for (final i in intakes) i.day};
  final schedule = settings.schedule;
  final nowTz = _local(now);
  final category = pillCategory(style, lang);
  final actions = pillActions(style, lang);
  final title = l.pillReminderTitle(style.wire);
  final headsUpToo =
      schedule.type == PackType.p21x7 &&
      t.hour * 60 + t.minute >
          _newPackHeadsUpUnlessBy.hour * 60 + _newPackHeadsUpUnlessBy.minute;
  final out = <PlannedReminder>[];
  for (var i = 0; i < days; i++) {
    final day = DateTime(now.year, now.month, now.day + i);
    final number = schedule.pillNumber(day);
    if (number == null || noted.contains(day)) continue;
    final newPack = number == 1 && schedule.type != PackType.continuous;
    if (newPack && headsUpToo) {
      final at = tz.TZDateTime(
        tz.local,
        day.year,
        day.month,
        day.day,
        _newPackHeadsUp.hour,
        _newPackHeadsUp.minute,
      );
      if (at.isAfter(nowTz)) {
        final body = style == ReminderText.clear
            ? l.pillNewPackMorningClear
            : l.pillNewPackMorningDiscreet(clock);
        out.add(
          _planned(
            pillNewPackFirstId + i,
            at,
            title,
            body,
            day,
            category,
            const [],
          ),
        );
      }
    }
    final first = tz.TZDateTime(
      tz.local,
      day.year,
      day.month,
      day.day,
      t.hour,
      t.minute,
    );
    final texts = [
      (
        id: pillReminderFirstId + 2 * i,
        at: first,
        body: pillFirstReminder(settings, day, lang).body,
      ),
      (
        id: pillReminderFirstId + 2 * i + 1,
        at: first.add(const Duration(minutes: 30)),
        body: style == ReminderText.clear
            ? l.pillReminderLaterClear
            : l.pillReminderLaterDiscreet(clock),
      ),
    ];
    for (final r in texts) {
      if (!r.at.isAfter(nowTz)) continue;
      out.add(_planned(r.id, r.at, title, r.body, day, category, actions));
    }
  }
  // The day after the plan: open the app, or the reminders stop here.
  final end = DateTime(now.year, now.month, now.day + days);
  final last = tz.TZDateTime(
    tz.local,
    end.year,
    end.month,
    end.day,
    t.hour,
    t.minute,
  );
  out.add(
    _planned(
      pillKeepAliveId,
      last,
      title,
      l.pillReminderKeepAlive,
      end,
      category,
      const [],
    ),
  );
  return out;
}

PlannedReminder _planned(
  int id,
  tz.TZDateTime at,
  String title,
  String body,
  DateTime day,
  String category,
  List<LocalAction> actions,
) => PlannedReminder(
  id: id,
  at: at,
  title: title,
  body: body,
  payload: jsonEncode({
    'kind': 'pill',
    'day': _date(day),
    'title': title,
    'body': body,
    'category': category,
    'taken': actions.isEmpty ? '' : actions.first.label,
    'snooze': actions.isEmpty ? '' : actions.last.label,
  }),
  iosCategory: category,
  actions: actions,
);

Map<String, dynamic>? _pillPayload(String? payload) {
  if (payload == null) return null;
  try {
    final data = jsonDecode(payload);
    return data is Map<String, dynamic> && data['kind'] == 'pill' ? data : null;
  } catch (_) {
    return null;
  }
}

/// The day a pill reminder's payload is about, or null for any other.
DateTime? pillDayFromPayload(String? payload) {
  final day = DateTime.tryParse(_pillPayload(payload)?['day'] as String? ?? '');
  return day == null ? null : DateTime(day.year, day.month, day.day);
}

/// « Dans 30 min »: the same reminder again half an hour from [now].
Future<void> snoozePillReminder(
  LocalNotifications notifications,
  String? payload, {
  DateTime? now,
}) async {
  final p = _pillPayload(payload);
  if (p == null) return;
  await notifications.schedule(
    id: pillSnoozeId,
    at: _local(now ?? DateTime.now()).add(const Duration(minutes: 30)),
    channel: LocalChannel.pillReminder,
    title: p['title'] as String? ?? '',
    body: p['body'] as String? ?? '',
    payload: payload,
    iosCategory: p['category'] as String?,
    actions: [
      LocalAction(pillTakenAction, p['taken'] as String? ?? '', opensApp: true),
      LocalAction(
        pillSnoozeAction,
        p['snooze'] as String? ?? '',
        opensApp: false,
      ),
    ],
  );
}

/// « Dans 30 min » tapped while the app isn't running: a separate isolate,
/// so the time zones and the plugin start here. Nothing goes to the server.
@pragma('vm:entry-point')
Future<void> pillNotificationBackgroundHandler(NotificationResponse r) async {
  if (r.actionId != pillSnoozeAction) return;
  await snoozePillReminder(
    await PluginLocalNotifications.forBackground(),
    r.payload,
  );
}

/// The last zone the sync tried to save while the app runs.
class _ZoneTried {
  String? zone;
}

final _pillZoneTriedProvider = Provider<_ZoneTried>((ref) => _ZoneTried());

/// Keeps the phone's pill reminders matching my settings and days: watched
/// by the main shell, so it runs at start, when the settings change and
/// after a tick (which reloads the days).
final pillReminderSyncProvider = FutureProvider<void>((ref) async {
  // A newer run replaces this one: it stops scheduling as soon as it is
  // stale, so reminders turned off don't come back from an older run.
  var live = true;
  ref.onDispose(() => live = false);
  final notifications = ref.watch(localNotificationsProvider);
  final zone = ref.watch(localZoneProvider);
  final settings = await ref.watch(pillSettingsProvider.future);
  final days = await ref.watch(pillWeekProvider.future);
  final lang = ref.watch(
    myProfileProvider.select((p) => p.valueOrNull?.language ?? 'fr'),
  );
  try {
    // The partner's "today" follows the phone: save a new zone, alone (these
    // settings may be older than the row), before touching what is
    // scheduled. The next run reads the row back and plans; if that read
    // fails, the reminders already scheduled stay. The same zone isn't
    // tried twice in a row, so a row that doesn't take it can't loop.
    final tried = ref.read(_pillZoneTriedProvider);
    if (settings != null &&
        live &&
        settings.timeZone != zone &&
        tried.zone != zone) {
      tried.zone = zone;
      final failed = await ref.read(pillRepositoryProvider).saveTimeZone(zone);
      if (failed == null) {
        ref.invalidate(pillSettingsProvider);
        return;
      }
      tried.zone = null;
    }
    await notifications.cancelRange(pillReminderFirstId, pillSnoozeId);
    if (settings == null || !live) return;
    for (final r in planPillReminders(
      settings: settings,
      intakes: days,
      now: ref.read(clockProvider)(),
      lang: lang,
    )) {
      if (!live) return;
      await notifications.schedule(
        id: r.id,
        at: r.at,
        channel: LocalChannel.pillReminder,
        title: r.title,
        body: r.body,
        payload: r.payload,
        iosCategory: r.iosCategory,
        actions: r.actions,
      );
    }
  } catch (_) {
    // Best effort: the next start plans them again.
  }
});

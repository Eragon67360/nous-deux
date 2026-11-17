import 'package:nousdeux/domain/calendar/phone_event.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';

/// What one sync writes to bring the couple's calendar in line with the
/// followed phone calendars.
class SyncPlan {
  const SyncPlan({
    required this.toInsert,
    required this.toUpdate,
    required this.toDelete,
  });

  final List<PhoneEvent> toInsert;

  /// The synced copy's id and what it becomes.
  final List<({String id, PhoneEvent event})> toUpdate;

  /// Ids of synced copies whose phone event is gone.
  final List<String> toDelete;

  bool get isEmpty => toInsert.isEmpty && toUpdate.isEmpty && toDelete.isEmpty;
}

/// Compares the followed calendars' occurrences between [from] and [to]
/// ([phone]) with the person's own synced copies ([synced]). A copy whose
/// key is gone is deleted only when it starts in [from]..[to]: older ones
/// are history. Events written in Nous Deux (no source key) are ignored.
SyncPlan planCalendarSync({
  required List<PhoneEvent> phone,
  required List<CalendarEventEntity> synced,
  required DateTime from,
  required DateTime to,
}) {
  final byKey = <String, CalendarEventEntity>{
    for (final s in synced) ?s.sourceKey: s,
  };
  final seen = <String>{};
  final toInsert = <PhoneEvent>[];
  final toUpdate = <({String id, PhoneEvent event})>[];
  for (final p in phone) {
    if (!seen.add(p.key)) continue;
    final copy = byKey[p.key];
    if (copy == null) {
      toInsert.add(p);
    } else if (_differs(copy, p)) {
      toUpdate.add((id: copy.id, event: p));
    }
  }
  final toDelete = [
    for (final s in byKey.values)
      if (!seen.contains(s.sourceKey) &&
          !s.startTime.isBefore(from) &&
          !s.startTime.isAfter(to))
        s.id,
  ];
  return SyncPlan(toInsert: toInsert, toUpdate: toUpdate, toDelete: toDelete);
}

bool _differs(CalendarEventEntity copy, PhoneEvent p) =>
    copy.title != p.title ||
    !copy.startTime.isAtSameMomentAs(p.start) ||
    !_sameInstant(copy.endTime, p.end);

bool _sameInstant(DateTime? a, DateTime? b) =>
    a == null ? b == null : b != null && a.isAtSameMomentAs(b);

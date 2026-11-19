import 'package:equatable/equatable.dart';

import 'package:nousdeux/domain/pill/pill_schedule.dart';

/// What a pill reminder says on the lock screen: [clear] names the pill,
/// [discreet] doesn't (« Petit rappel »).
enum ReminderText {
  clear,
  discreet;

  static ReminderText fromWire(String? wire) =>
      wire == 'clear' ? clear : discreet;

  String get wire => name;
}

/// An hour and minute of the day, for the reminder.
typedef TimeOfDayValue = ({int hour, int minute});

/// Someone's pill tracking settings (`pill_tracking`, docs/PILL.md).
class PillSettings extends Equatable {
  const PillSettings({
    required this.packType,
    required this.packStartedOn,
    this.reminderOn = true,
    this.reminderTime = (hour: 21, minute: 0),
    this.reminderText = ReminderText.discreet,
    this.shareWithPartner = true,
  });

  final PackType packType;

  /// Day 1 of a pack.
  final DateTime packStartedOn;
  final bool reminderOn;
  final TimeOfDayValue reminderTime;
  final ReminderText reminderText;
  final bool shareWithPartner;

  PillSchedule get schedule => PillSchedule(packType, packStartedOn);

  PillSettings copyWith({
    PackType? packType,
    DateTime? packStartedOn,
    bool? reminderOn,
    TimeOfDayValue? reminderTime,
    ReminderText? reminderText,
    bool? shareWithPartner,
  }) => PillSettings(
    packType: packType ?? this.packType,
    packStartedOn: packStartedOn ?? this.packStartedOn,
    reminderOn: reminderOn ?? this.reminderOn,
    reminderTime: reminderTime ?? this.reminderTime,
    reminderText: reminderText ?? this.reminderText,
    shareWithPartner: shareWithPartner ?? this.shareWithPartner,
  );

  @override
  List<Object?> get props => [
    packType,
    packStartedOn,
    reminderOn,
    reminderTime,
    reminderText,
    shareWithPartner,
  ];
}

/// One day of pill tracking: taken (with its time) or noted as missed.
class PillIntake extends Equatable {
  const PillIntake._(this.day, this.takenAt);

  PillIntake.taken(DateTime day, DateTime at)
    : this._(DateTime(day.year, day.month, day.day), at);

  PillIntake.missed(DateTime day)
    : this._(DateTime(day.year, day.month, day.day), null);

  /// The calendar day.
  final DateTime day;

  /// When the pill was taken; null when noted as missed.
  final DateTime? takenAt;

  bool get taken => takenAt != null;

  @override
  List<Object?> get props => [day, takenAt];
}

/// What the partner may know about today's pill (`partner_pill_today()`).
class PartnerPillToday extends Equatable {
  const PartnerPillToday({
    required this.tracking,
    required this.expected,
    required this.takenAt,
  });

  static const nothing = PartnerPillToday(
    tracking: false,
    expected: false,
    takenAt: null,
  );

  /// The partner tracks a pill and shares it.
  final bool tracking;

  /// A pill is expected today (not a day off).
  final bool expected;

  /// When today's pill was ticked, or null.
  final DateTime? takenAt;

  @override
  List<Object?> get props => [tracking, expected, takenAt];
}

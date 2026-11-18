import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.id,
    this.username,
    this.partnerId,
    this.language = 'fr',
    this.avatarUrl,
    this.onboardingCompletedAt,
    this.tracksCycle,
    this.shareCycle = true,
    this.shareCheckins = true,
    this.calendarSyncDevice,
    this.calendarSyncedAt,
    this.announcementsPush = true,
    this.announcementsSeenAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? username;
  final String? partnerId;
  final String language;
  final String? avatarUrl;
  final DateTime? onboardingCompletedAt;

  /// Whether this person tracks a cycle in the app; null until asked.
  final bool? tracksCycle;

  /// The partner may see this person's period dates (day, phase, expected
  /// date) and get the reminder.
  final bool shareCycle;

  /// The partner may see this person's daily check-ins.
  final bool shareCheckins;

  /// Install id of the phone that follows calendars for this person, null
  /// when they follow none (docs/CALENDAR_SYNC.md).
  final String? calendarSyncDevice;

  /// When that phone last synced the followed calendars.
  final DateTime? calendarSyncedAt;

  /// Whether a push comes with each new message from the team (Nouveautés).
  final bool announcementsPush;

  /// When this person last read Nouveautés: later messages are unread.
  final DateTime? announcementsSeenAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasPartner => partnerId != null && partnerId!.isNotEmpty;

  bool get hasCompletedOnboarding => onboardingCompletedAt != null;

  @override
  List<Object?> get props => [
    id,
    username,
    partnerId,
    language,
    avatarUrl,
    onboardingCompletedAt,
    tracksCycle,
    shareCycle,
    shareCheckins,
    calendarSyncDevice,
    calendarSyncedAt,
    announcementsPush,
    announcementsSeenAt,
    createdAt,
    updatedAt,
  ];
}

import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/domain/entities/couple_entity.dart';
import 'package:nousdeux/domain/entities/location_sharing_entity.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';
import 'package:nousdeux/domain/entities/user_entity.dart';

/// Ids shared by fixtures and fakes so tests read like the real couple.
const meId = 'user-me';
const partnerId = 'user-partner';
const coupleId = 'couple-1';

const me = UserEntity(id: meId, phone: '+33612345678');

ProfileEntity profile({
  String id = meId,
  String? username = 'Camille',
  String gender = 'woman',
  String? partner,
  String language = 'fr',
  String? avatarUrl,
  bool onboarded = true,
}) {
  return ProfileEntity(
    id: id,
    username: username,
    gender: gender,
    partnerId: partner,
    language: language,
    avatarUrl: avatarUrl,
    onboardingCompletedAt: onboarded ? DateTime.utc(2026, 1, 1) : null,
  );
}

ProfileEntity partnerProfile({
  String? username = 'Alex',
  String language = 'fr',
}) {
  return profile(
    id: partnerId,
    username: username,
    gender: 'man',
    partner: meId,
    language: language,
  );
}

CoupleEntity couple({
  String? user2Id = partnerId,
  String? pairingCode = 'ABC234',
  DateTime? togetherSince,
  DateTime? createdAt,
}) {
  return CoupleEntity(
    id: coupleId,
    user1Id: meId,
    user2Id: user2Id,
    pairingCode: pairingCode,
    togetherSince: togetherSince,
    createdAt: createdAt,
  );
}

CalendarEventEntity event({
  String id = 'event-1',
  String title = 'Dîner',
  String? description,
  required DateTime start,
  DateTime? end,
  String createdBy = meId,
  bool isCountdown = false,
}) {
  return CalendarEventEntity(
    id: id,
    coupleId: coupleId,
    title: title,
    description: description,
    startTime: start,
    endTime: end,
    createdBy: createdBy,
    isCountdown: isCountdown,
  );
}

PeriodLogEntity periodLog({
  String id = 'log-1',
  String userId = meId,
  required DateTime start,
  DateTime? end,
  String? mood,
  List<String> symptoms = const [],
  String? notes,
}) {
  return PeriodLogEntity(
    id: id,
    userId: userId,
    coupleId: coupleId,
    startDate: start,
    endDate: end,
    mood: mood,
    symptoms: symptoms,
    notes: notes,
  );
}

LocationSharingEntity location({
  String userId = meId,
  bool isSharing = true,
  double? lat,
  double? lng,
}) {
  return LocationSharingEntity(
    userId: userId,
    coupleId: coupleId,
    isSharing: isSharing,
    latitude: lat,
    longitude: lng,
  );
}

/// Today's date at UTC midnight, `daysAgo` days back. Period logs come back
/// from Supabase as UTC-midnight dates (see PeriodLogModel.fromJson).
DateTime utcDaysAgo(int daysAgo) {
  final now = DateTime.now();
  return DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: daysAgo));
}

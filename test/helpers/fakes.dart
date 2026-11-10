import 'dart:async';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/domain/entities/couple_entity.dart';
import 'package:nousdeux/domain/entities/location_sharing_entity.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';
import 'package:nousdeux/domain/entities/user_entity.dart';
import 'package:nousdeux/domain/repositories/auth_repository.dart';
import 'package:nousdeux/domain/repositories/calendar_repository.dart';
import 'package:nousdeux/domain/repositories/location_repository.dart';
import 'package:nousdeux/domain/repositories/pairing_repository.dart';
import 'package:nousdeux/domain/repositories/period_repository.dart';
import 'package:nousdeux/domain/repositories/profile_repository.dart';
import 'package:nousdeux/presentation/providers/location_provider.dart';

import 'fixtures.dart';

// Hand-written fakes for the repository interfaces. Each one keeps an
// in-memory state, records the calls the screens make, and returns
// `nextFailure` (once) when a test wants the next mutation to fail.

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({UserEntity? user}) : _user = user;

  UserEntity? _user;
  final _changes = StreamController<UserEntity?>.broadcast();

  /// Returned (once) by the next sign-in / verify call.
  Failure? nextFailure;

  /// When set, sign-in / verify calls wait on it (to observe loading states).
  Completer<void>? gate;

  final otpPhones = <String>[];
  final verifyCalls = <({String phone, String token})>[];
  int googleCalls = 0;
  int appleCalls = 0;
  int signOutCalls = 0;

  void emit(UserEntity? user) {
    _user = user;
    _changes.add(user);
  }

  Future<AuthResult> _result() async {
    if (gate != null) await gate!.future;
    final failure = nextFailure;
    nextFailure = null;
    return (user: failure == null ? _user : null, failure: failure);
  }

  @override
  Stream<UserEntity?> get authStateChanges async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  UserEntity? get currentUser => _user;

  @override
  Future<AuthResult> signInWithOtp({required String phone}) {
    otpPhones.add(phone);
    return _result();
  }

  @override
  Future<AuthResult> verifyOtp({required String phone, required String token}) {
    verifyCalls.add((phone: phone, token: token));
    return _result();
  }

  @override
  Future<AuthResult> signInWithGoogle() {
    googleCalls++;
    return _result();
  }

  @override
  Future<AuthResult> signInWithApple() {
    appleCalls++;
    return _result();
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.mine, Map<String, ProfileEntity>? others})
    : others = others ?? {};

  ProfileEntity? mine;
  final Map<String, ProfileEntity> others;
  Failure? nextFailure;

  /// Failure returned by [getOrCreateMyProfile] (e.g. profile deleted).
  Failure? loadFailure;

  int getOrCreateCalls = 0;
  final completeOnboardingCalls =
      <({String username, String gender, String language})>[];
  final updateCalls =
      <
        ({
          String? username,
          String? gender,
          String? language,
          String? avatarUrl,
        })
      >[];

  Failure? _takeFailure() {
    final f = nextFailure;
    nextFailure = null;
    return f;
  }

  ProfileEntity _copy(
    ProfileEntity p, {
    String? username,
    String? gender,
    String? language,
    String? avatarUrl,
    DateTime? onboardingCompletedAt,
  }) {
    return ProfileEntity(
      id: p.id,
      username: username ?? p.username,
      gender: gender ?? p.gender,
      partnerId: p.partnerId,
      language: language ?? p.language,
      avatarUrl: avatarUrl ?? p.avatarUrl,
      onboardingCompletedAt: onboardingCompletedAt ?? p.onboardingCompletedAt,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    );
  }

  @override
  Future<ProfileResult> getOrCreateMyProfile() async {
    getOrCreateCalls++;
    if (loadFailure != null) return (profile: null, failure: loadFailure);
    return (profile: mine, failure: null);
  }

  @override
  Future<ProfileResult> getProfile(String profileId) async {
    final p = profileId == mine?.id ? mine : others[profileId];
    if (p == null) return (profile: null, failure: const NotFoundFailure());
    return (profile: p, failure: null);
  }

  @override
  Future<ProfileResult> updateProfile({
    String? username,
    String? gender,
    String? language,
    String? avatarUrl,
  }) async {
    updateCalls.add((
      username: username,
      gender: gender,
      language: language,
      avatarUrl: avatarUrl,
    ));
    final failure = _takeFailure();
    if (failure != null) return (profile: null, failure: failure);
    mine = _copy(
      mine!,
      username: username,
      gender: gender,
      language: language,
      avatarUrl: avatarUrl,
    );
    return (profile: mine, failure: null);
  }

  @override
  Future<ProfileResult> completeOnboarding({
    required String username,
    required String gender,
    required String language,
  }) async {
    completeOnboardingCalls.add((
      username: username,
      gender: gender,
      language: language,
    ));
    final failure = _takeFailure();
    if (failure != null) return (profile: null, failure: failure);
    mine = _copy(
      mine ?? profile(onboarded: false),
      username: username,
      gender: gender,
      language: language,
      onboardingCompletedAt: DateTime.utc(2026, 1, 2),
    );
    return (profile: mine, failure: null);
  }

  @override
  Future<ProfileResult> updateFcmToken(String? token) async {
    return (profile: mine, failure: null);
  }
}

class FakePairingRepository implements PairingRepository {
  FakePairingRepository({this.couple});

  CoupleEntity? couple;
  Failure? nextFailure;

  /// Code handed out by [createCoupleAndGetCode].
  String generatedCode = 'XK7P2M';

  int createCalls = 0;
  final joinCodes = <String>[];
  int leaveCalls = 0;

  Failure? _takeFailure() {
    final f = nextFailure;
    nextFailure = null;
    return f;
  }

  @override
  Future<PairingResult> getMyCouple() async => (couple: couple, failure: null);

  @override
  Future<PairingResult> createCoupleAndGetCode() async {
    createCalls++;
    final failure = _takeFailure();
    if (failure != null) return (couple: null, failure: failure);
    couple = CoupleEntity(
      id: coupleId,
      user1Id: meId,
      pairingCode: generatedCode,
    );
    return (couple: couple, failure: null);
  }

  @override
  Future<PairingResult> joinByCode(String code) async {
    joinCodes.add(code);
    final failure = _takeFailure();
    if (failure != null) return (couple: null, failure: failure);
    couple = CoupleEntity(
      id: coupleId,
      user1Id: partnerId,
      user2Id: meId,
      pairingCode: code,
    );
    return (couple: couple, failure: null);
  }

  @override
  Future<PairingResult> leaveCouple() async {
    leaveCalls++;
    final failure = _takeFailure();
    if (failure != null) return (couple: null, failure: failure);
    couple = null;
    return (couple: null, failure: null);
  }
}

class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository([List<CalendarEventEntity>? events])
    : events = [...?events];

  final List<CalendarEventEntity> events;
  Failure? nextFailure;

  final createCalls =
      <
        ({
          String title,
          String? description,
          DateTime startTime,
          DateTime? endTime,
        })
      >[];
  final updateCalls =
      <
        ({
          String id,
          String? title,
          String? description,
          DateTime? startTime,
          DateTime? endTime,
        })
      >[];
  final deletedIds = <String>[];

  Failure? _takeFailure() {
    final f = nextFailure;
    nextFailure = null;
    return f;
  }

  @override
  Stream<List<CalendarEventEntity>> watchEvents() =>
      Stream.value(List.unmodifiable(events));

  @override
  Future<CalendarEventsResult> getEvents({
    required DateTime start,
    required DateTime end,
  }) async {
    return (
      events: List<CalendarEventEntity>.unmodifiable(events),
      failure: null,
    );
  }

  @override
  Future<CalendarEventResult> createEvent({
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
  }) async {
    createCalls.add((
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
    ));
    final failure = _takeFailure();
    if (failure != null) return (event: null, failure: failure);
    final created = event(
      id: 'event-${events.length + 1}',
      title: title,
      description: description,
      start: startTime,
      end: endTime,
    );
    events.add(created);
    return (event: created, failure: null);
  }

  @override
  Future<CalendarEventResult> updateEvent({
    required String id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    updateCalls.add((
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
    ));
    final failure = _takeFailure();
    if (failure != null) return (event: null, failure: failure);
    return (event: events.firstWhere((e) => e.id == id), failure: null);
  }

  @override
  Future<Failure?> deleteEvent(String id) async {
    deletedIds.add(id);
    final failure = _takeFailure();
    if (failure == null) events.removeWhere((e) => e.id == id);
    return failure;
  }
}

class FakePeriodRepository implements PeriodRepository {
  FakePeriodRepository([List<PeriodLogEntity>? logs]) : logs = [...?logs];

  final List<PeriodLogEntity> logs;
  Failure? nextFailure;

  final createCalls =
      <
        ({
          DateTime startDate,
          DateTime? endDate,
          String? mood,
          List<String>? symptoms,
          String? notes,
        })
      >[];
  final updateCalls =
      <
        ({
          String id,
          DateTime? startDate,
          DateTime? endDate,
          String? mood,
          List<String>? symptoms,
          String? notes,
        })
      >[];
  final deletedIds = <String>[];

  Failure? _takeFailure() {
    final f = nextFailure;
    nextFailure = null;
    return f;
  }

  @override
  Stream<List<PeriodLogEntity>> watchLogs() =>
      Stream.value(List.unmodifiable(logs));

  @override
  Future<PeriodLogsResult> getLogs({DateTime? start, DateTime? end}) async {
    return (logs: List<PeriodLogEntity>.unmodifiable(logs), failure: null);
  }

  @override
  Future<PeriodLogResult> createLog({
    required DateTime startDate,
    DateTime? endDate,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) async {
    createCalls.add((
      startDate: startDate,
      endDate: endDate,
      mood: mood,
      symptoms: symptoms,
      notes: notes,
    ));
    final failure = _takeFailure();
    if (failure != null) return (log: null, failure: failure);
    final created = periodLog(
      id: 'log-${logs.length + 1}',
      start: startDate,
      end: endDate,
      mood: mood,
      symptoms: symptoms ?? const [],
      notes: notes,
    );
    logs.add(created);
    return (log: created, failure: null);
  }

  @override
  Future<PeriodLogResult> updateLog({
    required String id,
    DateTime? startDate,
    DateTime? endDate,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) async {
    updateCalls.add((
      id: id,
      startDate: startDate,
      endDate: endDate,
      mood: mood,
      symptoms: symptoms,
      notes: notes,
    ));
    final failure = _takeFailure();
    if (failure != null) return (log: null, failure: failure);
    return (log: logs.firstWhere((l) => l.id == id), failure: null);
  }

  @override
  Future<Failure?> deleteLog(String id) async {
    deletedIds.add(id);
    final failure = _takeFailure();
    if (failure == null) logs.removeWhere((l) => l.id == id);
    return failure;
  }
}

class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository({this.mine, this.partner});

  LocationSharingEntity? mine;
  LocationSharingEntity? partner;
  Failure? nextFailure;

  final setCalls =
      <({bool isSharing, String coupleId, double? lat, double? lng})>[];

  @override
  Future<LocationSharingResult> getMyLocationSharing() async =>
      (entity: mine, failure: null);

  @override
  Future<LocationSharingResult> getPartnerLocationSharing(
    String partnerUserId,
  ) async => (entity: partner, failure: null);

  @override
  Future<LocationSharingResult> setMyLocationSharing({
    required bool isSharing,
    required String coupleId,
    double? lat,
    double? lng,
  }) async {
    setCalls.add((
      isSharing: isSharing,
      coupleId: coupleId,
      lat: lat,
      lng: lng,
    ));
    final failure = nextFailure;
    nextFailure = null;
    if (failure != null) return (entity: null, failure: failure);
    mine = LocationSharingEntity(
      userId: meId,
      coupleId: coupleId,
      isSharing: isSharing,
      latitude: lat ?? mine?.latitude,
      longitude: lng ?? mine?.longitude,
    );
    return (entity: mine, failure: null);
  }
}

/// [LocationUpdateNotifier] that never touches Geolocator or timers.
class FakeLocationUpdateNotifier extends LocationUpdateNotifier {
  int startCalls = 0;
  int stopCalls = 0;
  int pushCalls = 0;

  @override
  void start() => startCalls++;

  @override
  void stop() => stopCalls++;

  @override
  Future<void> pushCurrentPosition() async => pushCalls++;
}

import 'dart:async';

import 'package:nousdeux/domain/repositories/lists_repository.dart';
import 'package:nousdeux/domain/entities/shared_list_entity.dart';
import 'package:nousdeux/domain/repositories/ping_repository.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/domain/entities/couple_entity.dart';
import 'package:nousdeux/domain/entities/cycle_checkin_entity.dart';
import 'package:nousdeux/domain/entities/location_sharing_entity.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';
import 'package:nousdeux/domain/entities/user_entity.dart';
import 'package:nousdeux/domain/repositories/auth_repository.dart';
import 'package:nousdeux/domain/repositories/calendar_repository.dart';
import 'package:nousdeux/domain/repositories/cycle_repository.dart';
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
    bool? tracksCycle,
    bool? shareCycle,
    bool? shareCheckins,
  }) {
    return ProfileEntity(
      id: p.id,
      username: username ?? p.username,
      gender: gender ?? p.gender,
      partnerId: p.partnerId,
      language: language ?? p.language,
      avatarUrl: avatarUrl ?? p.avatarUrl,
      onboardingCompletedAt: onboardingCompletedAt ?? p.onboardingCompletedAt,
      tracksCycle: tracksCycle ?? p.tracksCycle,
      shareCycle: shareCycle ?? p.shareCycle,
      shareCheckins: shareCheckins ?? p.shareCheckins,
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

  final cycleSettingsCalls =
      <({bool? tracksCycle, bool? shareCycle, bool? shareCheckins})>[];

  @override
  Future<ProfileResult> updateCycleSettings({
    bool? tracksCycle,
    bool? shareCycle,
    bool? shareCheckins,
  }) async {
    cycleSettingsCalls.add((
      tracksCycle: tracksCycle,
      shareCycle: shareCycle,
      shareCheckins: shareCheckins,
    ));
    final failure = _takeFailure();
    if (failure != null) return (profile: null, failure: failure);
    mine = _copy(
      mine!,
      tracksCycle: tracksCycle,
      shareCycle: shareCycle,
      shareCheckins: shareCheckins,
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
  final togetherSinceUpdates = <DateTime>[];

  Failure? _takeFailure() {
    final f = nextFailure;
    nextFailure = null;
    return f;
  }

  @override
  Future<PairingResult> getMyCouple() async => (couple: couple, failure: null);

  @override
  Future<Failure?> updateTogetherSince(DateTime day) async {
    togetherSinceUpdates.add(day);
    final failure = _takeFailure();
    if (failure != null) return failure;
    final c = couple;
    if (c != null) {
      couple = CoupleEntity(
        id: c.id,
        user1Id: c.user1Id,
        user2Id: c.user2Id,
        pairingCode: c.pairingCode,
        togetherSince: day,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
      );
    }
    return null;
  }

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
    bool isCountdown = false,
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
    required String title,
    required String? description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isCountdown,
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
  final _changes = StreamController<List<PeriodLogEntity>>.broadcast();
  Failure? nextFailure;

  /// How many times the logs were (re)loaded.
  int watchCalls = 0;
  final createCalls = <({DateTime startDate, DateTime? endDate})>[];
  final updateCalls = <({String id, DateTime startDate, DateTime? endDate})>[];
  final deletedIds = <String>[];

  Failure? _takeFailure() {
    final f = nextFailure;
    nextFailure = null;
    return f;
  }

  void _changed() => _changes.add(List.unmodifiable(logs));

  @override
  Stream<List<PeriodLogEntity>> watchLogs() async* {
    watchCalls++;
    yield List.unmodifiable(logs);
    yield* _changes.stream;
  }

  @override
  Future<PeriodLogsResult> getLogs({DateTime? start, DateTime? end}) async {
    return (logs: List<PeriodLogEntity>.unmodifiable(logs), failure: null);
  }

  @override
  Future<PeriodLogResult> createLog({
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    createCalls.add((startDate: startDate, endDate: endDate));
    final failure = _takeFailure();
    if (failure != null) return (log: null, failure: failure);
    final created = periodLog(
      id: 'log-${logs.length + 1}',
      start: startDate,
      end: endDate,
    );
    logs.add(created);
    _changed();
    return (log: created, failure: null);
  }

  @override
  Future<PeriodLogResult> updateLog({
    required String id,
    required DateTime startDate,
    required DateTime? endDate,
  }) async {
    updateCalls.add((id: id, startDate: startDate, endDate: endDate));
    final failure = _takeFailure();
    if (failure != null) return (log: null, failure: failure);
    final i = logs.indexWhere((l) => l.id == id);
    final updated = periodLog(
      id: id,
      userId: logs[i].userId,
      start: startDate,
      end: endDate,
    );
    logs[i] = updated;
    _changed();
    return (log: updated, failure: null);
  }

  @override
  Future<Failure?> deleteLog(String id) async {
    deletedIds.add(id);
    final failure = _takeFailure();
    if (failure == null) {
      logs.removeWhere((l) => l.id == id);
      _changed();
    }
    return failure;
  }
}

class FakeCycleRepository implements CycleRepository {
  FakeCycleRepository({
    List<CycleCheckinEntity>? checkins,
    Map<DateTime, String>? notes,
  }) : checkins = [...?checkins],
       notes = {...?notes};

  final List<CycleCheckinEntity> checkins;
  final Map<DateTime, String> notes;
  final _changes = StreamController<List<CycleCheckinEntity>>.broadcast();
  Failure? nextFailure;

  final checkinCalls =
      <({DateTime day, List<String> symptoms, String? mood})>[];
  final noteCalls = <({DateTime day, String note})>[];

  Failure? _takeFailure() {
    final f = nextFailure;
    nextFailure = null;
    return f;
  }

  @override
  Stream<List<CycleCheckinEntity>> watchCheckins() async* {
    yield List.unmodifiable(checkins);
    yield* _changes.stream;
  }

  @override
  Future<Failure?> saveCheckin({
    required DateTime day,
    required List<String> symptoms,
    String? mood,
  }) async {
    checkinCalls.add((day: day, symptoms: symptoms, mood: mood));
    final failure = _takeFailure();
    if (failure != null) return failure;
    checkins.removeWhere((c) => c.userId == meId && c.day == day);
    final saved = checkin(day: day, symptoms: symptoms, mood: mood);
    if (!saved.isEmpty) checkins.add(saved);
    _changes.add(List.unmodifiable(checkins));
    return null;
  }

  @override
  Future<String?> noteFor(DateTime day) async => notes[day];

  @override
  Future<Failure?> saveNote(DateTime day, String note) async {
    noteCalls.add((day: day, note: note));
    final failure = _takeFailure();
    if (failure != null) return failure;
    if (note.trim().isEmpty) {
      notes.remove(day);
    } else {
      notes[day] = note.trim();
    }
    return null;
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

class FakePingRepository implements PingRepository {
  FakePingRepository([List<PingEntity>? initial])
    : _pings = [...?initial];

  final List<PingEntity> _pings;
  final _controller = StreamController<List<PingEntity>>.broadcast();
  final sent = <PingKind>[];
  Failure? nextFailure;

  /// Replace both people's latest notes and push them to listeners.
  void emit(List<PingEntity> pings) {
    _pings
      ..clear()
      ..addAll(pings);
    _controller.add(List.unmodifiable(_pings));
  }

  @override
  Stream<List<PingEntity>> watchPings() async* {
    yield List.unmodifiable(_pings);
    yield* _controller.stream;
  }

  @override
  Future<PingResult> send(PingKind kind) async {
    sent.add(kind);
    final failure = nextFailure;
    nextFailure = null;
    if (failure != null) return (ping: null, failure: failure);
    return (
      ping: PingEntity(
        coupleId: coupleId,
        senderId: meId,
        kind: kind,
        sentAt: DateTime(2026, 11, 10, 18),
      ),
      failure: null,
    );
  }
}

class FakeListsRepository implements ListsRepository {
  FakeListsRepository({List<SharedListEntity>? lists, List<ListItemEntity>? items})
    : lists = [...?lists],
      items = [...?items];

  final List<SharedListEntity> lists;
  final List<ListItemEntity> items;
  final _listsController = StreamController<List<SharedListEntity>>.broadcast();
  final _itemsController = StreamController<List<ListItemEntity>>.broadcast();
  Failure? nextFailure;
  int _ids = 0;

  final calls = <String>[];

  Failure? _take() {
    final f = nextFailure;
    nextFailure = null;
    return f;
  }

  void _publish() {
    _listsController.add(List.unmodifiable(lists));
    _itemsController.add(List.unmodifiable(items));
  }

  @override
  Stream<List<SharedListEntity>> watchLists() async* {
    yield List.unmodifiable(lists);
    yield* _listsController.stream;
  }

  @override
  Stream<List<ListItemEntity>> watchItems() async* {
    yield List.unmodifiable(items);
    yield* _itemsController.stream;
  }

  @override
  Future<ListResult> createList({required String name, required ListIcon icon}) async {
    calls.add('create:$name:${icon.name}');
    final f = _take();
    if (f != null) return (list: null, failure: f);
    final list = SharedListEntity(
      id: 'list-${++_ids}',
      coupleId: coupleId,
      name: name,
      icon: icon,
      createdBy: meId,
    );
    lists.add(list);
    _publish();
    return (list: list, failure: null);
  }

  @override
  Future<Failure?> renameList(String listId, String name) async {
    calls.add('rename:$listId:$name');
    final f = _take();
    if (f != null) return f; // a failed write changes nothing
    final i = lists.indexWhere((l) => l.id == listId);
    final l = lists[i];
    lists[i] = SharedListEntity(
      id: l.id,
      coupleId: l.coupleId,
      name: name,
      icon: l.icon,
      createdBy: l.createdBy,
    );
    _publish();
    return null;
  }

  @override
  Future<Failure?> deleteList(String listId) async {
    calls.add('deleteList:$listId');
    final f = _take();
    if (f != null) return f; // a failed write changes nothing
    lists.removeWhere((l) => l.id == listId);
    items.removeWhere((i) => i.listId == listId);
    _publish();
    return null;
  }

  @override
  Future<Failure?> addItem(String listId, String text) async {
    calls.add('add:$listId:$text');
    final f = _take();
    if (f != null) return f;
    items.add(
      ListItemEntity(
        id: 'item-${++_ids}',
        listId: listId,
        text: text,
        checked: false,
        addedBy: meId,
        createdAt: DateTime(2026, 11, 10, 18, _ids),
      ),
    );
    _publish();
    return null;
  }

  @override
  Future<Failure?> setChecked(String itemId, bool checked) async {
    calls.add('check:$itemId:$checked');
    final f = _take();
    if (f != null) return f; // a failed write changes nothing
    final i = items.indexWhere((x) => x.id == itemId);
    final x = items[i];
    items[i] = ListItemEntity(
      id: x.id,
      listId: x.listId,
      text: x.text,
      checked: checked,
      addedBy: x.addedBy,
      createdAt: x.createdAt,
    );
    _publish();
    return null;
  }

  @override
  Future<Failure?> deleteItem(String itemId) async {
    calls.add('deleteItem:$itemId');
    final f = _take();
    if (f != null) return f; // a failed write changes nothing
    items.removeWhere((x) => x.id == itemId);
    _publish();
    return null;
  }

  @override
  Future<Failure?> clearChecked(String listId) async {
    calls.add('clear:$listId');
    final f = _take();
    if (f != null) return f; // a failed write changes nothing
    items.removeWhere((x) => x.listId == listId && x.checked);
    _publish();
    return null;
  }
}

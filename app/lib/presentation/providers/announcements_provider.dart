import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/data/repositories/announcements_repository_impl.dart';
import 'package:nousdeux/domain/entities/announcement_entity.dart';
import 'package:nousdeux/domain/repositories/announcements_repository.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>(
  (ref) => AnnouncementsRepositoryImpl(),
);

/// The team's messages (Nouveautés), newest first; none when signed out.
/// Invalidate it to read them again (app resumed, a message's push tapped).
final announcementsProvider = FutureProvider<List<AnnouncementEntity>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const [];
  final list = await ref
      .watch(announcementsRepositoryProvider)
      .sentAnnouncements();
  return [...list]..sort((a, b) => b.sentAt.compareTo(a.sentAt));
});

/// How many messages came after this person last read Nouveautés: the gold
/// dot on the avatar and in Paramètres. 0 while they load, when they can't,
/// or without a last-read time.
final unreadAnnouncementsCountProvider = Provider<int>((ref) {
  final seenAt = ref.watch(myProfileProvider).valueOrNull?.announcementsSeenAt;
  final list = ref.watch(announcementsProvider).valueOrNull;
  if (seenAt == null || list == null) return 0;
  return list.where((a) => a.sentAt.isAfter(seenAt)).length;
});

/// Marks Nouveautés read up to the newest message loaded, then refreshes the
/// profile. Writes nothing when nothing is newer than the last read.
final markAnnouncementsReadProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final list = ref.read(announcementsProvider).valueOrNull;
    final profile = ref.read(myProfileProvider).valueOrNull;
    if (list == null || list.isEmpty || profile == null) return;
    final newest = list.first.sentAt;
    final seenAt = profile.announcementsSeenAt;
    if (seenAt != null && !newest.isAfter(seenAt)) return;
    final result = await ref
        .read(profileRepositoryProvider)
        .markAnnouncementsSeen(newest);
    if (result.failure == null) ref.invalidate(myProfileProvider);
  };
});

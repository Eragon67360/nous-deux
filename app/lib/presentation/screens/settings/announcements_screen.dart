import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/news_strings.dart';
import 'package:nousdeux/domain/entities/announcement_entity.dart';
import 'package:nousdeux/presentation/providers/announcements_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// Paramètres › Nouveautés: the team's messages, newest first
/// (docs/NOUVEAUTES.md). A gold dot marks what was unread when the screen
/// opened; opening it marks everything read.
class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  /// The last-read time before this visit; the dots keep to it while open.
  DateTime? _seenBefore;

  @override
  void initState() {
    super.initState();
    _seenBefore = ref.read(myProfileProvider).valueOrNull?.announcementsSeenAt;
    // After this frame: providers can't change while the tree builds.
    Future.microtask(_readAndMark);
  }

  Future<void> _readAndMark() async {
    final profile = await ref.read(myProfileProvider.future);
    if (!mounted) return;
    if (_seenBefore == null && profile?.announcementsSeenAt != null) {
      setState(() => _seenBefore = profile!.announcementsSeenAt);
    }
    final List<AnnouncementEntity> fresh;
    try {
      // A message may have come since the list was last read.
      fresh = await ref.refresh(announcementsProvider.future);
    } catch (_) {
      return; // The screen says the list couldn't load.
    }
    if (!mounted || fresh.isEmpty) return;
    await ref.read(markAnnouncementsReadProvider)();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final theme = Theme.of(context);
    final messages = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          Text(newsTitle(lang), style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          ...messages.when(
            data: (list) => list.isEmpty
                ? [_Note(newsEmpty(lang))]
                : [
                    for (final a in list)
                      _Message(
                        message: a,
                        lang: lang,
                        unread:
                            _seenBefore != null &&
                            a.sentAt.isAfter(_seenBefore!),
                      ),
                  ],
            loading: () => const [
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (_, _) => [_Note(newsLoadFailed(lang))],
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.message,
    required this.lang,
    required this.unread,
  });

  final AnnouncementEntity message;
  final String lang;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final texts = message.textFor(lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NotebookRule(space: 18),
        Row(
          children: [
            if (unread) ...[
              Container(
                key: ValueKey('unread-${message.id}'),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            NotebookLabel(newsDate(lang, message.sentAt)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          texts.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 21,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          texts.body,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
        ),
        const SizedBox(height: 8),
        Text(
          newsSignature(lang),
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

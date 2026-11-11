import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/guide_chapters.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/presentation/providers/cycle_provider.dart';
import 'package:nousdeux/presentation/providers/guide_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/screens/period/guide/guide_chapter_body.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

const _pagePadding = EdgeInsets.fromLTRB(24, 8, 24, 40);

/// Whose cycle the guide speaks about right now, if it is known: the phase,
/// the day, and how to say "you are here".
({CyclePhase phase, int day, String forNow, String here})? _now(
  WidgetRef ref,
  String lang,
) {
  final (:stats, :mine) = ref.watch(guideCycleProvider);
  final phase = stats.phase;
  final day = stats.dayOfCycle;
  if (phase == null || day == null) return null;
  if (mine) {
    return (
      phase: phase,
      day: day,
      forNow: guideForYouNow(lang, day),
      here: guideYouAreHere(lang),
    );
  }
  final name = cyclePartnerName(
    lang,
    ref.watch(partnerProfileProvider).valueOrNull?.username,
  );
  return (
    phase: phase,
    day: day,
    forNow: guideForPartnerNow(lang, name, day),
    here: guidePartnerIsHere(lang, name),
  );
}

String _lang(WidgetRef ref) =>
    ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';

/// R4: the guide's contents, with what matters right now on top.
class GuideScreen extends ConsumerStatefulWidget {
  const GuideScreen({super.key});

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = _lang(ref);
    final now = _now(ref, lang);
    final read = ref.watch(guideReadProvider).valueOrNull ?? const {};
    final query = _search.text;
    final chapters = guideChaptersMatching(query, lang);

    return Scaffold(
      appBar: AppBar(title: Text(guideLabel(lang))),
      body: ListView(
        padding: _pagePadding,
        children: [
          Text(
            guideTitle(lang),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w300,
            ),
          ),
          if (now != null) ...[
            const SizedBox(height: 22),
            NotebookLabel(now.forNow),
            const SizedBox(height: 4),
            NotebookLink(
              label: guideNowTitle(lang, now.phase),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GuidePhaseScreen(),
                ),
              ),
            ),
          ],
          const NotebookRule(),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: guideSearch(lang),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).deleteButtonTooltip,
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(_search.clear),
                    ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          if (chapters.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                guideNoMatch(lang, query.trim()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final chapter in chapters)
            _ChapterRow(
              number: chapter.index + 1,
              title: guideChapterTitle(chapter, lang),
              read: read.contains(chapter),
              readLabel: guideRead(lang),
              onTap: () => openGuideChapter(context, chapter),
            ),
          // Each chapter row already ends with a line.
          const SizedBox(height: 22),
          Text(
            guideFootnote(lang),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

void openGuideChapter(
  BuildContext context,
  GuideChapter chapter, {
  bool replace = false,
}) {
  final route = MaterialPageRoute<void>(
    builder: (_) => GuideChapterScreen(chapter: chapter),
  );
  final navigator = Navigator.of(context);
  replace ? navigator.pushReplacement(route) : navigator.push(route);
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.number,
    required this.title,
    required this.read,
    required this.readLabel,
    required this.onTap,
  });

  final int number;
  final String title;
  final bool read;
  final String readLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      label: read ? '$number. $title, $readLabel' : '$number. $title',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  '$number',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w200,
                    color: scheme.primary,
                  ),
                ),
              ),
              Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
              if (read)
                Icon(Icons.check, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One chapter, read top to bottom, with the way to the next.
class GuideChapterScreen extends ConsumerStatefulWidget {
  const GuideChapterScreen({super.key, required this.chapter});

  final GuideChapter chapter;

  @override
  ConsumerState<GuideChapterScreen> createState() => _GuideChapterScreenState();
}

class _GuideChapterScreenState extends ConsumerState<GuideChapterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(guideReadProvider.notifier).markRead(widget.chapter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = _lang(ref);
    final chapter = widget.chapter;
    final now = _now(ref, lang);
    final next = chapter.index + 1 < GuideChapter.values.length
        ? GuideChapter.values[chapter.index + 1]
        : null;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: _pagePadding,
        children: [
          NotebookLabel(guideChapter(lang, chapter.index + 1)),
          const SizedBox(height: 6),
          Semantics(
            header: true,
            child: Text(
              guideChapterTitle(chapter, lang),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GuideChapterBody(
            chapter: chapter,
            lang: lang,
            here: now?.phase,
            hereLabel: now?.here,
          ),
          const NotebookRule(),
          Row(
            children: [
              NotebookLink(
                label: guideContents(lang),
                quiet: true,
                back: true,
                onTap: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
              if (next != null)
                Flexible(
                  flex: 3,
                  child: NotebookLink(
                    label: guideNext(lang, guideChapterTitle(next, lang)),
                    onTap: () => openGuideChapter(context, next, replace: true),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "For you now": the current phase, what it tends to bring, what helps.
class GuidePhaseScreen extends ConsumerWidget {
  const GuidePhaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lang = _lang(ref);
    final now = _now(ref, lang);
    final mine = ref.watch(guideCycleProvider).mine;

    return Scaffold(
      appBar: AppBar(),
      body: now == null
          ? const SizedBox.shrink()
          : ListView(
              padding: _pagePadding,
              children: [
                NotebookLabel(now.forNow),
                const SizedBox(height: 6),
                Semantics(
                  header: true,
                  child: Text(
                    guideNowTitle(lang, now.phase),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  cyclePhasesData[now.phase.index].description(lang),
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const NotebookRule(),
                NotebookLabel(guideBody(lang)),
                const SizedBox(height: 6),
                Text(
                  cyclePhasesData[now.phase.index].physical(lang).join(', '),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                NotebookLabel(guideMood(lang)),
                const SizedBox(height: 6),
                Text(
                  cyclePhasesData[now.phase.index].emotional(lang).join(', '),
                  style: theme.textTheme.bodyLarge,
                ),
                const NotebookRule(),
                NotebookLabel(guideWhatHelps(lang)),
                const SizedBox(height: 6),
                if (mine)
                  Text(
                    cycleSelfTip(lang, now.phase),
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  )
                else
                  for (final tip in cyclePartnerTips(lang, now.phase))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '· $tip',
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                      ),
                    ),
                const NotebookRule(),
                NotebookLink(
                  label: cycleReadChapter(
                    lang,
                    guideChapterTitle(GuideChapter.cycle, lang),
                  ),
                  onTap: () => openGuideChapter(
                    context,
                    GuideChapter.cycle,
                    replace: true,
                  ),
                ),
              ],
            ),
    );
  }
}

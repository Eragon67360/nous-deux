import 'package:flutter/material.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/guide_chapters.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_ui_strings.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';
import 'package:nousdeux/presentation/widgets/period_external_source_card.dart';

/// The text of one guide chapter, as notebook paragraphs.
class GuideChapterBody extends StatelessWidget {
  const GuideChapterBody({
    super.key,
    required this.chapter,
    required this.lang,
    this.here,
    this.hereLabel,
  });

  final GuideChapter chapter;
  final String lang;

  /// The phase to mark on the cycle chapter ("you are here"), if known.
  final CyclePhase? here;
  final String? hereLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: switch (chapter) {
        GuideChapter.cycle => _cycle(context),
        GuideChapter.bodyMind => _bodyMind(),
        GuideChapter.support => _support(),
        GuideChapter.talking => _talking(context),
        GuideChapter.myths => _myths(),
        GuideChapter.faq => _faq(),
        GuideChapter.sources => _sources(),
      },
    );
  }

  List<Widget> _cycle(BuildContext context) => [
    _Paragraph(sectionCycleIntro(lang)),
    const SizedBox(height: 18),
    _PhaseStrip(lang: lang, here: here, hereLabel: hereLabel),
    for (final (i, p) in cyclePhasesData.indexed) ...[
      const NotebookRule(space: 18),
      _Heading(
        '${p.name(lang)} · ${guideDaysShort(lang, p.dayRange)}',
        marked: CyclePhase.values[i] == here,
      ),
      _Paragraph(p.description(lang)),
      _Aside(p.hormoneHint(lang)),
      _Line(lang, guideBody(lang), p.physical(lang).join(', ')),
      _Line(lang, guideMood(lang), p.emotional(lang).join(', ')),
    ],
    const NotebookRule(space: 18),
    NotebookLabel(sectionQuickRefTitle(lang)),
    const SizedBox(height: 10),
    for (final card in quickRefCards) ...[
      _Heading(card.title(lang)),
      for (final b in card.bullets(lang)) _Paragraph('· $b', tight: true),
      const SizedBox(height: 8),
    ],
    _Sources(lang, sourcesForTopic(VerifiedSourceTopic.cycleBasics, lang)),
  ];

  List<Widget> _bodyMind() => [
    _Aside(sectionPhysicalEmotionalSubtitle(lang)),
    const SizedBox(height: 8),
    _Paragraph(sectionPsychologicalIntro(lang)),
    _Paragraph(pmsDefinition(lang)),
    _Paragraph(pmddDefinition(lang)),
    const NotebookRule(space: 18),
    _Heading(sectionPsychologicalTitle(lang)),
    _Paragraph(whenToSeekHelp(lang)),
    _Sources(lang, sourcesWhenToSeekHelp(lang)),
  ];

  List<Widget> _support() => [
    _Aside(sectionPartnerSupportSubtitle(lang)),
    const SizedBox(height: 8),
    _Paragraph(sectionPartnerSupportIntro(lang)),
    _Paragraph(partnerDoSay(lang)),
    _Paragraph(partnerDontSay(lang)),
    const NotebookRule(space: 18),
    _Heading(comfortKitTitle(lang)),
    _Paragraph(comfortKitBody(lang)),
    _Sources(lang, sourcesPartnerSupport(lang)),
  ];

  List<Widget> _talking(BuildContext context) => [
    _Aside(sectionCommunicationSubtitle(lang)),
    for (final t in communicationTemplates) ...[
      const NotebookRule(space: 14),
      _Paragraph('✗  ${t.avoid(lang)}', muted: true, tight: true),
      const SizedBox(height: 4),
      _Paragraph('✓  ${t.tryInstead(lang)}', tight: true),
    ],
    const NotebookRule(space: 18),
    _Heading(expressingNeedsTitle(lang)),
    _Paragraph(expressingNeedsBody(lang)),
    _Heading(boundariesTitle(lang)),
    _Paragraph(boundariesBody(lang)),
    _Heading(planningTogetherTitle(lang)),
    _Paragraph(planningTogetherBody(lang)),
  ];

  List<Widget> _myths() => [
    _Aside(sectionMythBustersSubtitle(lang)),
    for (final m in mythBustersList) ...[
      const NotebookRule(space: 14),
      _Heading(m.myth(lang)),
      _Paragraph(m.fact(lang)),
    ],
  ];

  List<Widget> _faq() => [
    for (final (i, f) in faqList.indexed) ...[
      if (i > 0) const NotebookRule(space: 14),
      _Heading(f.question(lang)),
      _Paragraph(f.answer(lang)),
    ],
  ];

  List<Widget> _sources() => [
    _Paragraph(disclaimerBody(lang)),
    _Sources(lang, periodVerifiedSourcesForLang(lang), label: guideSources),
  ];
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text, {this.muted = false, this.tight = false});

  final String text;
  final bool muted;
  final bool tight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: tight ? 2 : 10),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.5,
          color: muted ? theme.colorScheme.onSurfaceVariant : null,
        ),
      ),
    );
  }
}

class _Aside extends StatelessWidget {
  const _Aside(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, {this.marked = false});

  final String text;

  /// Drawn in the partner/mine wine colour: the phase "you are in".
  final bool marked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: marked ? theme.colorScheme.primary : null,
          ),
        ),
      ),
    );
  }
}

/// "In the body: a, b, c."
class _Line extends StatelessWidget {
  const _Line(this.lang, this.label, this.text);

  final String lang;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              // French puts a space before the colon.
              text: lang == 'fr' ? '$label : ' : '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: text),
          ],
        ),
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }
}

/// The four phases as one bar, with a legend that marks the current one.
class _PhaseStrip extends StatelessWidget {
  const _PhaseStrip({required this.lang, this.here, this.hereLabel});

  final String lang;
  final CyclePhase? here;
  final String? hereLabel;

  static const _lengths = [5, 7, 3, 13];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mine = CoupleColors.of(context).mine;
    Color colorOf(CyclePhase phase) => phase == CyclePhase.menstrual
        ? mine
        : phase == here
        ? scheme.primary
        : scheme.surfaceContainerHigh;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Row(
            children: [
              for (final (i, phase) in CyclePhase.values.indexed)
                Expanded(
                  flex: _lengths[i],
                  child: Container(
                    height: phase == here ? 8 : 6,
                    margin: EdgeInsets.only(
                      right: i < CyclePhase.values.length - 1 ? 2 : 0,
                    ),
                    color: colorOf(phase),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final (i, phase) in CyclePhase.values.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorOf(phase),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    [
                      cyclePhaseLabel(lang, phase),
                      guideDaysShort(lang, cyclePhasesData[i].dayRange),
                      if (phase == here && hereLabel != null) hereLabel!,
                    ].join(' · '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: phase == here ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Sources extends StatelessWidget {
  const _Sources(this.lang, this.sources, {this.label = periodLearnMore});

  final String lang;
  final List<VerifiedSource> sources;
  final String Function(String lang) label;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NotebookRule(space: 18),
        NotebookLabel(label(lang)),
        const SizedBox(height: 4),
        for (final s in sources)
          PeriodExternalSourceCard(source: s, language: lang),
      ],
    );
  }
}

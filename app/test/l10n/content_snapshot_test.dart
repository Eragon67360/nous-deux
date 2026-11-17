import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/guide_chapters.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/core/constants/period_options.dart';
import 'package:nousdeux/core/constants/period_verified_sources.dart';
import 'package:nousdeux/core/l10n/app_languages.dart';

/// Every text of the cycle guide, its education content and its verified
/// sources, in each language, recorded in [_snapshotPath].
///
/// Moving that content around must leave the file identical byte for byte:
/// nothing a person reads has changed, apostrophes and non-breaking spaces
/// included. After an intended change of wording, rewrite the file and review
/// its diff (from `app/`):
///
///     UPDATE_CONTENT_SNAPSHOT=1 flutter test test/l10n/content_snapshot_test.dart
const _snapshotPath = 'test/l10n/content_snapshot.json';

/// A language the app doesn't speak, to record what such a phone reads.
const _unsupported = 'xx';

/// Searches whose matching chapters are recorded, in both languages.
const _queries = [
  '',
  'cycle',
  'ovulation',
  'œstrogène',
  'estrogen',
  'PMDD',
  'spm',
  'bouillotte',
  'heat pack',
  'partenaire',
  'partner',
  'règles',
  'period',
  'nhs',
  'flo',
  'lumni',
  'disclaimer',
  'avertissement',
  'zzqxw',
];

Map<String, Object?> _source(VerifiedSource s, String lang) => {
  'url': s.url,
  'platform': s.platform.name,
  'platformLabel': s.platformLabel(lang),
  'topic': s.topic.name,
  'locales': s.locales,
  'name': s.name(lang),
  'credential': s.credential(lang),
  'summary': s.summary(lang),
};

List<String> _urls(List<VerifiedSource> sources) => [
  for (final s in sources) s.url,
];

Map<String, Object?> _content(String lang) => {
  'guide': {
    'chapterTitles': {
      for (final c in GuideChapter.values) c.name: guideChapterTitle(c, lang),
    },
    'search': {
      for (final q in _queries)
        q: [for (final c in guideChaptersMatching(q, lang)) c.name],
    },
  },
  'education': {
    'periodScreenTitle': periodScreenTitle(lang),
    'sectionCycleTitle': sectionCycleTitle(lang),
    'sectionCycleSubtitle': sectionCycleSubtitle(lang),
    'sectionCycleIntro': sectionCycleIntro(lang),
    'phases': [
      for (final p in cyclePhasesData)
        {
          'dayRange': p.dayRange,
          'name': p.name(lang),
          'description': p.description(lang),
          'hormoneHint': p.hormoneHint(lang),
          'physical': p.physical(lang),
          'emotional': p.emotional(lang),
        },
    ],
    'sectionPhysicalEmotionalTitle': sectionPhysicalEmotionalTitle(lang),
    'sectionPhysicalEmotionalSubtitle': sectionPhysicalEmotionalSubtitle(lang),
    'sectionPsychologicalTitle': sectionPsychologicalTitle(lang),
    'sectionPsychologicalIntro': sectionPsychologicalIntro(lang),
    'pmsDefinition': pmsDefinition(lang),
    'pmddDefinition': pmddDefinition(lang),
    'whenToSeekHelp': whenToSeekHelp(lang),
    'sectionPartnerSupportSubtitle': sectionPartnerSupportSubtitle(lang),
    'sectionPartnerSupportIntro': sectionPartnerSupportIntro(lang),
    'partnerDoSay': partnerDoSay(lang),
    'partnerDontSay': partnerDontSay(lang),
    'comfortKitTitle': comfortKitTitle(lang),
    'comfortKitBody': comfortKitBody(lang),
    'sectionCommunicationSubtitle': sectionCommunicationSubtitle(lang),
    'communicationTemplates': [
      for (final t in communicationTemplates)
        {'avoid': t.avoid(lang), 'tryInstead': t.tryInstead(lang)},
    ],
    'expressingNeedsTitle': expressingNeedsTitle(lang),
    'expressingNeedsBody': expressingNeedsBody(lang),
    'boundariesTitle': boundariesTitle(lang),
    'boundariesBody': boundariesBody(lang),
    'planningTogetherTitle': planningTogetherTitle(lang),
    'planningTogetherBody': planningTogetherBody(lang),
    'sectionMythBustersSubtitle': sectionMythBustersSubtitle(lang),
    'mythBusters': [
      for (final m in mythBustersList)
        {'myth': m.myth(lang), 'fact': m.fact(lang)},
    ],
    'sectionQuickRefTitle': sectionQuickRefTitle(lang),
    'quickRefCards': [
      for (final c in quickRefCards)
        {'title': c.title(lang), 'bullets': c.bullets(lang)},
    ],
    'faq': [
      for (final f in faqList)
        {'question': f.question(lang), 'answer': f.answer(lang)},
    ],
    'disclaimerTitle': disclaimerTitle(lang),
    'disclaimerBody': disclaimerBody(lang),
    'periodLogNew': periodLogNew(lang),
    'periodLogEdit': periodLogEdit(lang),
    'periodDeleteConfirmTitle': periodDeleteConfirmTitle(lang),
    'periodCancel': periodCancel(lang),
    'periodDelete': periodDelete(lang),
    'periodSave': periodSave(lang),
    'periodStartDate': periodStartDate(lang),
    'periodEndDate': periodEndDate(lang),
    'periodReminderNotificationTitle': periodReminderNotificationTitle(lang),
    'periodReminderNotificationBody': periodReminderNotificationBody(lang),
    'moodLabels': {
      for (final v in [...periodMoods, 'not-a-mood'])
        v: periodMoodOptionLabel(v, lang),
    },
    'symptomLabels': {
      for (final v in [...periodSymptoms, 'not-a-symptom'])
        v: periodSymptomOptionLabel(v, lang),
    },
  },
  'sources': {
    'all': [for (final s in periodVerifiedSources) _source(s, lang)],
    'forLanguage': _urls(periodVerifiedSourcesForLang(lang)),
    'byTopic': {
      for (final t in VerifiedSourceTopic.values)
        t.name: _urls(sourcesForTopic(t, lang)),
    },
    'whenToSeekHelp': _urls(sourcesWhenToSeekHelp(lang)),
    'partnerSupport': _urls(sourcesPartnerSupport(lang)),
  },
};

String _snapshot() {
  final content = {
    for (final lang in [...AppLanguages.supported, _unsupported])
      lang: _content(lang),
  };
  return '${const JsonEncoder.withIndent('  ').convert(content)}\n';
}

void main() {
  test('the guide, its content and its sources read as recorded', () {
    final actual = _snapshot();
    final file = File(_snapshotPath);
    if (Platform.environment['UPDATE_CONTENT_SNAPSHOT'] == '1') {
      file.writeAsStringSync(actual);
      return;
    }
    expect(
      file.existsSync(),
      isTrue,
      reason:
          'Missing $_snapshotPath: write it with UPDATE_CONTENT_SNAPSHOT=1.',
    );
    final recorded = file.readAsBytesSync();
    if (listEquals(utf8.encode(actual), recorded)) return;

    final now = actual.split('\n');
    final before = utf8.decode(recorded).split('\n');
    var i = 0;
    while (i < now.length && i < before.length && now[i] == before[i]) {
      i++;
    }
    fail(
      'The content differs from $_snapshotPath at line ${i + 1}:\n'
      '  recorded: ${i < before.length ? before[i] : '(end of file)'}\n'
      '  now:      ${i < now.length ? now[i] : '(end of file)'}\n'
      'If the change is intended, rerun with UPDATE_CONTENT_SNAPSHOT=1 and '
      'review the diff.',
    );
  });
}

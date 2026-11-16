import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/utils/code_point_limit.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/domain/nous/note_words.dart';
import 'package:nousdeux/presentation/providers/own_words_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

/// "Mes mots": which notes show on Nous and in what order, the five presets
/// and one's own saved ones. All of it stays on this phone.
class MyWordsScreen extends ConsumerStatefulWidget {
  const MyWordsScreen({super.key});

  @override
  ConsumerState<MyWordsScreen> createState() => _MyWordsScreenState();
}

class _MyWordsScreenState extends ConsumerState<MyWordsScreen> {
  final _add = TextEditingController();

  @override
  void dispose() {
    _add.dispose();
    super.dispose();
  }

  String get _lang => ref.read(myProfileProvider).valueOrNull?.language ?? 'fr';

  void _say(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggle(int index) async {
    HapticFeedback.selectionClick();
    final done = await ref.read(noteWordsProvider.notifier).toggle(index);
    if (!done && mounted) _say(myWordsFull(_lang));
  }

  Future<void> _addWord(NoteWords words) async {
    final text = cleanNoteText(_add.text);
    if (text.isEmpty) return;
    if (words.contains(text)) {
      _say(myWordsAlready(_lang));
      return;
    }
    await ref.read(noteWordsProvider.notifier).add(text);
    _add.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final words = ref.watch(noteWordsProvider).valueOrNull;
    final quiet = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(),
      body: words == null
          ? const SizedBox.shrink()
          : ReorderableListView(
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.fromLTRB(28, 0, 28, AppSpacing.lg),
              onReorder: (from, to) =>
                  ref.read(noteWordsProvider.notifier).move(from, to),
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(myWordsTitle(lang), style: theme.textTheme.displaySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(myWordsHelp(lang), style: quiet),
                  const SizedBox(height: AppSpacing.sm),
                  Divider(height: 1, color: scheme.outlineVariant),
                ],
              ),
              footer: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _add,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          inputFormatters: const [
                            CodePointLimit(noteTextMaxLength),
                          ],
                          onSubmitted: (_) => _addWord(words),
                          decoration: InputDecoration(
                            hintText: myWordsAddHint(lang),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _addWord(words),
                        child: Text(myWordsAdd(lang)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(myWordsDrag(lang), style: theme.textTheme.bodySmall),
                ],
              ),
              children: [
                for (final (i, entry) in words.entries.indexed)
                  _WordRow(
                    key: ValueKey(
                      entry.word.isOwn
                          ? 'own:${entry.word.text!.toLowerCase()}'
                          : 'preset:${entry.word.kind.wire}',
                    ),
                    index: i,
                    lang: lang,
                    entry: entry,
                    onToggle: () => _toggle(i),
                    onRemove: entry.word.isOwn
                        ? () => ref
                              .read(noteWordsProvider.notifier)
                              .remove(entry.word)
                        : null,
                  ),
              ],
            ),
    );
  }
}

/// A note with its tick (shown on Nous or not), a cross for one's own, and
/// the handle to move it.
class _WordRow extends StatelessWidget {
  const _WordRow({
    super.key,
    required this.index,
    required this.lang,
    required this.entry,
    required this.onToggle,
    required this.onRemove,
  });

  final int index;
  final String lang;
  final NoteWordEntry entry;
  final VoidCallback onToggle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = pingLabel(lang, entry.word.kind, text: entry.word.text);
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: scheme.surfaceContainer)),
        ),
        child: Row(
          children: [
            Expanded(
              child: MergeSemantics(
                child: InkWell(
                  onTap: onToggle,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Row(
                      children: [
                        Checkbox(
                          value: entry.shown,
                          onChanged: (_) => onToggle(),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: entry.shown
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (onRemove != null)
              IconButton(
                tooltip: myWordsRemove(lang, label),
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 20),
                color: scheme.onSurfaceVariant,
              ),
            ReorderableDragStartListener(
              index: index,
              child: Tooltip(
                message: myWordsMove(lang, label),
                child: SizedBox(
                  width: 44,
                  height: 48,
                  child: Icon(Icons.drag_handle, color: scheme.outline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

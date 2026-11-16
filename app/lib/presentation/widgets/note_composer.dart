import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/nous_strings.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/core/utils/code_point_limit.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/domain/nous/note_words.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/presentation/providers/own_words_provider.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// Opens the sheet to write a little note of one's own to [partnerName] and
/// send it, then says it was sent.
Future<void> showNoteComposer(
  BuildContext context, {
  required String lang,
  required String partnerName,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final sent = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => NoteComposer(lang: lang, partnerName: partnerName),
  );
  if (sent == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(nousNoteSent(lang, PingKind.custom, text: sent))),
    );
}

/// The sheet behind "Écrire…": the note (40 characters at most), whether to
/// keep it in "Mes mots", and Send. Pops with the text once it is sent; a
/// refusal (the 30-second limit, no connection) stays on the sheet.
class NoteComposer extends ConsumerStatefulWidget {
  const NoteComposer({
    super.key,
    required this.lang,
    required this.partnerName,
  });

  final String lang;
  final String partnerName;

  @override
  ConsumerState<NoteComposer> createState() => _NoteComposerState();
}

class _NoteComposerState extends ConsumerState<NoteComposer> {
  final _text = TextEditingController();
  bool _keep = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = cleanNoteText(_text.text);
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await ref
        .read(pingRepositoryProvider)
        .send(PingKind.custom, text: text);
    if (!mounted) return;
    if (result.failure case final Failure failure) {
      setState(() {
        _sending = false;
        _error = pingResultMessage(widget.lang, PingKind.custom, failure);
      });
      return;
    }
    HapticFeedback.lightImpact();
    if (_keep) await ref.read(noteWordsProvider.notifier).add(text);
    if (mounted) Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lang = widget.lang;
    final count = cleanNoteText(_text.text).runes.length;
    final quiet = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    // Scrolls when the keyboard and a large text size leave too little room.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        28,
        AppSpacing.xs,
        28,
        AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NotebookLabel(nousWriteTo(lang, widget.partnerName)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _text,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            inputFormatters: const [CodePointLimit(noteTextMaxLength)],
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w300,
            ),
            decoration: InputDecoration(
              filled: false,
              contentPadding: const EdgeInsets.only(top: 6, bottom: 10),
              hintText: nousWriteHint(lang),
              errorText: _error,
              errorMaxLines: 3,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: scheme.primary),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: scheme.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(nousWriteReplaces(lang), style: quiet)),
              const SizedBox(width: AppSpacing.sm),
              Text('$count / $noteTextMaxLength', style: quiet),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(nousKeepWord(lang)),
            value: _keep,
            onChanged: (on) => setState(() => _keep = on),
          ),
          const SizedBox(height: AppSpacing.xs),
          FilledButton(
            onPressed: count == 0 || _sending ? null : _send,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: const StadiumBorder(),
            ),
            child: Text(nousSend(lang)),
          ),
        ],
      ),
    );
  }
}

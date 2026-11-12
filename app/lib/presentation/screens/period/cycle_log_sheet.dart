import 'package:flutter/material.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/domain/cycle/cycle_stats.dart';
import 'package:nousdeux/presentation/widgets/notebook.dart';

/// Which end of a period the sheet notes.
enum CycleLogKind { started, ended }

/// R1: asks which day a period started or ended, for a day other than the
/// one the main button takes. Returns the chosen day, or null if dismissed.
Future<DateTime?> showCycleLogSheet(
  BuildContext context, {
  required CycleLogKind kind,
  required String lang,
  required DateTime today,

  /// The earliest day allowed (the period's start, when noting its end).
  DateTime? earliest,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _CycleLogSheet(
      kind: kind,
      lang: lang,
      today: today,
      earliest: earliest ?? DateTime(today.year - 2, today.month, today.day),
    ),
  );
}

class _CycleLogSheet extends StatefulWidget {
  const _CycleLogSheet({
    required this.kind,
    required this.lang,
    required this.today,
    required this.earliest,
  });

  final CycleLogKind kind;
  final String lang;
  final DateTime today;
  final DateTime earliest;

  @override
  State<_CycleLogSheet> createState() => _CycleLogSheetState();
}

class _CycleLogSheetState extends State<_CycleLogSheet> {
  late DateTime _day;
  bool _picked = false;

  DateTime get _yesterday =>
      DateTime(widget.today.year, widget.today.month, widget.today.day - 1);

  bool get _yesterdayAllowed => daysBetween(widget.earliest, _yesterday) >= 0;

  @override
  void initState() {
    super.initState();
    _day = _yesterdayAllowed ? _yesterday : widget.today;
  }

  Future<void> _pickDay() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: widget.earliest,
      lastDate: widget.today,
    );
    if (day != null && mounted) {
      setState(() {
        _day = day;
        _picked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = widget.lang;
    final isToday = daysBetween(_day, widget.today) == 0;
    final isYesterday = daysBetween(_day, _yesterday) == 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.kind == CycleLogKind.started
                  ? cycleSheetStarted(lang)
                  : cycleSheetEnded(lang),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 20),
            NotebookLabel(cycleSheetWhen(lang)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_yesterdayAllowed)
                  ChoiceChip(
                    label: Text(cycleYesterday(lang)),
                    selected: isYesterday && !_picked,
                    onSelected: (_) => setState(() {
                      _day = _yesterday;
                      _picked = false;
                    }),
                  ),
                ChoiceChip(
                  label: Text(cycleToday(lang)),
                  selected: isToday && !_picked,
                  onSelected: (_) => setState(() {
                    _day = widget.today;
                    _picked = false;
                  }),
                ),
                ChoiceChip(
                  label: Text(
                    _picked
                        ? cycleShortDate(lang, _day)
                        : cycleAnotherDay(lang),
                  ),
                  selected: _picked,
                  onSelected: (_) => _pickDay(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => Navigator.of(context).pop(_day),
              child: Text(cycleSave(lang)),
            ),
            if (widget.kind == CycleLogKind.started) ...[
              const SizedBox(height: 12),
              Text(
                cycleSheetFootnote(lang),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/constants/cycle_strings.dart';
import 'package:nousdeux/core/constants/period_education.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

/// Fixes the dates of one period (or notes a new one).
class PeriodLogFormScreen extends ConsumerStatefulWidget {
  const PeriodLogFormScreen({super.key, this.log});

  final PeriodLogEntity? log;

  @override
  ConsumerState<PeriodLogFormScreen> createState() =>
      _PeriodLogFormScreenState();
}

class _PeriodLogFormScreenState extends ConsumerState<PeriodLogFormScreen> {
  late DateTime _startDate;
  DateTime? _endDate;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate =
        widget.log?.startDate ?? DateTime(now.year, now.month, now.day);
    _endDate = widget.log?.endDate;
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(periodRepositoryProvider);
    final log = widget.log;
    final result = log == null
        ? await repo.createLog(startDate: _startDate, endDate: _endDate)
        : await repo.updateLog(
            id: log.id,
            startDate: _startDate,
            endDate: _endDate,
          );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.failure != null) {
      setState(() => _error = result.failure!.message);
      return;
    }
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  Future<DateTime?> _pick(DateTime initial, DateTime first) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(now.year, now.month, now.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.log != null ? periodLogEdit(lang) : periodLogNew(lang),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          ListTile(
            title: Text(periodStartDate(lang)),
            subtitle: Text(cycleShortDate(lang, _startDate)),
            onTap: () async {
              final d = await _pick(_startDate, DateTime(2000));
              if (d != null && mounted) {
                setState(() {
                  _startDate = d;
                  if (_endDate != null && _endDate!.isBefore(d)) {
                    _endDate = null;
                  }
                });
              }
            },
          ),
          ListTile(
            title: Text(periodEndDate(lang)),
            subtitle: Text(
              _endDate == null ? '—' : cycleShortDate(lang, _endDate!),
            ),
            trailing: _endDate == null
                ? null
                : IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _endDate = null),
                  ),
            onTap: () async {
              final d = await _pick(_endDate ?? _startDate, _startDate);
              if (d != null && mounted) setState(() => _endDate = d);
            },
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _loading ? null : _save,
              child: _loading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(periodSave(lang)),
            ),
          ),
        ],
      ),
    );
  }
}

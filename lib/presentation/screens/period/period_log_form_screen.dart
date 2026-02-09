import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nousdeux/core/constants/app_spacing.dart';
import 'package:nousdeux/core/constants/period_options.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

class PeriodLogFormScreen extends ConsumerStatefulWidget {
  const PeriodLogFormScreen({super.key, this.log});

  final PeriodLogEntity? log;

  @override
  ConsumerState<PeriodLogFormScreen> createState() =>
      _PeriodLogFormScreenState();
}

class _PeriodLogFormScreenState extends ConsumerState<PeriodLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  DateTime? _endDate;
  String? _mood;
  final Set<String> _symptoms = {};
  final TextEditingController _notesController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.log != null) {
      _startDate = widget.log!.startDate;
      _endDate = widget.log!.endDate;
      _mood = widget.log!.mood;
      _symptoms.addAll(widget.log!.symptoms);
      _notesController.text = widget.log!.notes ?? '';
    } else {
      _startDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(periodRepositoryProvider);

    if (widget.log != null) {
      final result = await repo.updateLog(
        id: widget.log!.id,
        startDate: _startDate,
        endDate: _endDate,
        mood: _mood,
        symptoms: (_symptoms.toList()..sort()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (result.failure != null) {
        setState(() => _error = result.failure!.message);
        return;
      }
    } else {
      final result = await repo.createLog(
        startDate: _startDate,
        endDate: _endDate,
        mood: _mood,
        symptoms: _symptoms.isEmpty ? null : (_symptoms.toList()..sort()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (result.failure != null) {
        setState(() => _error = result.failure!.message);
        return;
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String _formatDate(BuildContext context, DateTime d) {
    final language = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final locale = language == 'fr' ? 'fr_FR' : 'en_US';
    final fmt = language == 'fr'
        ? DateFormat('d MMM y', locale)
        : DateFormat('MMM d, y', locale);
    return fmt.format(d.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.log != null
              ? 'Modifier l\'enregistrement'
              : 'Nouvel enregistrement',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.sm),
          children: [
            ListTile(
              title: const Text('Date de début'),
              subtitle: Text(_formatDate(context, _startDate)),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
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
              title: const Text('Date de fin (optionnel)'),
              subtitle: Text(
                _endDate == null ? '—' : _formatDate(context, _endDate!),
              ),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? _startDate,
                  firstDate: _startDate,
                  lastDate: DateTime(2100),
                );
                if (d != null && mounted) {
                  setState(() => _endDate = d);
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _mood,
              decoration: const InputDecoration(labelText: 'Humeur'),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('—')),
                ...periodMoodOptions.map(
                  (o) => DropdownMenuItem(value: o.value, child: Text(o.label)),
                ),
              ],
              onChanged: (v) => setState(() => _mood = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Symptômes (optionnel)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: periodSymptomOptions.map((o) {
                final selected = _symptoms.contains(o.value);
                return FilterChip(
                  label: Text(o.label),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _symptoms.add(o.value);
                      } else {
                        _symptoms.remove(o.value);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:nous_deux/core/constants/app_constants.dart';
import 'package:nous_deux/core/constants/app_spacing.dart';
import 'package:nous_deux/domain/entities/calendar_event_entity.dart';
import 'package:nous_deux/presentation/providers/calendar_provider.dart';
import 'package:nous_deux/presentation/providers/profile_provider.dart';

class CalendarEventFormScreen extends ConsumerStatefulWidget {
  const CalendarEventFormScreen({
    super.key,
    this.event,
    required this.initialDate,
  });
  final CalendarEventEntity? event;
  final DateTime initialDate;

  @override
  ConsumerState<CalendarEventFormScreen> createState() =>
      _CalendarEventFormScreenState();
}

class _CalendarEventFormScreenState
    extends ConsumerState<CalendarEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _startTime;
  late DateTime _endTime;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descController = TextEditingController(
      text: widget.event?.description ?? '',
    );
    final initial = widget.initialDate;
    _startTime = widget.event?.startTime ?? _roundToNextHour(initial);
    _endTime =
        widget.event?.endTime ?? _startTime.add(const Duration(hours: 1));
  }

  /// Rounds to the next full hour (e.g. 15:28 → 16:00).
  static DateTime _roundToNextHour(DateTime d) {
    final atHour = DateTime(d.year, d.month, d.day, d.hour, 0, 0, 0);
    if (d.minute == 0 && d.second == 0 && d.millisecond == 0) {
      return atHour;
    }
    return atHour.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    final repo = ref.read(calendarRepositoryProvider);
    if (widget.event != null) {
      final result = await repo.updateEvent(
        id: widget.event!.id,
        title: title,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (result.failure != null) {
        setState(() => _error = result.failure!.message);
        return;
      }
    } else {
      final result = await repo.createEvent(
        title: title,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
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

  String _formatDateTime(BuildContext context, DateTime dt) {
    final language = ref.watch(myProfileProvider).valueOrNull?.language ?? 'fr';
    final locale = language == 'fr' ? 'fr_FR' : 'en_US';
    final dateFormat = language == 'fr'
        ? DateFormat('d MMM y HH:mm', locale)
        : DateFormat('MMM d, y h:mm a', locale);
    return dateFormat.format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event != null ? 'Modifier l\'événement' : 'Nouvel événement',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.sm),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
              maxLength: AppConstants.eventTitleMaxLength,
              validator: (v) =>
                  v?.trim().isEmpty ?? true ? 'Titre requis' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
              ),
              maxLines: 3,
              maxLength: AppConstants.eventDescriptionMaxLength,
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              title: const Text('Début'),
              subtitle: Text(_formatDateTime(context, _startTime)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startTime,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date == null || !mounted) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_startTime),
                );
                if (time == null || !mounted) return;
                setState(
                  () => _startTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Fin'),
              subtitle: Text(_formatDateTime(context, _endTime)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endTime,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date == null || !mounted) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_endTime),
                );
                if (time == null || !mounted) return;
                setState(
                  () => _endTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  ),
                );
              },
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

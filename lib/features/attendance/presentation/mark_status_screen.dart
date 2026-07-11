import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../data/attendance_repository.dart';
import '../models/attendance_models.dart';

class MarkStatusScreen extends StatefulWidget {
  const MarkStatusScreen({super.key, required this.attendanceRepository});

  final AttendanceRepository attendanceRepository;

  @override
  State<MarkStatusScreen> createState() => _MarkStatusScreenState();
}

class _MarkStatusScreenState extends State<MarkStatusScreen> {
  DateTime _date = DateTime.now();
  AttendanceStatus _status = AttendanceStatus.halfDay;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.attendanceRepository.markStatus(
        date: _date,
        status: _status,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isSubmitting = false;
        _errorMessage = switch (e) {
          ConnectionException() => l10n.connectionErrorMessage,
          ApiException(message: final message) => message,
          _ => l10n.genericErrorMessage,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.markStatusTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.dateLabel),
              subtitle: Text(DateFormat('d MMMM yyyy', Localizations.localeOf(context).toString()).format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AttendanceStatus>(
              initialValue: _status,
              decoration: InputDecoration(labelText: l10n.typeLabel, border: const OutlineInputBorder()),
              items: selfReportableStatuses
                  .map((status) => DropdownMenuItem(value: status, child: Text(status.label(context))))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: l10n.notesLabel, border: const OutlineInputBorder()),
              maxLines: 3,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.submitButton),
            ),
          ],
        ),
      ),
    );
  }
}

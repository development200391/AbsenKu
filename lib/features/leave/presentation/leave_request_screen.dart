import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../data/leave_repository.dart';
import '../models/leave_models.dart';
import 'leave_history_screen.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key, required this.leaveRepository});

  final LeaveRepository leaveRepository;

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  List<LeaveType> _leaveTypes = [];
  bool _isLoadingTypes = true;
  int? _selectedLeaveTypeId;
  DateTimeRange? _dateRange;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLeaveTypes();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaveTypes() async {
    setState(() {
      _isLoadingTypes = true;
      _errorMessage = null;
    });

    try {
      final leaveTypes = await widget.leaveRepository.getLeaveTypes();
      if (!mounted) return;
      setState(() {
        _leaveTypes = leaveTypes;
        _selectedLeaveTypeId = leaveTypes.isEmpty ? null : leaveTypes.first.id;
        _isLoadingTypes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingTypes = false;
        _errorMessage = _describeError(e);
      });
    }
  }

  String _describeError(Object error) {
    final l10n = AppLocalizations.of(context)!;
    return switch (error) {
      ConnectionException() => l10n.connectionErrorMessage,
      ApiException(message: final message) => message,
      _ => l10n.genericErrorMessage,
    };
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedLeaveTypeId == null) {
      setState(() => _errorMessage = l10n.leaveTypeRequired);
      return;
    }

    if (_dateRange == null) {
      setState(() => _errorMessage = l10n.selectDateRangePlaceholder);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.leaveRepository.submit(
        leaveTypeId: _selectedLeaveTypeId!,
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
        reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = _describeError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaveRequestTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.leaveHistoryTooltip,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => LeaveHistoryScreen(leaveRepository: widget.leaveRepository),
            )),
          ),
        ],
      ),
      body: _isLoadingTypes
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _selectedLeaveTypeId,
                    decoration: InputDecoration(labelText: l10n.leaveTypeLabel, border: const OutlineInputBorder()),
                    items: _leaveTypes
                        .map((type) => DropdownMenuItem(value: type.id, child: Text(type.name)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedLeaveTypeId = value),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.dateRangeLabel),
                    subtitle: Text(_dateRange == null
                        ? l10n.selectDateRangePlaceholder
                        : '${DateFormat('d MMM yyyy', locale).format(_dateRange!.start)} - '
                            '${DateFormat('d MMM yyyy', locale).format(_dateRange!.end)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDateRange,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reasonController,
                    decoration: InputDecoration(labelText: l10n.reasonLabel, border: const OutlineInputBorder()),
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

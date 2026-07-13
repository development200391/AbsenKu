import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../data/leave_repository.dart';
import '../models/leave_models.dart';
import 'leave_history_screen.dart';

const _defaultMaxAttachmentSizeBytes = 5 * 1024 * 1024;

class _AttachmentSlot {
  _AttachmentSlot(this.detail);

  final DocumentReferenceTypeConfigDetail detail;
  final TextEditingController noteController = TextEditingController();
  PlatformFile? file;

  void dispose() => noteController.dispose();
}

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key, required this.leaveRepository});

  final LeaveRepository leaveRepository;

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  List<LeaveType> _leaveTypes = [];
  final List<_AttachmentSlot> _slots = [];
  bool _isLoading = true;
  int? _selectedLeaveTypeId;
  DateTimeRange? _dateRange;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    for (final slot in _slots) {
      slot.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        widget.leaveRepository.getLeaveTypes(),
        widget.leaveRepository.getAttachmentConfig(),
      ]);
      if (!mounted) return;
      final leaveTypes = results[0] as List<LeaveType>;
      final config = results[1] as DocumentReferenceTypeConfig?;
      setState(() {
        _leaveTypes = leaveTypes;
        _selectedLeaveTypeId = leaveTypes.isEmpty ? null : leaveTypes.first.id;
        _slots.addAll((config?.details ?? []).map(_AttachmentSlot.new));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
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

  Future<void> _pickSlotFile(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final slot = _slots[index];
    final maxSize = slot.detail.maxFileSizeBytes ?? _defaultMaxAttachmentSizeBytes;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: slot.detail.allowedExtensions.map((ext) => ext.replaceFirst('.', '')).toList(),
      withData: true,
    );

    final picked = result?.files.single;
    if (picked == null) {
      return;
    }

    if (picked.size > maxSize) {
      setState(() => _errorMessage = l10n.attachmentTooLarge);
      return;
    }

    setState(() {
      slot.file = picked;
      _errorMessage = null;
    });
  }

  void _removeSlotFile(int index) {
    setState(() => _slots[index].file = null);
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

    for (final slot in _slots) {
      if (slot.detail.isRequired && slot.file == null) {
        setState(() => _errorMessage = l10n.attachmentSlotRequiredMessage(slot.detail.name));
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.leaveRepository.submit(
        leaveTypeId: _selectedLeaveTypeId!,
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
        reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
        slots: _slots
            .map((slot) => (
                  bytes: slot.file?.bytes,
                  fileName: slot.file?.name,
                  note: slot.noteController.text.trim().isEmpty ? null : slot.noteController.text.trim(),
                ))
            .toList(),
      );

      if (!mounted) return;

      if (result.attachmentWarnings.isNotEmpty) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.attachmentWarningsTitle),
            content: Text(result.attachmentWarnings.join('\n')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.okButton),
              ),
            ],
          ),
        );
        if (!mounted) return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = _describeError(e);
      });
    }
  }

  Widget _buildSlot(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final slot = _slots[index];
    final hasFile = slot.file != null;
    final isMissingRequired = slot.detail.isRequired && !hasFile;
    final stripeColor = hasFile
        ? Colors.green
        : (isMissingRequired ? Colors.orange : theme.dividerColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 16, color: stripeColor, margin: const EdgeInsets.only(right: 8)),
              Expanded(
                child: Text(
                  slot.detail.name,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                slot.detail.isRequired ? l10n.attachmentRequiredTag : l10n.attachmentOptionalTag,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: slot.detail.isRequired ? Colors.orange[800] : theme.hintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: hasFile ? null : () => _pickSlotFile(index),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: hasFile ? Colors.green.withValues(alpha: 0.08) : null,
                border: Border.all(color: hasFile ? Colors.green.withValues(alpha: 0.4) : theme.dividerColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(hasFile ? Icons.insert_drive_file : Icons.attach_file, size: 16, color: hasFile ? Colors.green : null),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasFile ? slot.file!.name : l10n.attachmentPlaceholder,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  if (hasFile)
                    InkWell(
                      onTap: () => _removeSlotFile(index),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(Icons.close, size: 16, semanticLabel: l10n.attachmentRemoveTooltip),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: slot.noteController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              hintText: l10n.notesLabel,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ],
      ),
    );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
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
                  if (_slots.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(l10n.attachmentsTitle, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    ...List.generate(_slots.length, (index) => _buildSlot(context, index)),
                  ],
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

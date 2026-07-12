import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../data/leave_repository.dart';
import '../models/leave_models.dart';
import 'leave_history_screen.dart';

const _defaultAllowedAttachmentExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'docx'];
const _defaultMaxAttachmentSizeBytes = 5 * 1024 * 1024;

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key, required this.leaveRepository});

  final LeaveRepository leaveRepository;

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  List<LeaveType> _leaveTypes = [];
  DocumentReferenceTypeConfig? _attachmentConfig;
  bool _isLoading = true;
  int? _selectedLeaveTypeId;
  DateTimeRange? _dateRange;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  final List<PlatformFile> _attachments = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  List<String> get _allowedExtensions =>
      _attachmentConfig?.allowedExtensions.map((ext) => ext.replaceFirst('.', '')).toList() ??
      _defaultAllowedAttachmentExtensions;

  int get _maxFileSizeBytes => _attachmentConfig?.maxFileSizeBytes ?? _defaultMaxAttachmentSizeBytes;

  int get _maxFileCount => _attachmentConfig?.maxFileCount ?? 1;

  bool get _isAttachmentRequired => _attachmentConfig?.isRequired ?? false;

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
      setState(() {
        _leaveTypes = leaveTypes;
        _selectedLeaveTypeId = leaveTypes.isEmpty ? null : leaveTypes.first.id;
        _attachmentConfig = results[1] as DocumentReferenceTypeConfig?;
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

  Future<void> _pickAttachments() async {
    final l10n = AppLocalizations.of(context)!;
    final remainingSlots = _maxFileCount - _attachments.length;
    if (remainingSlots <= 0) {
      setState(() => _errorMessage = l10n.attachmentMaxCountMessage(_maxFileCount));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      withData: true,
      allowMultiple: _maxFileCount > 1,
    );

    final picked = result?.files ?? [];
    if (picked.isEmpty) {
      return;
    }

    final tooLarge = picked.any((file) => file.size > _maxFileSizeBytes);
    if (tooLarge) {
      setState(() => _errorMessage = l10n.attachmentTooLarge);
      return;
    }

    final accepted = picked.take(remainingSlots).toList();

    setState(() {
      _attachments.addAll(accepted);
      _errorMessage = picked.length > remainingSlots ? l10n.attachmentMaxCountMessage(_maxFileCount) : null;
    });
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
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

    if (_isAttachmentRequired && _attachments.isEmpty) {
      setState(() => _errorMessage = l10n.attachmentRequiredMessage);
      return;
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
        files: _attachments
            .where((file) => file.bytes != null)
            .map((file) => (bytes: file.bytes!, fileName: file.name))
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
                  const SizedBox(height: 16),
                  Text(
                    _isAttachmentRequired ? l10n.attachmentLabelRequired : l10n.attachmentLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (_attachments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(l10n.attachmentPlaceholder, style: Theme.of(context).textTheme.bodyMedium),
                    )
                  else
                    ...List.generate(_attachments.length, (index) {
                      final file = _attachments[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(file.name, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: l10n.attachmentRemoveTooltip,
                          onPressed: () => _removeAttachment(index),
                        ),
                      );
                    }),
                  if (_attachments.length < _maxFileCount)
                    OutlinedButton.icon(
                      onPressed: _pickAttachments,
                      icon: const Icon(Icons.attach_file),
                      label: Text(l10n.attachmentAddButton),
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

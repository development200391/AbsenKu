import 'package:flutter/material.dart';

import '../../../core/api_exception.dart';
import '../../../core/file_opener.dart';
import '../../../l10n/app_localizations.dart';
import '../data/leave_repository.dart';
import '../models/leave_models.dart';

/// One row in an attachments bottom sheet. Tapping downloads the file (via
/// [leaveRepository]) and opens it with the OS's default viewer for that file
/// type — manages its own busy/error state so multiple tiles in the same
/// sheet can be tapped independently without rebuilding the whole sheet.
class AttachmentListTile extends StatefulWidget {
  const AttachmentListTile({super.key, required this.document, required this.leaveRepository});

  final LeaveDocument document;
  final LeaveRepository leaveRepository;

  @override
  State<AttachmentListTile> createState() => _AttachmentListTileState();
}

class _AttachmentListTileState extends State<AttachmentListTile> {
  bool _isOpening = false;
  String? _errorMessage;

  String _describeError(Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is ConnectionException) return l10n.connectionErrorMessage;
    if (error is ApiException) return error.message;
    return l10n.genericErrorMessage;
  }

  Future<void> _open() async {
    setState(() {
      _isOpening = true;
      _errorMessage = null;
    });

    try {
      final bytes = await widget.leaveRepository.downloadAttachment(widget.document.id);
      final openError = await openDownloadedFile(bytes, widget.document.originalFileName, uniqueId: widget.document.id);
      if (!mounted) return;
      setState(() {
        _isOpening = false;
        _errorMessage = openError;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isOpening = false;
        _errorMessage = _describeError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: _isOpening ? null : _open,
      leading: _isOpening
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.attach_file),
      title: Text(widget.document.originalFileName),
      subtitle: _errorMessage != null
          ? Text(_errorMessage!, style: TextStyle(color: colors.error))
          : Text('${(widget.document.fileSizeBytes / 1024).toStringAsFixed(0)} KB'),
    );
  }
}

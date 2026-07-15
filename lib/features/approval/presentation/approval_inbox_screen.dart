import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../data/approval_repository.dart';
import '../models/approval_models.dart';

class ApprovalInboxScreen extends StatefulWidget {
  const ApprovalInboxScreen({super.key, required this.approvalRepository});

  final ApprovalRepository approvalRepository;

  @override
  State<ApprovalInboxScreen> createState() => _ApprovalInboxScreenState();
}

class _ApprovalInboxScreenState extends State<ApprovalInboxScreen> {
  List<ApprovalInboxItem>? _items;
  bool _isLoading = true;
  String? _errorMessage;
  final _busyRequestIds = <int>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _describeError(Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is ConnectionException) return l10n.connectionErrorMessage;
    if (error is ApiException) return error.message;
    return l10n.genericErrorMessage;
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await widget.approvalRepository.getInbox();
      if (!mounted) return;
      setState(() {
        _items = items;
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

  Future<void> _handleAction(ApprovalInboxItem item, {required bool approve}) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(approve ? l10n.approveConfirmMessage : l10n.rejectConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(approve ? l10n.approveButton : l10n.rejectButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _busyRequestIds.add(item.requestId);
      _errorMessage = null;
    });

    try {
      if (approve) {
        await widget.approvalRepository.approve(item.requestId);
      } else {
        await widget.approvalRepository.reject(item.requestId);
      }

      if (!mounted) return;
      setState(() {
        _busyRequestIds.remove(item.requestId);
        _items = _items?.where((x) => x.requestId != item.requestId).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(approve ? l10n.approvalApprovedMessage : l10n.approvalRejectedMessage),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busyRequestIds.remove(item.requestId);
        _errorMessage = _describeError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.approvalInboxTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(l10n, locale, colors),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, String locale, ColorScheme colors) {
    if (_errorMessage != null && (_items == null || _items!.isEmpty)) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(_errorMessage!, style: TextStyle(color: colors.error))),
          ),
        ],
      );
    }

    final items = _items ?? [];
    if (items.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(l10n.noApprovalInbox)),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: items.length + (_errorMessage != null ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (_errorMessage != null && index == 0) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_errorMessage!, style: TextStyle(color: colors.error)),
          );
        }

        final item = items[index - (_errorMessage != null ? 1 : 0)];
        final isBusy = _busyRequestIds.contains(item.requestId);

        return ListTile(
          title: Text(item.subject),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.approvalRequestedBySummary(
                item.requestedByName,
                DateFormat('d MMM yyyy HH:mm', locale).format(item.requestedAt),
              )),
              const SizedBox(height: 2),
              Text(
                l10n.approvalDueLabel(DateFormat('d MMM yyyy HH:mm', locale).format(item.dueAt)),
                style: item.isOverdue ? TextStyle(color: colors.error, fontWeight: FontWeight.bold) : null,
              ),
            ],
          ),
          isThreeLine: true,
          trailing: isBusy
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: colors.error,
                      tooltip: l10n.rejectButton,
                      onPressed: () => _handleAction(item, approve: false),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: colors.primary,
                      tooltip: l10n.approveButton,
                      onPressed: () => _handleAction(item, approve: true),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

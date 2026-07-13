import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../data/leave_repository.dart';
import '../models/leave_models.dart';

class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key, required this.leaveRepository});

  final LeaveRepository leaveRepository;

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  late Future<List<LeaveRequest>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.leaveRepository.getHistory();
  }

  Color _statusColor(LeaveStatus status, ColorScheme colors) {
    switch (status) {
      case LeaveStatus.approved:
        return colors.primary;
      case LeaveStatus.rejected:
        return colors.error;
      case LeaveStatus.pending:
        return colors.tertiary;
    }
  }

  Future<void> _showAttachments(LeaveRequest request) async {
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<LeaveDocument>>(
              future: widget.leaveRepository.getAttachments(request.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  final error = snapshot.error;
                  final message = switch (error) {
                    ConnectionException() => l10n.connectionErrorMessage,
                    ApiException(message: final message) => message,
                    _ => l10n.genericErrorMessage,
                  };
                  return SizedBox(height: 100, child: Center(child: Text(message)));
                }

                final documents = snapshot.data ?? [];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.attachmentsTitle, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (documents.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(l10n.noAttachments),
                      )
                    else
                      ...documents.map((doc) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.attach_file),
                            title: Text(doc.originalFileName),
                            subtitle: Text('${(doc.fileSizeBytes / 1024).toStringAsFixed(0)} KB'),
                          )),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.leaveHistoryTitle)),
      body: FutureBuilder<List<LeaveRequest>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = switch (error) {
              ConnectionException() => l10n.connectionErrorMessage,
              ApiException(message: final message) => message,
              _ => l10n.genericErrorMessage,
            };
            return Center(child: Text(message));
          }

          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return Center(child: Text(l10n.noLeaveHistory));
          }

          return ListView.separated(
            itemCount: requests.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final request = requests[index];
              final reason = request.reason?.trim();
              return ListTile(
                title: Text(request.leaveTypeName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.leavePeriodSummary(
                      DateFormat('d MMM yyyy', locale).format(request.startDate),
                      DateFormat('d MMM yyyy', locale).format(request.endDate),
                      request.totalDays.toString(),
                    )),
                    if (reason != null && reason.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(l10n.leaveReasonSummary(reason)),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      tooltip: l10n.attachmentsTitle,
                      onPressed: () => _showAttachments(request),
                    ),
                    Text(
                      request.status.label(context),
                      style: TextStyle(color: _statusColor(request.status, colors), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

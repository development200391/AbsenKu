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
              return ListTile(
                title: Text(request.leaveTypeName),
                subtitle: Text(l10n.leavePeriodSummary(
                  DateFormat('d MMM yyyy', locale).format(request.startDate),
                  DateFormat('d MMM yyyy', locale).format(request.endDate),
                  request.totalDays.toString(),
                )),
                trailing: Text(
                  request.status.label(context),
                  style: TextStyle(color: _statusColor(request.status, colors), fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

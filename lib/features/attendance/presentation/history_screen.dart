import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../data/attendance_repository.dart';
import '../models/attendance_models.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.attendanceRepository});

  final AttendanceRepository attendanceRepository;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<AttendanceRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.attendanceRepository.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: FutureBuilder<List<AttendanceRecord>>(
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

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return Center(child: Text(l10n.noHistory));
          }

          return ListView.separated(
            itemCount: records.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                title: Text(DateFormat('EEEE, d MMMM yyyy', locale).format(record.date)),
                subtitle: Text(l10n.attendanceSummary(
                  record.checkIn == null ? '-' : DateFormat('HH:mm').format(record.checkIn!),
                  record.checkOut == null ? '-' : DateFormat('HH:mm').format(record.checkOut!),
                )),
                trailing: Text(record.status.label(context)),
              );
            },
          );
        },
      ),
    );
  }
}

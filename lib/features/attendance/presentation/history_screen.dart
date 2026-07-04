import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: FutureBuilder<List<AttendanceRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(child: Text('Belum ada riwayat.'));
          }

          return ListView.separated(
            itemCount: records.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                title: Text(DateFormat('EEEE, d MMMM yyyy').format(record.date)),
                subtitle: Text(
                  'In: ${record.checkIn == null ? '-' : DateFormat('HH:mm').format(record.checkIn!)}   '
                  'Out: ${record.checkOut == null ? '-' : DateFormat('HH:mm').format(record.checkOut!)}',
                ),
                trailing: Text(record.status.label),
              );
            },
          );
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/auth_session.dart';
import '../../../core/brand.dart';
import '../../auth/auth_repository.dart';
import '../data/attendance_repository.dart';
import '../data/location_helper.dart';
import '../models/attendance_models.dart';
import 'history_screen.dart';
import 'mark_status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.attendanceRepository,
    required this.authRepository,
    required this.authSession,
  });

  final AttendanceRepository attendanceRepository;
  final AuthRepository authRepository;
  final AuthSession authSession;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AttendanceRecord? _today;
  AttendanceSettings? _settings;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  Duration _serverOffset = Duration.zero;
  DateTime _clock = DateTime.now();
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        widget.attendanceRepository.getToday(),
        widget.attendanceRepository.getSettings(),
        widget.attendanceRepository.getServerTime(),
      ]);
      if (!mounted) return;
      final serverTime = results[2] as DateTime;
      setState(() {
        _today = results[0] as AttendanceRecord?;
        _settings = results[1] as AttendanceSettings;
        _serverOffset = serverTime.difference(DateTime.now());
        _clock = serverTime;
        _isLoading = false;
      });
      _startClock();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _clock = DateTime.now().add(_serverOffset);
      });
    });
  }

  Future<void> _handleCheckInOut({required bool isCheckIn}) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final position = await getCurrentPosition();
      final record = isCheckIn
          ? await widget.attendanceRepository.checkIn(latitude: position.latitude, longitude: position.longitude)
          : await widget.attendanceRepository.checkOut(latitude: position.latitude, longitude: position.longitude);

      if (!mounted) return;
      setState(() {
        _today = record;
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _logout() async {
    await widget.authRepository.logout();
    await widget.authSession.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AbsenKuMark(size: 28, tile: false),
            SizedBox(width: 10),
            Text('AbsenKu'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => HistoryScreen(attendanceRepository: widget.attendanceRepository),
            )),
          ),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now())),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm:ss').format(_clock),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildTimeRow('Check-in', _today?.checkIn),
                          const SizedBox(height: 8),
                          _buildTimeRow('Check-out', _today?.checkOut),
                          if (_today != null) ...[
                            const SizedBox(height: 8),
                            Text('Status: ${_today!.status.label}'),
                          ],
                          if (_settings != null && !_settings!.isOfficeLocationConfigured) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Lokasi kantor belum diatur oleh admin. Hubungi HR.',
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  _buildActionButton(),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.event_busy_outlined),
                    label: const Text('Ajukan Izin / Sakit / Cuti / Setengah Hari'),
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            final submitted = await Navigator.of(context).push<bool>(MaterialPageRoute(
                              builder: (_) => MarkStatusScreen(attendanceRepository: widget.attendanceRepository),
                            ));
                            if (submitted == true) {
                              _load();
                            }
                          },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTimeRow(String label, DateTime? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value == null ? '-' : DateFormat('HH:mm').format(value), style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButton() {
    final hasCheckedIn = _today?.checkIn != null;
    final hasCheckedOut = _today?.checkOut != null;

    if (hasCheckedIn && hasCheckedOut) {
      return const FilledButton(onPressed: null, child: Text('Selesai hari ini'));
    }

    final isCheckIn = !hasCheckedIn;

    return FilledButton.icon(
      icon: _isSubmitting
          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(isCheckIn ? Icons.login : Icons.logout),
      label: Text(isCheckIn ? 'Check In' : 'Check Out'),
      onPressed: _isSubmitting ? null : () => _handleCheckInOut(isCheckIn: isCheckIn),
    );
  }
}

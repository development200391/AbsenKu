import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api_exception.dart';
import '../../../core/auth_session.dart';
import '../../../core/brand.dart';
import '../../../core/language_picker.dart';
import '../../../core/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
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
    required this.localeController,
  });

  final AttendanceRepository attendanceRepository;
  final AuthRepository authRepository;
  final AuthSession authSession;
  final LocaleController localeController;

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

  String _describeError(Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is ConnectionException) return l10n.connectionErrorMessage;
    if (error is ApiException) return error.message;
    if (error is LocationServiceDisabledException) return l10n.locationServiceDisabled;
    if (error is LocationPermissionDeniedException) return l10n.locationPermissionDenied;
    return l10n.genericErrorMessage;
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
        _errorMessage = _describeError(e);
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
        _errorMessage = _describeError(e);
      });
    }
  }

  Future<void> _logout() async {
    await widget.authRepository.logout();
    await widget.authSession.logout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

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
            icon: const Icon(Icons.language),
            tooltip: l10n.languageTooltip,
            onPressed: () => showLanguagePicker(context, widget.localeController),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.historyTooltip,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => HistoryScreen(attendanceRepository: widget.attendanceRepository),
            )),
          ),
          IconButton(icon: const Icon(Icons.logout), tooltip: l10n.logoutTooltip, onPressed: _logout),
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
                          Text(DateFormat('EEEE, d MMMM yyyy', locale).format(DateTime.now())),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm:ss').format(_clock),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildTimeRow(l10n.checkIn, _today?.checkIn),
                          const SizedBox(height: 8),
                          _buildTimeRow(l10n.checkOut, _today?.checkOut),
                          if (_today != null) ...[
                            const SizedBox(height: 8),
                            Text(l10n.statusLine(_today!.status.label(context))),
                          ],
                          if (_settings != null && !_settings!.isOfficeLocationConfigured) ...[
                            const SizedBox(height: 12),
                            Text(
                              l10n.officeLocationNotConfigured,
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
                  _buildActionButton(l10n),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.event_busy_outlined),
                    label: Text(l10n.requestLeaveButton),
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

  Widget _buildActionButton(AppLocalizations l10n) {
    final hasCheckedIn = _today?.checkIn != null;
    final hasCheckedOut = _today?.checkOut != null;
    final isCheckIn = !hasCheckedIn;

    return FilledButton.icon(
      icon: _isSubmitting
          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(isCheckIn ? Icons.login : Icons.logout),
      label: Text(isCheckIn ? l10n.checkIn : (hasCheckedOut ? l10n.updateCheckOutButton : l10n.checkOut)),
      onPressed: _isSubmitting ? null : () => _handleCheckInOut(isCheckIn: isCheckIn),
    );
  }
}

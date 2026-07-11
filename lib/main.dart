import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/api_client.dart';
import 'core/auth_session.dart';
import 'core/biometric_auth_service.dart';
import 'core/brand.dart';
import 'core/diagnostics_reporter.dart';
import 'core/secure_storage.dart';
import 'features/attendance/data/attendance_repository.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/login_screen.dart';
import 'features/attendance/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[uncaught/flutter] ${details.exceptionAsString()}\n${details.stack}');
    DiagnosticsReporter.instance.report(details.exception, details.stack, source: 'flutter');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[uncaught/platform] $error\n$stack');
    DiagnosticsReporter.instance.report(error, stack, source: 'platform');
    return true;
  };

  await initializeDateFormatting('id_ID');
  runApp(const AbsenKuApp());
}

class AbsenKuApp extends StatefulWidget {
  const AbsenKuApp({super.key});

  @override
  State<AbsenKuApp> createState() => _AbsenKuAppState();
}

class _AbsenKuAppState extends State<AbsenKuApp> {
  final _storage = const SecureStorageService();
  late final AuthSession _authSession;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final AttendanceRepository _attendanceRepository;
  late final BiometricAuthService _biometricAuthService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authSession = AuthSession(_storage);
    _apiClient = ApiClient(_storage, onSessionExpired: _authSession.logout);
    _authRepository = AuthRepository(_apiClient, _storage);
    _attendanceRepository = AttendanceRepository(_apiClient);
    _biometricAuthService = BiometricAuthService();

    _router = GoRouter(
      refreshListenable: _authSession,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(
            authRepository: _authRepository,
            authSession: _authSession,
            biometricAuthService: _biometricAuthService,
          ),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => HomeScreen(
            attendanceRepository: _attendanceRepository,
            authRepository: _authRepository,
            authSession: _authSession,
          ),
        ),
      ],
      redirect: (context, state) {
        if (_authSession.isInitializing) {
          return null;
        }

        final loggingIn = state.matchedLocation == '/login';
        if (!_authSession.isAuthenticated) {
          return loggingIn ? null : '/login';
        }
        if (loggingIn) {
          return '/';
        }
        return null;
      },
    );

    _authSession.restore();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authSession,
      builder: (context, _) {
        if (_authSession.isInitializing) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

        return MaterialApp.router(
          title: 'AbsenKu',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Brand.seed),
            useMaterial3: true,
          ),
          routerConfig: _router,
        );
      },
    );
  }
}

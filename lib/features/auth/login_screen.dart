import 'package:flutter/material.dart';

import '../../core/auth_session.dart';
import '../../core/biometric_auth_service.dart';
import '../../core/brand.dart';
import 'auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authRepository,
    required this.authSession,
    required this.biometricAuthService,
  });

  final AuthRepository authRepository;
  final AuthSession authSession;
  final BiometricAuthService biometricAuthService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Whether the password form is shown. When a session is already stored on
  // disk, the screen starts on the biometric-unlock gate instead.
  bool _showPasswordForm = false;
  bool _isUnlocking = false;

  @override
  void initState() {
    super.initState();
    _showPasswordForm = !widget.authSession.hasStoredSession;
    if (widget.authSession.hasStoredSession) {
      _prepareUnlock();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _prepareUnlock() async {
    final available = await widget.biometricAuthService.isAvailable();
    if (!mounted) return;

    if (!available) {
      // Device has no usable biometrics: don't force a dead-end lock screen,
      // just let the existing session through like before this feature.
      widget.authSession.markAuthenticated();
      return;
    }

    _unlockWithBiometric();
  }

  Future<void> _unlockWithBiometric() async {
    setState(() {
      _isUnlocking = true;
      _errorMessage = null;
    });

    final success = await widget.biometricAuthService.authenticate();

    if (!mounted) return;

    if (success) {
      widget.authSession.markAuthenticated();
      return;
    }

    setState(() {
      _isUnlocking = false;
      _errorMessage = 'Verifikasi biometrik gagal atau dibatalkan.';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await widget.authRepository.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      return;
    }

    widget.authSession.markAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _showPasswordForm ? _buildPasswordForm(context) : _buildUnlockGate(context),
      ),
    );
  }

  Widget _buildUnlockGate(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AbsenKuMark(size: 88, tile: true, showRing: true),
            const SizedBox(height: 16),
            Text(
              'AbsenKu',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Brand.teal,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sesi Anda masih tersimpan. Verifikasi untuk melanjutkan.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_errorMessage != null) ...[
              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              icon: _isUnlocking
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.fingerprint),
              label: const Text('Buka dengan Sidik Jari / Face ID'),
              onPressed: _isUnlocking ? null : _unlockWithBiometric,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isUnlocking ? null : () => setState(() => _showPasswordForm = true),
              child: const Text('Login dengan Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: AbsenKuMark(size: 88, tile: true, showRing: true)),
              const SizedBox(height: 16),
              Text(
                'AbsenKu',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Brand.teal,
                    ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Username wajib diisi' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) => (value == null || value.isEmpty) ? 'Password wajib diisi' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Login'),
              ),
              if (widget.authSession.hasStoredSession) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isLoading ? null : () => setState(() => _showPasswordForm = false),
                  child: const Text('Kembali ke verifikasi biometrik'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

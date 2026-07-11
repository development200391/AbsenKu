import 'package:flutter/material.dart';

import '../../core/api_exception.dart';
import '../../core/auth_session.dart';
import '../../core/biometric_auth_service.dart';
import '../../core/brand.dart';
import '../../core/language_picker.dart';
import '../../core/locale_controller.dart';
import '../../l10n/app_localizations.dart';
import 'auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authRepository,
    required this.authSession,
    required this.biometricAuthService,
    required this.localeController,
  });

  final AuthRepository authRepository;
  final AuthSession authSession;
  final BiometricAuthService biometricAuthService;
  final LocaleController localeController;

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
      _errorMessage = AppLocalizations.of(context)!.biometricFailed;
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

    final l10n = AppLocalizations.of(context)!;

    try {
      await widget.authRepository.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    } on ConnectionException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.connectionErrorMessage;
      });
      return;
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.loginGenericError;
      });
      return;
    }

    if (!mounted) return;
    widget.authSession.markAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _showPasswordForm ? _buildPasswordForm(context) : _buildUnlockGate(context),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.language),
                tooltip: l10n.languageTooltip,
                onPressed: () => showLanguagePicker(context, widget.localeController),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockGate(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
            Text(l10n.unlockSubtitle, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            if (_errorMessage != null) ...[
              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              icon: _isUnlocking
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.fingerprint),
              label: Text(l10n.unlockWithBiometricButton),
              onPressed: _isUnlocking ? null : _unlockWithBiometric,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isUnlocking ? null : () => setState(() => _showPasswordForm = true),
              child: Text(l10n.loginWithPasswordButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                decoration: InputDecoration(labelText: l10n.usernameLabel, border: const OutlineInputBorder()),
                validator: (value) => (value == null || value.trim().isEmpty) ? l10n.usernameRequired : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: l10n.passwordLabel, border: const OutlineInputBorder()),
                obscureText: true,
                validator: (value) => (value == null || value.isEmpty) ? l10n.passwordRequired : null,
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
                    : Text(l10n.loginButton),
              ),
              if (widget.authSession.hasStoredSession) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isLoading ? null : () => setState(() => _showPasswordForm = false),
                  child: Text(l10n.backToBiometricButton),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

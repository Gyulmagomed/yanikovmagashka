import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/services/biometric_service.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';

class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({
    super.key,
    required this.onUnlocked,
    this.userName,
  });

  final VoidCallback onUnlocked;
  final String? userName;

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  bool _isAuthenticating = false;

  Future<void> _tryUnlock() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    try {
      final ok = await BiometricService.instance.authenticate();
      if (ok && mounted) {
        widget.onUnlocked();
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _tryUnlock();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.of(context);
    return Material(
      color: c.background,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: c.backgroundGradient,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                context.l10n('unlock'),
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n('unlock_fingerprint'),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _isAuthenticating ? null : _tryUnlock,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: c.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 56,
                    color: c.textPrimary,
                  ),
                ),
              ),
              if (_isAuthenticating) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              TextButton(
                onPressed: _isAuthenticating ? null : _tryUnlock,
                child: Text(
                  context.l10n('retry'),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: c.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

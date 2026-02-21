import 'package:flutter/material.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/services/auth_service.dart';
import 'package:telemost12_app/services/biometric_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _navigateAfterSplash();
    });
  }

  Future<void> _navigateAfterSplash() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    if (user != null) {
      final biometricEnabled = BiometricService.instance.enabled;
      final biometricAvailable = await BiometricService.instance.isAvailable;
      if (biometricEnabled && biometricAvailable) {
        Navigator.of(context).pushReplacementNamed(
          '/lock',
          arguments: {'userName': user['name']},
        );
      } else {
        Navigator.of(context).pushReplacementNamed(
          '/home',
          arguments: {'userName': user['name']},
        );
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(decoration: c.backgroundGradient),
          ),
          // Угловые элементы
          Positioned(top: 28, left: 20, child: _buildCorner(top: true, left: true)),
          Positioned(top: 28, right: 20, child: _buildCorner(top: true, left: false)),
          Positioned(bottom: 28, left: 20, child: _buildCorner(top: false, left: true)),
          Positioned(bottom: 28, right: 20, child: _buildCorner(top: false, left: false)),
          // Центральный контент
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Text(
                        'YANIKOV',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 14,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: Offset.zero,
                            ),
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _taglineFade,
                  child: Column(
                    children: [
                      Container(
                        height: 1,
                        width: 60,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        context.l10n('modern_collection'),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 5,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    const color = Color(0xFF1A1A1A);
    const size = 48.0;
    const len = 20.0;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(top: top, left: left, color: color, len: len),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;
  final Color color;
  final double len;

  _CornerPainter({required this.top, required this.left, required this.color, required this.len});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    if (top && left) {
      canvas.drawLine(Offset.zero, Offset(len, 0), paint);
      canvas.drawLine(Offset.zero, Offset(0, len), paint);
    } else if (top && !left) {
      canvas.drawLine(Offset(size.width - len, 0), Offset(size.width, 0), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    } else if (!top && left) {
      canvas.drawLine(Offset(0, size.height - len), Offset(0, size.height), paint);
      canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    } else {
      canvas.drawLine(Offset(size.width - len, size.height), Offset(size.width, size.height), paint);
      canvas.drawLine(Offset(size.width, size.height - len), Offset(size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

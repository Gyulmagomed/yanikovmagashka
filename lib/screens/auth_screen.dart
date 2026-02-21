import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/services/auth_service.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _regName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPassword = TextEditingController();
  final _regConfirmPassword = TextEditingController();

  bool _obscureLogin = true;
  bool _obscureReg = true;
  bool _obscureRegConfirm = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPassword.dispose();
    _regConfirmPassword.dispose();
    super.dispose();
  }

  Widget _buildPanel(BuildContext context, {required Widget child, double borderRadius = 20}) {
    final c = AppTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: c.surfaceElevated,
        border: Border.all(color: c.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField(BuildContext context, {
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    final c = AppTheme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.outfit(
        color: c.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: c.textSecondary, fontWeight: FontWeight.w400),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: c.textSecondary, size: 22)
            : null,
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: c.textSecondary,
                  size: 22,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.borderBright, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        filled: true,
        fillColor: c.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: c.backgroundGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo / Brand
                Text(
                  'YANIKOV',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 16,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 2,
                  color: c.accent,
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n('brand_text'),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 5,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                // Tabs
                _buildPanel(context,
                  borderRadius: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: c.accent,
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: c.background,
                      unselectedLabelColor: c.textSecondary,
                      labelStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                      unselectedLabelStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      tabs: [
                        Tab(text: context.l10n('login_tab')),
                        Tab(text: context.l10n('register_tab')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 420,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoginForm(),
                      _buildRegisterForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return _buildPanel(context,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(context,
                label: context.l10n('email'),
                controller: _loginEmail,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                validator: (v) {
                  if (v == null || v.isEmpty) return context.l10n('enter_email');
                  if (!v.contains('@')) return context.l10n('invalid_email');
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(context,
                label: context.l10n('password'),
                controller: _loginPassword,
                obscure: _obscureLogin,
                onToggleObscure: () => setState(() => _obscureLogin = !_obscureLogin),
                prefixIcon: Icons.lock_outline_rounded,
                validator: (v) {
                  if (v == null || v.isEmpty) return context.l10n('enter_password');
                  return null;
                },
              ),
              const SizedBox(height: 48),
              _buildPrimaryButton(context,
                label: context.l10n('login_btn'),
                onPressed: () async {
                  if (_loginFormKey.currentState?.validate() != true) return;
                  final user = await AuthService.login(
                    email: _loginEmail.text,
                    password: _loginPassword.text,
                  );
                  if (!mounted) return;
                  if (user != null) {
                    Navigator.of(context).pushReplacementNamed(
                      '/home',
                      arguments: {'userName': user['name']},
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n('wrong_credentials')),
                        backgroundColor: Colors.red.shade800,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return _buildPanel(context,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _registerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(context,
                label: context.l10n('name'),
                controller: _regName,
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) {
                  if (v == null || v.isEmpty) return context.l10n('enter_name');
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(context,
                label: context.l10n('email'),
                controller: _regEmail,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                validator: (v) {
                  if (v == null || v.isEmpty) return context.l10n('enter_email');
                  if (!v.contains('@')) return context.l10n('invalid_email');
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(context,
                label: context.l10n('password'),
                controller: _regPassword,
                obscure: _obscureReg,
                onToggleObscure: () => setState(() => _obscureReg = !_obscureReg),
                prefixIcon: Icons.lock_outline_rounded,
                validator: (v) {
                  if (v == null || v.isEmpty) return context.l10n('enter_password');
                  if ((v.length) < 6) return context.l10n('min_6_chars');
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(context,
                label: context.l10n('confirm_password'),
                controller: _regConfirmPassword,
                obscure: _obscureRegConfirm,
                onToggleObscure: () => setState(() => _obscureRegConfirm = !_obscureRegConfirm),
                prefixIcon: Icons.lock_outline_rounded,
                validator: (v) {
                  if (v != _regPassword.text) return context.l10n('passwords_match');
                  return null;
                },
              ),
              const SizedBox(height: 28),
              _buildPrimaryButton(context,
                label: context.l10n('register_btn'),
                onPressed: () async {
                  if (_registerFormKey.currentState?.validate() != true) return;
                  try {
                    await AuthService.register(
                      name: _regName.text.trim(),
                      email: _regEmail.text,
                      password: _regPassword.text,
                    );
                    if (!mounted) return;
                    final user = await AuthService.getCurrentUser();
                    if (!mounted) return;
                    Navigator.of(context).pushReplacementNamed(
                      '/home',
                      arguments: {'userName': user?['name'] ?? _regName.text.trim()},
                    );
                  } on AuthException catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message == 'User already registered'
                            ? context.l10n('email_exists')
                            : e.message),
                        backgroundColor: Colors.red.shade800,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    final c = AppTheme.of(context);
    return Material(
      color: c.accent,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: c.background,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

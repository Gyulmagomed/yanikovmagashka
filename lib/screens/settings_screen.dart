import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telemost12_app/screens/addresses_screen.dart';
import 'package:telemost12_app/screens/favorites_screen.dart';
import 'package:telemost12_app/screens/orders_screen.dart';
import 'package:telemost12_app/services/biometric_service.dart';
import 'package:telemost12_app/services/locale_service.dart';
import 'package:telemost12_app/services/currency_service.dart';
import 'package:telemost12_app/screens/saved_cards_screen.dart';
import 'package:telemost12_app/screens/search_screen.dart';
import 'package:telemost12_app/screens/comparison_screen.dart';
import 'package:telemost12_app/screens/devices_screen.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';
import 'package:telemost12_app/services/favorites_service.dart';
import 'package:telemost12_app/services/recently_viewed_service.dart';
import 'package:telemost12_app/services/search_history_service.dart';
import 'package:telemost12_app/services/sessions_service.dart';
import 'package:telemost12_app/services/realtime_sync_service.dart';
import 'package:telemost12_app/services/auth_service.dart';
import 'package:telemost12_app/services/theme_service.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  bool _biometricAvailable = false;
  static const _keySound = 'yanikov_sound_enabled';
  static const _keyNotifications = 'yanikov_notifications_enabled';
  static const _keyHaptic = 'yanikov_haptic_enabled';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await BiometricService.instance.isAvailable;
    if (mounted) setState(() => _biometricAvailable = available);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool(_keySound) ?? true;
      _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
      _hapticEnabled = prefs.getBool(_keyHaptic) ?? true;
    });
  }

  Future<void> _setSound(bool v) async {
    setState(() => _soundEnabled = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, v);
  }

  Future<void> _setNotifications(bool v) async {
    setState(() => _notificationsEnabled = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, v);
  }

  Future<void> _setHaptic(bool v) async {
    setState(() => _hapticEnabled = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHaptic, v);
  }

  String _themeModeTitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.dark:
        return 'Тёмная';
      case ThemeMode.system:
        return 'Как в системе';
    }
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final c = AppTheme.of(context);
    final mode = await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Тема', style: GoogleFonts.outfit(color: c.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values
              .map((m) => ListTile(
                    title: Text(_themeModeTitle(m), style: GoogleFonts.outfit(color: c.textPrimary)),
                    onTap: () => Navigator.pop(ctx, m),
                  ))
              .toList(),
        ),
      ),
    );
    if (mode != null) await ThemeService.instance.setThemeMode(mode);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      context.l10n('settings'),
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    buildGlassPanel(context,
                      borderRadius: 16,
                      child: SwitchListTile(
                        value: _notificationsEnabled,
                        onChanged: _setNotifications,
                        activeTrackColor: c.accent,
                        title: Text(
                          context.l10n('notifications'),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: c.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          context.l10n('notifications_subtitle'),
                          style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildGlassPanel(context,
                      borderRadius: 16,
                      child: SwitchListTile(
                        value: _soundEnabled,
                        onChanged: _setSound,
                        activeTrackColor: c.accent,
                        title: Text(
                          context.l10n('sound'),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: c.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          context.l10n('sound_subtitle'),
                          style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildGlassPanel(context,
                      borderRadius: 16,
                      child: SwitchListTile(
                        value: _hapticEnabled,
                        onChanged: _setHaptic,
                        activeTrackColor: c.accent,
                        title: Text(
                          context.l10n('haptic'),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: c.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          context.l10n('haptic_subtitle'),
                          style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                      listenable: ThemeService.instance,
                      builder: (context, _) => buildGlassPanel(context,
                        borderRadius: 16,
                        child: ListTile(
                          onTap: () => _showThemePicker(context),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.palette_outlined, color: c.textPrimary),
                          ),
                          title: Text(
                            'Тема',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: c.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            _themeModeTitle(ThemeService.instance.themeMode),
                            style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded, color: c.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                      listenable: LocaleService.instance,
                      builder: (context, _) => buildGlassPanel(context,
                        borderRadius: 16,
                        child: ListTile(
                          onTap: () => _showLanguagePicker(context),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.language_rounded, color: c.textPrimary),
                          ),
                          title: Text(
                            context.l10n('language'),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: c.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            LocaleService.localeNames[LocaleService.instance.localeCode] ?? 'Русский',
                            style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded, color: c.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                      listenable: CurrencyService.instance,
                      builder: (context, _) => buildGlassPanel(context,
                        borderRadius: 16,
                        child: ListTile(
                          onTap: () => _showCurrencyPicker(context),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.attach_money_rounded, color: c.textPrimary),
                          ),
                          title: Text(
                            context.l10n('currency'),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: c.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            CurrencyService.currencyNames[CurrencyService.instance.currencyCode] ?? '₽',
                            style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded, color: c.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                      listenable: BiometricService.instance,
                      builder: (context, _) => _biometricAvailable
                          ? _buildBiometricSettings(context)
                          : _settingsTileComingSoon(context,
                              Icons.fingerprint_rounded,
                              context.l10n('biometric'),
                              context.l10n('biometric_unavailable'),
                              context.l10n('biometric_unavailable_message'),
                            ),
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(context,
                      Icons.credit_card_rounded,
                      context.l10n('saved_cards'),
                      context.l10n('saved_cards_subtitle'),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavedCardsScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _settingsTileComingSoon(context,
                      Icons.campaign_outlined,
                      'Подписка на рассылку',
                      'Новости, акции и скидки на почту',
                    ),
                    const SizedBox(height: 12),
                    _settingsTileComingSoon(context,
                      Icons.card_giftcard_rounded,
                      'Реферальная программа',
                      'Приглашайте друзей и получайте бонусы',
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(context,
                      Icons.search_rounded,
                      context.l10n('search_history'),
                      context.l10n('search_history_subtitle'),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(context,
                      Icons.compare_arrows_rounded,
                      context.l10n('comparison'),
                      context.l10n('comparison_subtitle'),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ComparisonScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                      listenable: SessionsService.instance,
                      builder: (_, __) => _settingsTile(context,
                        Icons.phone_android_rounded,
                        context.l10n('devices'),
                        '${SessionsService.instance.sessions.length} ${context.l10n('devices_count')}',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DevicesScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildGlassPanel(context,
                      borderRadius: 16,
                      child: ListTile(
                        onTap: () => _confirmDeleteAccount(context),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.person_off_rounded, color: Colors.red.shade400),
                        ),
                        title: Text(
                          'Удаление аккаунта',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red.shade400,
                          ),
                        ),
                        subtitle: Text(
                          'Безвозвратно удалить аккаунт и все данные',
                          style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, color: c.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle(context, context.l10n('quick_links')),
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: FavoritesService.instance,
                      builder: (context, _) => _settingsTile(context,
                        Icons.favorite_outline_rounded,
                        context.l10n('favorites'),
                        '${FavoritesService.instance.ids.length} ${context.l10n('favorites_count')}',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(context,
                      Icons.receipt_long_outlined,
                      context.l10n('orders'),
                      context.l10n('orders_subtitle'),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(context,
                      Icons.location_on_outlined,
                      context.l10n('addresses'),
                      context.l10n('addresses_subtitle'),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddressesScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle(context, context.l10n('data')),
                    const SizedBox(height: 8),
                    _settingsTile(context,
                      Icons.delete_outline_rounded,
                      context.l10n('clear_cache'),
                      context.l10n('clear_cache_subtitle'),
                      () => _clearCache(context),
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(context,
                      Icons.history_rounded,
                      context.l10n('clear_recent'),
                      context.l10n('clear_recent_subtitle'),
                      () => _clearRecentlyViewed(context),
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(context,
                      Icons.search_rounded,
                      context.l10n('clear_search_history'),
                      context.l10n('search_history_subtitle'),
                      () => _clearSearchHistory(context),
                    ),
                    const SizedBox(height: 20),
                    _settingsTile(context,
                      Icons.help_outline_rounded,
                      context.l10n('help'),
                      context.l10n('help_subtitle'),
                      () => _showHelp(context),
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(context,
                      Icons.privacy_tip_outlined,
                      context.l10n('privacy'),
                      context.l10n('privacy_subtitle'),
                      () => _showPolicy(context),
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(context,
                      Icons.description_outlined,
                      context.l10n('terms'),
                      context.l10n('terms_subtitle'),
                      () => _showTerms(context),
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(context,
                      Icons.share_outlined,
                      context.l10n('share'),
                      context.l10n('share_subtitle'),
                      () => Share.share(
                        'Скачай приложение YANIKOV — современная одежда и аксессуары. https://yanikov.ru',
                        subject: 'YANIKOV',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(context,
                      Icons.star_outline_rounded,
                      context.l10n('rate'),
                      context.l10n('rate_subtitle'),
                      () => _openStore(context),
                    ),
                    const SizedBox(height: 12),
                    buildGlassPanel(context,
                      borderRadius: 16,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.info_outline_rounded, color: c.textPrimary),
                        ),
                        title: Text(
                          context.l10n('about'),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: c.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'YANIKOV 1.0',
                          style: GoogleFonts.outfit(fontSize: 14, color: c.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildGlassPanel(context,
                      borderRadius: 16,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.mail_outline_rounded, color: c.textPrimary),
                        ),
                        title: Text(
                          context.l10n('contact'),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: c.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'support@yanikov.ru',
                          style: GoogleFonts.outfit(fontSize: 14, color: c.textSecondary),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, color: c.textSecondary),
                        onTap: () async {
                          try {
                            await launchUrl(Uri.parse('mailto:support@yanikov.ru'));
                          } catch (_) {}
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricSettings(BuildContext context) {
    final c = AppTheme.of(context);
    final service = BiometricService.instance;
    return buildGlassPanel(context,
      borderRadius: 16,
      child: SwitchListTile(
        value: service.enabled,
        onChanged: (v) async {
          await service.setEnabled(v);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  v ? context.l10n('biometric_on') : context.l10n('biometric_off'),
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
                backgroundColor: c.surfaceElevated,
              ),
            );
          }
        },
        activeTrackColor: c.accent,
        title: Text(
          context.l10n('biometric'),
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: c.textPrimary,
          ),
        ),
        subtitle: Text(
          context.l10n('biometric_subtitle'),
          style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final c = AppTheme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n('language'),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ...LocaleService.supportedLocales.map((locale) {
              final isSelected = LocaleService.instance.localeCode == locale.languageCode;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: isSelected ? c.accent : c.textSecondary,
                  size: 24,
                ),
                title: Text(
                  LocaleService.localeNames[locale.languageCode] ?? locale.languageCode,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: c.textPrimary,
                  ),
                ),
                onTap: () async {
                  await LocaleService.instance.setLocale(locale);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final c = AppTheme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n('currency'),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ...CurrencyService.supportedCurrencies.map((code) {
              final isSelected = CurrencyService.instance.currencyCode == code;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: isSelected ? c.accent : c.textSecondary,
                  size: 24,
                ),
                title: Text(
                  CurrencyService.currencyNames[code] ?? code,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: c.textPrimary,
                  ),
                ),
                onTap: () async {
                  await CurrencyService.instance.setCurrency(code);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String title, [String? message]) {
    final c = AppTheme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.construction_rounded, size: 48, color: c.textSecondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? context.l10n('feature_coming'),
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: c.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _settingsTileComingSoon(BuildContext context, IconData icon, String title, String subtitle, [String? onTapMessage]) {
    final c = AppTheme.of(context);
    return buildGlassPanel(context,
      borderRadius: 16,
      child: ListTile(
        onTap: () => _showComingSoon(context, title, onTapMessage),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: c.textSecondary),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: c.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n('soon'),
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: c.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: c.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    final c = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: c.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final c = AppTheme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Удаление аккаунта',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: c.textPrimary),
        ),
        content: Text(
          'Вы уверены? Аккаунт и все данные (заказы, избранное, корзина, адреса) будут удалены безвозвратно. Это действие нельзя отменить.',
          style: GoogleFonts.outfit(fontSize: 15, color: c.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n('cancel'), style: GoogleFonts.outfit(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Удалить', style: GoogleFonts.outfit(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    try {
      RealtimeSyncService.instance.unsubscribe();
      await SessionsService.instance.resetForLogout();
      await AuthService.deleteAccount();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _clearCache(BuildContext context) async {
    final c = AppTheme.of(context);
    try {
      await DefaultCacheManager().emptyCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n('cache_cleared'),
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            backgroundColor: c.surfaceElevated,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n('cache_clear_failed'),
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  Future<void> _clearRecentlyViewed(BuildContext context) async {
    final c = AppTheme.of(context);
    await RecentlyViewedService.instance.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n('recent_cleared'),
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: c.surfaceElevated,
        ),
      );
    }
  }

  Future<void> _clearSearchHistory(BuildContext context) async {
    final c = AppTheme.of(context);
    await SearchHistoryService.instance.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n('search_history_cleared'),
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: c.surfaceElevated,
        ),
      );
    }
  }

  Widget _settingsTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    final c = AppTheme.of(context);
    return buildGlassPanel(context,
      borderRadius: 16,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: c.textPrimary),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: c.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: c.textSecondary),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    final c = AppTheme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n('help'),
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _helpItem(context, 'Как оформить заказ?', 'Добавьте товары в корзину, нажмите «Оформить заказ» и заполните адрес доставки.'),
            _helpItem(context, 'Как отследить заказ?', 'Перейдите в «Мои заказы» в профиле — там отображаются все ваши заказы.'),
            _helpItem(context, 'Бесплатная доставка?', 'Да, при заказе от 5 000 ₽ доставка бесплатная.'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _helpItem(BuildContext context, String q, String a) {
    final c = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            a,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showPolicy(BuildContext context) {
    _showInfoSheet(context, 'Политика конфиденциальности', '''
Мы собираем только необходимые данные для работы приложения:
• Имя и email — для учёта и связи
• Адреса доставки — для отправки заказов
• История заказов — для вашего удобства

Ваши данные не передаются третьим лицам и хранятся в защищённом виде.
''');
  }

  Future<void> _openStore(BuildContext context) async {
    final c = AppTheme.of(context);
    try {
      final uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.example.telemost12_app',
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n('app_not_in_store'),
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            backgroundColor: c.surfaceElevated,
          ),
        );
      }
    }
  }

  void _showTerms(BuildContext context) {
    _showInfoSheet(context, 'Условия использования', '''
Используя приложение YANIKOV, вы соглашаетесь:
• С правилами оформления и оплаты заказов
• С условиями доставки и возврата
• С обработкой персональных данных

По вопросам: support@yanikov.ru
''');
  }

  void _showInfoSheet(BuildContext context, String title, String text) {
    final c = AppTheme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: c.border),
          ),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                text.trim(),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: c.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

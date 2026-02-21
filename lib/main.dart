import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/supabase_config.dart';
import 'package:telemost12_app/services/biometric_service.dart';
import 'package:telemost12_app/services/locale_service.dart';
import 'package:telemost12_app/services/currency_service.dart';
import 'package:telemost12_app/services/sessions_service.dart';
import 'package:telemost12_app/services/theme_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/biometric_lock_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      authOptions: FlutterAuthClientOptions(
        detectSessionInUri: !kIsWeb,
      ),
    );
  }
  await BiometricService.instance.load();
  await LocaleService.instance.load();
  await CurrencyService.instance.load();
  await ThemeService.instance.load();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: AppTheme.border,
    ),
  );
  runApp(const YanikovApp());
}

class YanikovApp extends StatefulWidget {
  const YanikovApp({super.key});

  @override
  State<YanikovApp> createState() => _YanikovAppState();
}

class _YanikovAppState extends State<YanikovApp> with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _lockOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      SessionsService.instance.addCurrentSession();
      if (BiometricService.instance.enabled && state == AppLifecycleState.paused) {
        _lockOnResume = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_lockOnResume && BiometricService.instance.enabled) {
        _lockOnResume = false;
        setState(() => _isLocked = true);
      }
    }
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([LocaleService.instance, CurrencyService.instance, ThemeService.instance]),
      builder: (context, _) {
        final isDark = ThemeService.instance.themeMode == ThemeMode.dark ||
            (ThemeService.instance.themeMode == ThemeMode.system &&
                WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: isDark ? AppTheme.background : AppThemeColors.light.background,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: isDark ? AppTheme.border : AppThemeColors.light.border,
          ),
        );
        return MaterialApp(
        title: 'YANIKOV',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeService.instance.themeMode,
        locale: LocaleService.instance.locale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocaleService.supportedLocales,
        navigatorKey: navigatorKey,
        initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/auth': (context) => const AuthScreen(),
        '/lock': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final userName = args?['userName'] as String?;
          return BiometricLockScreen(
            userName: userName,
            onUnlocked: () {
              Navigator.of(context).pushReplacementNamed(
                '/home',
                arguments: {'userName': userName},
              );
            },
          );
        },
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return HomeScreen(userName: args?['userName'] as String?);
        },
      },
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            if (_isLocked)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: BiometricLockScreen(onUnlocked: _onUnlocked),
                ),
              ),
          ],
        );
      },
        );
      },
    );
  }
}

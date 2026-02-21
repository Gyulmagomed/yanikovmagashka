import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:telemost12_app/services/sessions_service.dart';
import 'package:telemost12_app/services/realtime_sync_service.dart';
import 'package:telemost12_app/services/auth_service.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await SessionsService.instance.load();
    await SessionsService.instance.addCurrentSession();
  }

  Future<void> _confirmRemoveSession(BuildContext context, String sessionId, String deviceName) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n('devices')),
        content: Text(
          'Выгнать устройство $deviceName?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Выгнать', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await SessionsService.instance.removeSession(sessionId);
    }
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
                      context.l10n('devices'),
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
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: c.accent,
                  child: ListenableBuilder(
                    listenable: SessionsService.instance,
                    builder: (context, _) {
                      final sessions = SessionsService.instance.sessions;
                      if (sessions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone_android_rounded, size: 64, color: c.textSecondary),
                              const SizedBox(height: 20),
                              Text(
                                context.l10n('active_devices'),
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: c.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        children: [
                          ...sessions.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: buildGlassPanel(context,
                              borderRadius: 16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: s.isCurrent ? null : () => _confirmRemoveSession(context, s.id, s.deviceName),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: s.isCurrent ? c.accent.withValues(alpha: 0.2) : c.surface,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            s.platform == 'iOS' ? Icons.phone_iphone_rounded : Icons.phone_android_rounded,
                                            color: s.isCurrent ? c.accent : c.textSecondary,
                                            size: 26,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      s.deviceName,
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: c.textPrimary,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (s.isCurrent)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: c.accent.withValues(alpha: 0.2),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        context.l10n('this_device'),
                                                        style: GoogleFonts.outfit(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                          color: c.accent,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: s.isOnline ? Colors.green : c.textSecondary,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    s.isOnline ? context.l10n('online') : context.l10n('offline'),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 12,
                                                      color: s.isOnline ? Colors.green : c.textSecondary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '• ${s.lastActiveFormatted((k) => context.l10n(k))}',
                                                    style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!s.isCurrent)
                                          Icon(Icons.logout_rounded, color: c.textSecondary, size: 22),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                          const SizedBox(height: 8),
                          buildGlassPanel(context,
                            borderRadius: 16,
                            child: ListTile(
                              onTap: () async {
                                await SessionsService.instance.terminateAllOther();
                                RealtimeSyncService.instance.unsubscribe();
                                await SessionsService.instance.resetForLogout();
                                await AuthService.logout();
                                if (!context.mounted) return;
                                Navigator.of(context).pushNamedAndRemoveUntil('/auth', (r) => false);
                              },
                              leading: Icon(Icons.logout_rounded, color: c.textSecondary),
                              title: Text(
                                context.l10n('terminate_all_other'),
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

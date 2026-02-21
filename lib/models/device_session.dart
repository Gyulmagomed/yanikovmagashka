class DeviceSession {
  const DeviceSession({
    required this.id,
    required this.deviceName,
    required this.platform,
    required this.lastActive,
    this.isCurrent = false,
  });

  final String id;
  final String deviceName;
  final String platform; // Android, iOS
  final DateTime lastActive;
  final bool isCurrent;

  /// Онлайн, если активность была менее 2 минут назад
  bool get isOnline =>
      DateTime.now().difference(lastActive).inMinutes < 2;

  String lastActiveFormatted(String Function(String) l10n) {
    final now = DateTime.now();
    final diff = now.difference(lastActive);
    if (diff.inMinutes < 1) return l10n('just_now');
    if (diff.inMinutes < 60) return l10n('min_ago').replaceAll('{n}', '${diff.inMinutes}');
    if (diff.inHours < 24) return l10n('hours_ago').replaceAll('{n}', '${diff.inHours}');
    if (diff.inDays < 7) return l10n('days_ago').replaceAll('{n}', '${diff.inDays}');
    return '${lastActive.day.toString().padLeft(2, '0')}.${lastActive.month.toString().padLeft(2, '0')}.${lastActive.year}';
  }
}

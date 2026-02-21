class Order {
  const Order({
    required this.id,
    required this.date,
    required this.itemsSummary,
    required this.total,
    required this.totalRubles,
    this.addressLabel,
  });

  final String id;
  final DateTime date;
  final String itemsSummary;
  final String total;
  /// Сумма в рублях (для расчёта totalSpent)
  final int totalRubles;
  final String? addressLabel;

  String get dateFormatted {
    final d = date;
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}

class SavedCard {
  const SavedCard({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    this.holderName,
  });

  final String id;
  final String last4;
  final String brand; // Visa, Mastercard, Mir
  final int expiryMonth;
  final int expiryYear;
  final String? holderName;

  String get maskedNumber => '•••• •••• •••• $last4';
  String get expiryFormatted =>
      '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}';
}

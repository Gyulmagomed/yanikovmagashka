class Address {
  const Address({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.phone,
  });

  final String id;
  final String label;
  final String street;
  final String city;
  final String phone;

  String get full => '$street, $city';
}

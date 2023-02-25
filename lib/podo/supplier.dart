class Supplier {
  Supplier({
    required this.name,
    this.reference = '',
    this.address = '',
    this.postalCode = '',
    this.city = '',
    this.activityType = '',
    this.contactName = '',
    this.email = '',
    this.phone = '',
  });

  final String name;
  final String reference;
  final String address;
  final String postalCode;
  final String city;
  final String activityType;
  final String contactName;
  final String email;
  final String phone;

  @override
  String toString() {
    return '{name: $name, reference: $reference, address: $address, postalCode: $postalCode, city: $city, activityType: $activityType, contactName: $contactName, email: $email, phone: $phone}';
  }
}

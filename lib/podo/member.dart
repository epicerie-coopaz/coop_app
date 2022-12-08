class Member {
  Member({
    required this.name,
    required this.email,
    required this.phone,
    this.score = 0.0,
  });

  final String name;
  final String email;
  final String phone;
  final double score;

  @override
  String toString() {
    return '{name: $name, email: $email, phone: $phone, score: $score}';
  }
}

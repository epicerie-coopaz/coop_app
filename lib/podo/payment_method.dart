enum PaymentMethod {
  card,
  cheque,
  transfer;

  String get asString {
    switch (this) {
      case PaymentMethod.card:
        return 'CB';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.transfer:
        return 'Virement';
    }
  }
}

enum Units {
  kg,
  liter,
  piece;

  String get unitAsString {
    switch (this) {
      case Units.kg:
        return 'Kg';
      case Units.liter:
        return 'Litre';
      case Units.piece:
        return 'Pièce';
    }
  }
}

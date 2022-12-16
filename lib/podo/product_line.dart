class ProductLine {
  ProductLine({
    this.name,
    this.qty,
    this.unitPrice,
  });

  String? name;
  String? qty;
  String? unitPrice;

  @override
  String toString() {
    return '{name: $name, qty: $qty, unitPrice: $unitPrice,}';
  }
}

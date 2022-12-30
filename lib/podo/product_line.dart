class ProductLine {
  ProductLine({
    this.name,
    this.qty,
    this.unitPrice,
    this.unit,
  });

  String? name;
  String? qty;
  String? unitPrice;
  String? unit;

  @override
  String toString() {
    return '{name: $name, qty: $qty, unitPrice: $unitPrice, unit: $unit,}';
  }
}

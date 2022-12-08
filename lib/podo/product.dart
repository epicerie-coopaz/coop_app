import 'package:coopaz_app/podo/units.dart';

class Product {
  Product({
    required this.designation,
    required this.name,
    required this.family,
    required this.supplier,
    required this.unit,
    this.barreCode = '',
    required this.reference,
    this.buyer = '',
    required this.price,
    required this.stock,
  });

  final String designation;
  final String name;
  final String family;
  final String supplier;
  final Units unit;
  final String barreCode;
  final String reference;
  final String buyer;
  final double price;
  final double stock;

  @override
  String toString() {
    return '{name: $name, family: $family, supplier: $supplier, unit: $unit, barreCode: $barreCode, reference: $reference, buyer: $buyer, price: $price, stock: $stock, }';
  }
}

import 'package:coopaz_app/podo/product.dart';

class CartItem {
  CartItem({
    this.product,
    this.qty,
  });

  Product? product;
  String? qty;

  @override
  String toString() {
    return '{product: $product, qty: $qty,}';
  }
}

import 'menu_item.dart';

class CartItem {
  final MenuItem item;
  final int quantity;
  final String size;
  final String milkType;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.size = 'Medium',
    this.milkType = 'Whole Milk',
  });

  CartItem copyWith({
    MenuItem? item,
    int? quantity,
    String? size,
    String? milkType,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      milkType: milkType ?? this.milkType,
    );
  }

  static const Map<String, double> _sizeMultipliers = {
    'Small': 0.75,
    'Medium': 1.0,
    'Large': 1.35,
  };

  double get totalPrice =>
      item.price * quantity * (_sizeMultipliers[size] ?? 1.0);
}

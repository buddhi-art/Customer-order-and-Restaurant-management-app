class InventoryItem {
  final String id;
  final String name;
  final String category;
  final double currentStock;
  final double minStock;
  final String unit;
  final double costPerUnit;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    required this.costPerUnit,
  });

  bool get isLow => currentStock <= minStock;

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? currentStock,
    double? minStock,
    String? unit,
    double? costPerUnit,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      costPerUnit: costPerUnit ?? this.costPerUnit,
    );
  }
}

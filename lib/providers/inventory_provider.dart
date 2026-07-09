import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/inventory_repository.dart';
import '../models/inventory_item.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => InventoryRepository(),
);

class InventoryNotifier extends Notifier<List<InventoryItem>> {
  StreamSubscription<List<Map<String, dynamic>>>? _inventorySubscription;
  late final InventoryRepository _repo;

  @override
  List<InventoryItem> build() {
    _repo = ref.read(inventoryRepositoryProvider);
    _listenToInventory();
    ref.onDispose(() => _inventorySubscription?.cancel());
    return _mockInventory;
  }

  void _listenToInventory() {
    try {
      _inventorySubscription = _repo.stream().listen(
        (List<Map<String, dynamic>> data) {
          final loaded = data
              .map<InventoryItem>(InventoryRepository.parseItem)
              .toList();
          if (loaded.isNotEmpty) state = loaded;
        },
        onError: (error) {
          debugPrint('Inventory stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Inventory stream not available, using mock data: $e');
    }
  }

  int get lowStockCount => state.where((item) => item.isLow).length;

  Set<String> get categories => state.map((e) => e.category).toSet();

  List<InventoryItem> itemsByCategory(String category) =>
      state.where((e) => e.category == category).toList();

  Future<void> addItem(InventoryItem item) async {
    try {
      await _repo.insert(item);
    } catch (e) {
      state = [...state, item];
      debugPrint('Added item locally: $e');
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    final index = state.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = item;
      state = updated;
    }
    try {
      await _repo.updateFields(item);
    } catch (e) {
      debugPrint('Error updating inventory: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    state = state.where((e) => e.id != id).toList();
    try {
      await _repo.delete(id);
    } catch (e) {
      debugPrint('Error deleting inventory item: $e');
    }
  }

  Future<void> adjustStock(String id, double delta) async {
    final index = state.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final item = state[index];
    final newStock = (item.currentStock + delta).clamp(0.0, double.infinity);
    final updated = item.copyWith(currentStock: newStock);
    final list = [...state];
    list[index] = updated;
    state = list;

    try {
      await _repo.setStock(id, newStock);
    } catch (e) {
      debugPrint('Error adjusting stock: $e');
    }
  }

  static final List<InventoryItem> _mockInventory = [
    const InventoryItem(
      id: 'inv-1',
      name: 'Coffee Beans - Arabica',
      category: 'Coffee',
      currentStock: 25,
      minStock: 10,
      unit: 'kg',
      costPerUnit: 12.50,
    ),
    const InventoryItem(
      id: 'inv-2',
      name: 'Coffee Beans - Robusta',
      category: 'Coffee',
      currentStock: 8,
      minStock: 10,
      unit: 'kg',
      costPerUnit: 9.75,
    ),
    const InventoryItem(
      id: 'inv-3',
      name: 'Milk - Whole',
      category: 'Dairy',
      currentStock: 40,
      minStock: 20,
      unit: 'L',
      costPerUnit: 1.20,
    ),
    const InventoryItem(
      id: 'inv-4',
      name: 'Milk - Oat',
      category: 'Dairy',
      currentStock: 12,
      minStock: 10,
      unit: 'L',
      costPerUnit: 2.50,
    ),
    const InventoryItem(
      id: 'inv-5',
      name: 'Sugar - Brown',
      category: 'Sweeteners',
      currentStock: 5,
      minStock: 5,
      unit: 'kg',
      costPerUnit: 3.00,
    ),
    const InventoryItem(
      id: 'inv-6',
      name: 'Sugar - White',
      category: 'Sweeteners',
      currentStock: 15,
      minStock: 8,
      unit: 'kg',
      costPerUnit: 2.00,
    ),
    const InventoryItem(
      id: 'inv-7',
      name: 'Chocolate Syrup',
      category: 'Syrups',
      currentStock: 3,
      minStock: 5,
      unit: 'L',
      costPerUnit: 8.00,
    ),
    const InventoryItem(
      id: 'inv-8',
      name: 'Vanilla Syrup',
      category: 'Syrups',
      currentStock: 7,
      minStock: 5,
      unit: 'L',
      costPerUnit: 7.50,
    ),
    const InventoryItem(
      id: 'inv-9',
      name: 'Paper Cups - Small',
      category: 'Packaging',
      currentStock: 200,
      minStock: 100,
      unit: 'pcs',
      costPerUnit: 0.15,
    ),
    const InventoryItem(
      id: 'inv-10',
      name: 'Paper Cups - Large',
      category: 'Packaging',
      currentStock: 80,
      minStock: 100,
      unit: 'pcs',
      costPerUnit: 0.20,
    ),
    const InventoryItem(
      id: 'inv-11',
      name: 'Napkins',
      category: 'Packaging',
      currentStock: 500,
      minStock: 200,
      unit: 'pcs',
      costPerUnit: 0.05,
    ),
    const InventoryItem(
      id: 'inv-12',
      name: 'Cinnamon Powder',
      category: 'Toppings',
      currentStock: 2,
      minStock: 3,
      unit: 'kg',
      costPerUnit: 15.00,
    ),
  ];
}

final inventoryProvider =
    NotifierProvider<InventoryNotifier, List<InventoryItem>>(
      InventoryNotifier.new,
    );

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
    // Start empty; the realtime stream populates real data. Do NOT seed with
    // mock inventory — showing fake stock during a backend outage is dangerous
    // for an admin making reorder decisions. (Issue 17)
    return const [];
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
    // Optimistically add, then roll back if the insert fails — otherwise a
    // failed insert would leave a phantom item that never persisted.
    state = [...state, item];
    try {
      await _repo.insert(item);
    } catch (e) {
      state = state.where((x) => x.id != item.id).toList();
      debugPrint('Failed to add inventory item, rolled back: $e');
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
      // Apply the change as an atomic delta in Postgres so concurrent
      // adjustments don't clobber each other (read-modify-write on cached
      // state loses updates). The realtime stream reconciles the true value.
      await _repo.adjustStock(id, delta);
    } catch (e) {
      debugPrint('Error adjusting stock: $e');
    }
  }

}

final inventoryProvider =
    NotifierProvider<InventoryNotifier, List<InventoryItem>>(
      InventoryNotifier.new,
    );

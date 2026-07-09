import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/cart_repository.dart';
import '../data/repositories/menu_repository.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepository(),
);

final menuRepositoryProviderForCart = Provider<MenuRepository>(
  (ref) => MenuRepository(),
);

class CartNotifier extends Notifier<List<CartItem>> {
  late final CartRepository _cartRepo;
  late final MenuRepository _menuRepo;

  @override
  List<CartItem> build() {
    _cartRepo = ref.read(cartRepositoryProvider);
    _menuRepo = ref.read(menuRepositoryProviderForCart);
    // Kick off async hydration; state starts empty until load completes.
    _loadFromPrefs();
    return <CartItem>[];
  }

  // ── Persistence ──

  Future<void> _saveToPrefs() async {
    try {
      await _cartRepo.save(state);
    } catch (e) {
      debugPrint('Error saving cart to prefs: $e');
    }
  }

  Future<void> _loadFromPrefs() async {
    // 1. Check the saved-at timestamp. If it's older than 2h OR missing,
    //    discard the persisted cart and return.
    final savedAt = await _cartRepo.readSavedAt();
    final isStale =
        savedAt == null ||
        DateTime.now().difference(savedAt) > CartRepository.maxAge;
    if (isStale) {
      await _cartRepo.clear();
      return;
    }

    // 2. Read the skeleton items.
    final skeleton = await _cartRepo.readSkeleton();
    if (skeleton == null || skeleton.isEmpty) return;

    // 3. Re-hydrate the full MenuItem objects from Supabase.
    try {
      final ids = skeleton.map((i) => i.item.id).toList();
      final fresh = await _menuRepo.fetchByIds(ids);
      final byId = {for (final m in fresh) m.id: m};

      final rehydrated = skeleton
          .map((i) => i.copyWith(item: byId[i.item.id] ?? i.item))
          .toList();

      state = rehydrated;
    } catch (e) {
      // If the network is down, fall back to the skeleton (so the user
      // doesn't lose their cart offline) and try to save it back.
      debugPrint('Error re-hydrating cart items: $e');
      state = skeleton;
    }
  }

  // ── Mutations ──

  void addItem(
    MenuItem item,
    int quantity,
    String size, {
    String milkType = 'Whole Milk',
  }) {
    final index = state.indexWhere(
      (element) =>
          element.item.id == item.id &&
          element.size == size &&
          element.milkType == milkType,
    );

    if (index >= 0) {
      final updatedCart = [...state];
      updatedCart[index] = updatedCart[index].copyWith(
        quantity: updatedCart[index].quantity + quantity,
      );
      state = updatedCart;
    } else {
      state = [
        ...state,
        CartItem(
          item: item,
          quantity: quantity,
          size: size,
          milkType: milkType,
        ),
      ];
    }
    _saveToPrefs();
  }

  void removeItem(MenuItem item, String size) {
    state = state
        .where(
          (element) => !(element.item.id == item.id && element.size == size),
        )
        .toList();
    _saveToPrefs();
  }

  void updateQuantity(MenuItem item, String size, int quantity) {
    if (quantity <= 0) {
      removeItem(item, size);
      return;
    }

    final index = state.indexWhere(
      (element) => element.item.id == item.id && element.size == size,
    );
    if (index >= 0) {
      final updatedCart = [...state];
      updatedCart[index] = updatedCart[index].copyWith(quantity: quantity);
      state = updatedCart;
    }
    _saveToPrefs();
  }

  double get totalAmount {
    return state.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  void clearCart() {
    state = [];
    // Best-effort wipe; ignore errors so the UI always updates.
    _cartRepo.clear().catchError((Object e) {
      debugPrint('Error clearing cart prefs: $e');
      return;
    });
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

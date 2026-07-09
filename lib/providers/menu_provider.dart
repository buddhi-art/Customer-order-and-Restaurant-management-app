import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/menu_repository.dart';
import '../models/menu_item.dart';

final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => MenuRepository(),
);

// Mock data to start with, per our plan
final mockMenu = [
  MenuItem(
    id: '1',
    name: 'Cappuccino',
    price: 25.40,
    imageUrl:
        'https://images.unsplash.com/photo-1572442388796-11668a67e53d?auto=format&fit=crop&q=80&w=300&h=300', // Mock coffee cup
    description:
        'A deep espresso base, the perfect proportions of hot milk and steamed milk foam.',
    category: 'Cappuccino',
    rating: 4.8,
    volumeMl: 160,
  ),
  MenuItem(
    id: '2',
    name: 'Latte',
    price: 22.00,
    imageUrl:
        'https://images.unsplash.com/photo-1534040385115-33dcb3acba5b?auto=format&fit=crop&q=80&w=300&h=300',
    description:
        'Rich, full-bodied espresso in steamed milk, lightly topped with foam.',
    category: 'Latte',
    rating: 4.6,
    volumeMl: 200,
  ),
  MenuItem(
    id: '3',
    name: 'Espresso',
    price: 18.50,
    imageUrl:
        'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?auto=format&fit=crop&q=80&w=300&h=300',
    description:
        'A concentrated form of coffee, served in small, strong shots.',
    category: 'Espresso',
    rating: 4.9,
    volumeMl: 30,
  ),
];

class MenuNotifier extends Notifier<List<MenuItem>> {
  StreamSubscription<List<Map<String, dynamic>>>? _menuSubscription;
  late final MenuRepository _repo;

  @override
  List<MenuItem> build() {
    _repo = ref.read(menuRepositoryProvider);
    _listenToMenu();
    ref.onDispose(() => _menuSubscription?.cancel());
    return mockMenu;
  }

  void _listenToMenu() {
    _menuSubscription = _repo.stream().listen(
      (List<Map<String, dynamic>> data) {
        if (data.isNotEmpty || state == mockMenu) {
          final List<MenuItem> loadedMenu = data
              .map<MenuItem>(MenuRepository.parseMenuItem)
              .toList();
          state = loadedMenu;
        }
      },
      onError: (error) {
        debugPrint('Error listening to menu: $error');
      },
    );
  }

  void addOrUpdateItem(MenuItem item) {
    final index = state.indexWhere((element) => element.id == item.id);
    if (index >= 0) {
      final updatedList = [...state];
      updatedList[index] = item;
      state = updatedList;
    } else {
      state = [...state, item];
    }
  }

  Future<void> toggleAvailability(String id) async {
    final index = state.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final newStatus = !state[index].isAvailable;

      final updatedList = [...state];
      updatedList[index] = MenuItem(
        id: updatedList[index].id,
        name: updatedList[index].name,
        price: updatedList[index].price,
        imageUrl: updatedList[index].imageUrl,
        description: updatedList[index].description,
        category: updatedList[index].category,
        rating: updatedList[index].rating,
        volumeMl: updatedList[index].volumeMl,
        isAvailable: newStatus,
      );
      state = updatedList;

      try {
        await _repo.setAvailability(id, newStatus);
        // We don't need to manually re-fetch, the stream will push the update
      } catch (e) {
        debugPrint('Error toggling availability: $e');
      }
    }
  }
}

final menuProvider = NotifierProvider<MenuNotifier, List<MenuItem>>(
  MenuNotifier.new,
);

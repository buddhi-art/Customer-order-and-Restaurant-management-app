import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/menu_repository.dart';
import '../models/menu_item.dart';

final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => MenuRepository(),
);


class MenuNotifier extends Notifier<List<MenuItem>> {
  StreamSubscription<List<Map<String, dynamic>>>? _menuSubscription;
  late final MenuRepository _repo;

  @override
  List<MenuItem> build() {
    _repo = ref.read(menuRepositoryProvider);
    _listenToMenu();
    ref.onDispose(() => _menuSubscription?.cancel());
    return const [];
  }

  void _listenToMenu() {
    _menuSubscription = _repo.stream().listen(
      (List<Map<String, dynamic>> data) {
        state = data.map<MenuItem>(MenuRepository.parseMenuItem).toList();
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

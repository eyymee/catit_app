import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/grocery_item.dart';

const _boxName = 'groceries';

class GroceryNotifier extends StateNotifier<List<GroceryItem>> {
  GroceryNotifier() : super([]) {
    _load();
  }

  late final Box<String> _box;

  Future<void> _load() async {
    _box = await Hive.openBox<String>(_boxName);
    state = _box.values.map(GroceryItem.decode).toList();
  }

  void _save() {
    _box.clear();
    for (final item in state) {
      _box.put(item.id, item.encode());
    }
  }

  void addItem(String name) {
    if (name.trim().isEmpty) return;
    state = [GroceryItem(name: name.trim()), ...state];
    _save();
  }

  void toggleItem(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isPurchased: !item.isPurchased) else item,
    ];
    _save();
  }

  void deleteItem(String id) {
    state = state.where((item) => item.id != id).toList();
    _save();
  }

  void clearAll() {
    state = [];
    _box.clear();
  }

  void completeList() {
    state = [];
    _box.clear();
  }
}

final groceryProvider =
    StateNotifierProvider<GroceryNotifier, List<GroceryItem>>(
  (_) => GroceryNotifier(),
);

final purchasedCountProvider = Provider<int>((ref) {
  return ref.watch(groceryProvider).where((i) => i.isPurchased).length;
});

final totalGroceryCountProvider = Provider<int>((ref) {
  return ref.watch(groceryProvider).length;
});

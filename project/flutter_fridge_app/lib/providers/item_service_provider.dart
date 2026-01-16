import "package:flutter_fridge_app/common/utils/result.dart";
import "package:flutter_fridge_app/main.dart" show repoProvider;
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/services/item_service.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

/// Provider for the [ItemService] dependency.
/// Depends on the [repoProvider] from main.dart.
final itemServiceProvider = Provider<ItemService>((ref) {
  final repo = ref.watch(repoProvider);
  return ItemService(repo);
});

/// Modern AsyncNotifier for managing the list of items with loading/error states.
class ItemsNotifier extends AsyncNotifier<List<Item>> {
  ItemService get _service => ref.read(itemServiceProvider);

  @override
  Future<List<Item>> build() async {
    final result = await _service.loadItems();
    return result.when(
      success: (items) => items,
      failure: (message, error) => throw (error ?? Exception(message)),
    );
  }

  /// Refresh items from the repository.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }

  /// Add a new item and refresh the list.
  Future<Result<void>> addItem(Item item) async {
    final result = await _service.addItem(item);
    if (result is Success) {
      await refresh();
    }
    return result;
  }

  /// Edit an item and refresh the list.
  Future<Result<void>> editItem(Item oldItem, Item newItem) async {
    final result = await _service.editItem(oldItem, newItem);
    if (result is Success) {
      await refresh();
    }
    return result;
  }

  /// Adjust quantity and refresh the list.
  Future<Result<void>> adjustQuantity(Item item, double delta) async {
    final result = await _service.adjustQuantity(item, delta);
    if (result is Success) {
      await refresh();
    }
    return result;
  }

  /// Delete an item and refresh the list.
  Future<Result<void>> deleteItem(String itemId) async {
    final result = await _service.deleteItem(itemId);
    if (result is Success) {
      await refresh();
    }
    return result;
  }
}

/// Provider for items with loading/error/data states.
final itemsNotifierProvider = AsyncNotifierProvider<ItemsNotifier, List<Item>>(
  ItemsNotifier.new,
);

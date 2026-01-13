import "package:flutter_fridge_app/domain/settings/price_symbol_settings.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:shared_preferences/shared_preferences.dart";

class PriceSymbolNotifier extends StateNotifier<AsyncValue<String>> {
  PriceSymbolNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final symbol = prefs.getString(priceSymbolPrefKey) ?? defaultPriceSymbol;
    state = AsyncValue.data(symbol);
  }

  Future<void> setSymbol(String symbol) async {
    state = AsyncValue.data(symbol);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(priceSymbolPrefKey, symbol);
  }
}

final priceSymbolProvider =
    StateNotifierProvider<PriceSymbolNotifier, AsyncValue<String>>(
      (ref) => PriceSymbolNotifier(),
    );

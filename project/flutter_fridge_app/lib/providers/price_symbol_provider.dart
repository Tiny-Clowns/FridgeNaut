import "package:flutter_fridge_app/domain/settings/price_symbol_settings.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Modern AsyncNotifier for managing the price symbol setting.
class PriceSymbolNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(priceSymbolPrefKey) ?? defaultPriceSymbol;
  }

  Future<void> setSymbol(String symbol) async {
    state = AsyncValue.data(symbol);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(priceSymbolPrefKey, symbol);
  }
}

final priceSymbolProvider = AsyncNotifierProvider<PriceSymbolNotifier, String>(
  PriceSymbolNotifier.new,
);

class CurrencyOption {
  final String labelKey;
  final String symbol;
  const CurrencyOption({required this.labelKey, required this.symbol});
}

const String priceSymbolPrefKey = "price_symbol";
const String defaultPriceSymbol = "£";

const List<CurrencyOption> currencyOptions = <CurrencyOption>[
  CurrencyOption(labelKey: "britishPound", symbol: "£"),
  CurrencyOption(labelKey: "usDollar", symbol: "\$"),
  CurrencyOption(labelKey: "euro", symbol: "€"),
  CurrencyOption(labelKey: "japaneseYen", symbol: "¥"),
  CurrencyOption(labelKey: "hongKongDollar", symbol: "HK\$"),
  CurrencyOption(labelKey: "australianDollar", symbol: "A\$"),
  CurrencyOption(labelKey: "canadianDollar", symbol: "C\$"),
  CurrencyOption(labelKey: "indianRupee", symbol: "₹"),
  CurrencyOption(labelKey: "southKoreanWon", symbol: "₩"),
  CurrencyOption(labelKey: "swissFranc", symbol: "CHF"),
];

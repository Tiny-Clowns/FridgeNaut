class CurrencyOption {
  final String label;
  final String symbol;
  const CurrencyOption({required this.label, required this.symbol});
}

const String priceSymbolPrefKey = "price_symbol";
const String defaultPriceSymbol = "£";

const List<CurrencyOption> currencyOptions = <CurrencyOption>[
  CurrencyOption(label: "British Pound", symbol: "£"),
  CurrencyOption(label: "US Dollar", symbol: "\$"),
  CurrencyOption(label: "Euro", symbol: "€"),
  CurrencyOption(label: "Japanese Yen", symbol: "¥"),
  CurrencyOption(label: "Hong Kong Dollar", symbol: "HK\$"),
  CurrencyOption(label: "Australian Dollar", symbol: "A\$"),
  CurrencyOption(label: "Canadian Dollar", symbol: "C\$"),
  CurrencyOption(label: "Indian Rupee", symbol: "₹"),
  CurrencyOption(label: "South Korean Won", symbol: "₩"),
  CurrencyOption(label: "Swiss Franc", symbol: "CHF"),
];

// lib/common/extensions/string_extensions.dart
extension StringCapitalization on String {
  String toCapitalisedWords() {
    final trimmed = trim();
    if (trimmed.isEmpty) return this;

    final words = trimmed.split(RegExp(r"\s+"));
    final capitalisedWords = words.map((word) {
      if (word.isEmpty) return word;
      final lower = word.toLowerCase();
      final first = lower[0].toUpperCase();
      return first + lower.substring(1);
    }).toList();

    return capitalisedWords.join(" ");
  }
}

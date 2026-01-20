import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_fridge_app/common/utils/date_time_utils.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";
import "package:flutter_fridge_app/common/extensions/string_extensions.dart";
import "package:flutter_fridge_app/domain/item_status.dart";
import "package:flutter_fridge_app/models/item.dart";

/// Data class representing the visual state of a fridge item tile.
/// This separates the UI from business logic, making testing easier.
class FridgeItemTileData {
  final String displayName;
  final String quantityText;
  final String? priceText;
  final String? expiryText;
  final bool isQuantityLow;
  final bool isExpired;
  final bool isExpiringSoon;
  final bool isZeroQuantity;
  final Widget leadingImage;

  const FridgeItemTileData({
    required this.displayName,
    required this.quantityText,
    this.priceText,
    this.expiryText,
    required this.isQuantityLow,
    required this.isExpired,
    required this.isExpiringSoon,
    required this.isZeroQuantity,
    required this.leadingImage,
  });

  /// Factory to create tile data from an Item and its calculated status.
  factory FridgeItemTileData.fromItem(
    Item item, {
    required ItemStatus status,
    required String currencySymbol,
  }) {
    final price = item.pricePerUnit;
    final exp = item.expirationDate;

    return FridgeItemTileData(
      displayName: item.name.toCapitalisedWords(),
      quantityText: "${item.quantity} ${item.unit}",
      priceText: price != null
          ? "$currencySymbol${price.toStringAsFixed(2)} / ${item.unit}"
          : null,
      expiryText: exp != null ? "exp ${formatLocalIsoDate(exp)}" : null,
      isQuantityLow: status.isLow,
      isExpired: status.isExpired,
      isExpiringSoon: status.isExpiringSoon,
      isZeroQuantity: status.isOutOfStock,
      leadingImage: _buildItemImage(item.imagePath),
    );
  }

  static Widget _buildItemImage(String? path) {
    if (path == null || path.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.fastfood));
    }

    final file = File(path);
    if (!file.existsSync()) {
      return const CircleAvatar(child: Icon(Icons.fastfood));
    }

    return CircleAvatar(backgroundImage: FileImage(file));
  }
}

/// A reusable tile widget for displaying fridge items.
/// Can be used in any list context.
class FridgeItemTile extends StatelessWidget {
  final FridgeItemTileData data;
  final VoidCallback? onTap;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const FridgeItemTile({
    super.key,
    required this.data,
    this.onTap,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: data.leadingImage,
      title: Text(
        data.displayName,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontSize: 18,
        ),
      ),
      titleAlignment: ListTileTitleAlignment.top,
      subtitle: _buildSubtitle(context, theme),
      onTap: onTap,
      trailing: _buildActions(theme),
    );
  }

  Widget _buildSubtitle(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final defaultStyle = theme.textTheme.bodyMedium;

    return Text.rich(
      TextSpan(
        style: defaultStyle?.copyWith(color: colorScheme.onSurface),
        children: [
          TextSpan(
            text: data.quantityText,
            style: data.isQuantityLow ? TextStyle(color: Colors.red) : null,
          ),
          if (data.priceText != null) ...[
            const TextSpan(text: " | "),
            TextSpan(text: data.priceText),
          ],
          if (data.expiryText != null) ...[
            const TextSpan(text: " | "),
            TextSpan(
              text: _localizedExpiryText(context, data.expiryText!),
              style: data.isExpired
                  ? const TextStyle(color: Colors.red)
                  : data.isExpiringSoon
                  ? const TextStyle(color: Colors.orange)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(data.isZeroQuantity ? Icons.delete : Icons.remove),
          color: Colors.red,
          onPressed: onDecrement,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          color: Colors.green,
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

String _localizedExpiryText(BuildContext context, String rawExpiryText) {
  // rawExpiryText currently formatted as "exp YYYY-MM-DD".
  final l10n = AppLocalizations.of(context)!;
  if (rawExpiryText.startsWith('exp ')) {
    return "${l10n.expiryAbbrev}${rawExpiryText.substring(3)}";
  }
  return rawExpiryText;
}

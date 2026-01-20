// lib/widgets/item_image_selector.dart
import "dart:io";

import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";

class ItemImageSelector extends StatefulWidget {
  final String? imagePath;
  final ValueChanged<String?> onImageChanged;

  const ItemImageSelector({
    super.key,
    required this.imagePath,
    required this.onImageChanged,
  });

  @override
  State<ItemImageSelector> createState() => _ItemImageSelectorState();
}

class _ItemImageSelectorState extends State<ItemImageSelector> {
  late final ImagePicker _picker;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 100,
    );

    if (picked != null) {
      widget.onImageChanged(picked.path);
    }
  }

  void _handleTap() {
    _pickImage();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final path = widget.imagePath ?? "";
    final hasImage = path.trim().isNotEmpty;

    return Center(
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: hasImage ? FileImage(File(path)) : null,
              child: hasImage ? null : const Icon(Icons.camera_alt),
            ),
            const SizedBox(height: 4),
            Text(
              hasImage ? l10n.changePicture : l10n.addPicture,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

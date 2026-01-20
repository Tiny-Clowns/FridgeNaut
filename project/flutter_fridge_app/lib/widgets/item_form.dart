import "package:flutter/material.dart";
import "package:flutter_fridge_app/widgets/item_image_selector.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/common/widgets/confirm_cancel_form.dart";

import "package:flutter_fridge_app/common/utils/date_time_utils.dart";
import "package:flutter_fridge_app/domain/settings/price_symbol_settings.dart";
import "package:flutter_fridge_app/l10n/generated/app_localizations.dart";

bool _sameDateOnly(DateTime? a, DateTime? b) {
  if (a == null || b == null) return a == b;
  return dateOnlyUtc(a) == dateOnlyUtc(b);
}

class _ItemFormSnapshot {
  final String name;
  final String unit;
  final String quantity;
  final String pricePerUnit;
  final String lowThreshold;
  final DateTime? expirationDate;
  final bool toBuy;
  final bool notifyOnLow;
  final bool notifyOnExpire;
  final String? imagePath;

  const _ItemFormSnapshot({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.pricePerUnit,
    required this.lowThreshold,
    required this.expirationDate,
    required this.toBuy,
    required this.notifyOnLow,
    required this.notifyOnExpire,
    required this.imagePath,
  });

  bool isSameAs(_ItemFormSnapshot other) {
    if (name.trim() != other.name.trim()) return false;
    if (unit.trim() != other.unit.trim()) return false;
    if (quantity.trim() != other.quantity.trim()) return false;
    if (pricePerUnit.trim() != other.pricePerUnit.trim()) return false;
    if (lowThreshold.trim() != other.lowThreshold.trim()) return false;
    if (!_sameDateOnly(expirationDate, other.expirationDate)) return false;
    if (toBuy != other.toBuy) return false;
    if (notifyOnLow != other.notifyOnLow) return false;
    if (notifyOnExpire != other.notifyOnExpire) return false;
    if ((imagePath ?? "") != (other.imagePath ?? "")) return false;
    return true;
  }
}

class ItemForm extends StatefulWidget {
  final Item? existing;
  final String currencySymbol;
  final List<Item>? allItems;

  const ItemForm({
    super.key,
    this.existing,
    this.currencySymbol = defaultPriceSymbol,
    this.allItems,
  });

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _form = GlobalKey<FormState>();

  static const _defaultUnit = "pcs";
  static const _defaultQuantity = 1;
  static const _defaultPricePerUnit = 0;
  static const _defaultLowThreshold = 1;
  static const _numberKeyboard = TextInputType.numberWithOptions(decimal: true);

  late final TextEditingController _nameController;
  late final TextEditingController _unitController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _lowThresholdController;

  DateTime? _expirationDate;
  bool _toBuy = false;
  bool _notifyOnLow = true;
  bool _notifyOnExpire = true;
  String? _imagePath;
  bool _isDuplicateName = false;

  late final _ItemFormSnapshot _initialSnapshot;

  bool get _isEdit => widget.existing != null;

  String _title(AppLocalizations l10n) =>
      _isEdit ? l10n.editItem : l10n.addItem;

  @override
  void initState() {
    super.initState();
    final it = widget.existing;

    _nameController = TextEditingController(text: it?.name ?? "");
    _unitController = TextEditingController(text: it?.unit ?? _defaultUnit);
    _quantityController = TextEditingController(
      text: (it?.quantity ?? _defaultQuantity).toString(),
    );
    _priceController = TextEditingController(
      text: (it?.pricePerUnit ?? _defaultPricePerUnit).toString(),
    );
    _lowThresholdController = TextEditingController(
      text: (it?.lowThreshold ?? _defaultLowThreshold).toString(),
    );

    _expirationDate = it?.expirationDate;
    _toBuy = it?.toBuy ?? false;
    _notifyOnLow = it?.notifyOnLow ?? true;
    _notifyOnExpire = it?.notifyOnExpire ?? true;
    _imagePath = it?.imagePath;

    _initialSnapshot = _createSnapshot();

    // Listen for name changes to check for duplicates
    _nameController.addListener(_checkForDuplicateName);
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForDuplicateName);
    _nameController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _lowThresholdController.dispose();
    super.dispose();
  }

  _ItemFormSnapshot _createSnapshot() {
    return _ItemFormSnapshot(
      name: _nameController.text,
      unit: _unitController.text,
      quantity: _quantityController.text,
      pricePerUnit: _priceController.text,
      lowThreshold: _lowThresholdController.text,
      expirationDate: _expirationDate,
      toBuy: _toBuy,
      notifyOnLow: _notifyOnLow,
      notifyOnExpire: _notifyOnExpire,
      imagePath: _imagePath,
    );
  }

  bool _hasChanges() => !_initialSnapshot.isSameAs(_createSnapshot());

  void _checkForDuplicateName() {
    final items = widget.allItems;
    if (items == null || items.isEmpty) {
      if (_isDuplicateName) {
        setState(() => _isDuplicateName = false);
      }
      return;
    }

    final currentName = _nameController.text.trim().toLowerCase();
    if (currentName.isEmpty) {
      if (_isDuplicateName) {
        setState(() => _isDuplicateName = false);
      }
      return;
    }

    final existingId = widget.existing?.id;
    final isDuplicate = items.any(
      (item) =>
          item.id != existingId &&
          item.name.trim().toLowerCase() == currentName,
    );

    if (isDuplicate != _isDuplicateName) {
      setState(() => _isDuplicateName = isDuplicate);
    }
  }

  String? _validateRequiredText(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.required;
    return null;
  }

  String? _validateRequiredNonNegativeNumber(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.required;
    final value = double.tryParse(v.trim());
    if (value == null) return l10n.invalidNumber;
    if (value < 0) return l10n.minZero;
    return null;
  }

  double _parseDouble(String v) => double.tryParse(v.trim()) ?? 0;

  String _normalizedUnit() {
    final unit = _unitController.text.trim();
    return unit.isEmpty ? _defaultUnit : unit;
  }

  String _expirationLabel(AppLocalizations l10n) {
    final date = _expirationDate;
    return date == null ? l10n.none : formatLocalIsoDate(date);
  }

  bool get _isPastExpiry {
    final exp = _expirationDate;
    if (exp == null) return false;

    final todayUtc = dateOnlyUtc(DateTime.now());
    final expDateOnly = dateOnlyUtc(exp);

    return expDateOnly.isBefore(todayUtc);
  }

  Future<void> _selectExpirationDate() async {
    final now = DateTime.now();
    final initial = _expirationDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() => _expirationDate = dateOnlyUtc(picked));
    }
  }

  void _closeWithoutResult() {
    Navigator.pop(context, null);
  }

  Item _buildItem() {
    final now = DateTime.now().toUtc();

    final qty = _parseDouble(_quantityController.text);
    final price = _parseDouble(_priceController.text);
    final low = _parseDouble(_lowThresholdController.text);

    final id = widget.existing?.id ?? now.microsecondsSinceEpoch.toString();

    return Item(
      id: id,
      name: _nameController.text.trim(),
      quantity: qty,
      unit: _normalizedUnit(),
      expirationDate: _expirationDate,
      pricePerUnit: price,
      toBuy: _toBuy,
      notifyOnLow: _notifyOnLow,
      notifyOnExpire: _notifyOnExpire,
      lowThreshold: low,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
      imagePath: _imagePath,
    );
  }

  void _handleSave() {
    final valid = _form.currentState?.validate() ?? false;
    if (!valid) return;
    final item = _buildItem();
    Navigator.pop(context, item);
  }

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixText: prefixText),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  TextFormField _buildNumberField({
    required TextEditingController controller,
    required String label,
    required AppLocalizations l10n,
    String? prefixText,
  }) {
    return _buildTextField(
      controller: controller,
      label: label,
      prefixText: prefixText,
      keyboardType: _numberKeyboard,
      validator: (v) => _validateRequiredNonNegativeNumber(v, l10n),
    );
  }

  Widget _buildImageSelector() {
    return ItemImageSelector(
      imagePath: _imagePath,
      onImageChanged: (path) => setState(() => _imagePath = path),
    );
  }

  Widget _buildNameField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: l10n.name,
          validator: (v) => _validateRequiredText(v, l10n),
        ),
        if (_isDuplicateName)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
            child: Text(
              l10n.duplicateNameWarning,
              style: TextStyle(color: Colors.yellow.shade700, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildQuantityUnitRow(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildNumberField(
            controller: _quantityController,
            label: l10n.quantity,
            l10n: l10n,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(controller: _unitController, label: l10n.unit),
        ),
      ],
    );
  }

  Widget _buildPriceLowRow(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildNumberField(
            controller: _priceController,
            label: l10n.pricePerUnit,
            l10n: l10n,
            prefixText: "${widget.currencySymbol} ",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberField(
            controller: _lowThresholdController,
            label: l10n.lowThreshold,
            l10n: l10n,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildExpirationSection(AppLocalizations l10n) {
    return [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.expirationDate),
        subtitle: Text(_expirationLabel(l10n)),
        trailing: IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: _selectExpirationDate,
        ),
      ),
      if (_isPastExpiry) ...[
        const SizedBox(height: 4),
        Text(
          l10n.pastExpiryNote,
          style: const TextStyle(color: Colors.orange, fontSize: 12),
        ),
      ],
    ];
  }

  List<Widget> _buildNotificationSwitches(AppLocalizations l10n) {
    return [
      SwitchListTile(
        title: Text(l10n.plannedToBuy),
        value: _toBuy,
        onChanged: (v) => setState(() => _toBuy = v),
      ),
      SwitchListTile(
        title: Text(l10n.notifyOnLow),
        value: _notifyOnLow,
        onChanged: (v) => setState(() => _notifyOnLow = v),
      ),
      SwitchListTile(
        title: Text(l10n.notifyOnExpire),
        value: _notifyOnExpire,
        onChanged: (v) => setState(() => _notifyOnExpire = v),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final formLabels = ConfirmCancelFormLabels(
      cancelButton: l10n.cancel,
      saveButton: l10n.save,
      discardDialogTitle: l10n.discardChanges,
      discardDialogContent: l10n.discardChangesMessage,
      keepEditingButton: l10n.keepEditing,
      discardButton: l10n.discard,
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + bottomInset,
        ),
        child: Form(
          key: _form,
          child: ConfirmCancelForm(
            title: _title(l10n),
            hasChanges: _hasChanges,
            onCancelConfirmed: _closeWithoutResult,
            onSave: _handleSave,
            labels: formLabels,
            children: [
              _buildImageSelector(),
              const SizedBox(height: 16),

              _buildNameField(l10n),
              _buildQuantityUnitRow(l10n),
              _buildPriceLowRow(l10n),
              const SizedBox(height: 8),

              ..._buildExpirationSection(l10n),
              ..._buildNotificationSwitches(l10n),
            ],
          ),
        ),
      ),
    );
  }
}

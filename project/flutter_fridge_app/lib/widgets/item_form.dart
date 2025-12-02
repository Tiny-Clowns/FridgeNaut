// lib/widgets/item_form.dart
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_fridge_app/widgets/item_image_selector.dart";
import "package:image_picker/image_picker.dart";
import "package:flutter_fridge_app/models/item.dart";
import "package:flutter_fridge_app/common/widgets/confirm_cancel_form.dart";

bool _sameDateOnly(DateTime? a, DateTime? b) {
  if (a == null || b == null) return a == b;
  final ad = DateTime.utc(a.year, a.month, a.day);
  final bd = DateTime.utc(b.year, b.month, b.day);
  return ad == bd;
}

class _ItemFormSnapshot {
  final String name;
  final String unit;
  final String qty;
  final String price;
  final String low;
  final DateTime? exp;
  final bool toBuy;
  final bool notifyLow;
  final bool notifyExp;
  final String? imagePath;

  const _ItemFormSnapshot({
    required this.name,
    required this.unit,
    required this.qty,
    required this.price,
    required this.low,
    required this.exp,
    required this.toBuy,
    required this.notifyLow,
    required this.notifyExp,
    required this.imagePath,
  });

  bool isSameAs(_ItemFormSnapshot other) {
    if (name.trim() != other.name.trim()) return false;
    if (unit.trim() != other.unit.trim()) return false;
    if (qty.trim() != other.qty.trim()) return false;
    if (price.trim() != other.price.trim()) return false;
    if (low.trim() != other.low.trim()) return false;
    if (!_sameDateOnly(exp, other.exp)) return false;
    if (toBuy != other.toBuy) return false;
    if (notifyLow != other.notifyLow) return false;
    if (notifyExp != other.notifyExp) return false;
    if ((imagePath ?? "") != (other.imagePath ?? "")) return false;
    return true;
  }
}

class ItemForm extends StatefulWidget {
  final Item? existing;
  const ItemForm({super.key, this.existing});

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _form = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _unit;
  late final TextEditingController _qty;
  late final TextEditingController _price;
  late final TextEditingController _low;

  DateTime? _exp;
  bool _toBuy = false;
  bool _notifyLow = true;
  bool _notifyExp = true;

  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  late final _ItemFormSnapshot _initialSnapshot;

  static const _numberKeyboard = TextInputType.numberWithOptions(decimal: true);

  @override
  void initState() {
    super.initState();
    final it = widget.existing;

    _name = TextEditingController(text: it?.name ?? "");
    _unit = TextEditingController(text: it?.unit ?? "pcs");
    _qty = TextEditingController(text: (it?.quantity ?? 1).toString());
    _price = TextEditingController(text: (it?.pricePerUnit ?? 0).toString());
    _low = TextEditingController(text: (it?.lowThreshold ?? 1).toString());

    _exp = it?.expirationDate;
    _toBuy = it?.toBuy ?? false;
    _notifyLow = it?.notifyOnLow ?? true;
    _notifyExp = it?.notifyOnExpire ?? true;
    _imagePath = it?.imagePath;

    _initialSnapshot = _createSnapshot();
  }

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _qty.dispose();
    _price.dispose();
    _low.dispose();
    super.dispose();
  }

  _ItemFormSnapshot _createSnapshot() {
    return _ItemFormSnapshot(
      name: _name.text,
      unit: _unit.text,
      qty: _qty.text,
      price: _price.text,
      low: _low.text,
      exp: _exp,
      toBuy: _toBuy,
      notifyLow: _notifyLow,
      notifyExp: _notifyExp,
      imagePath: _imagePath,
    );
  }

  bool get _hasChanges => !_initialSnapshot.isSameAs(_createSnapshot());
  bool hasChanges() => _hasChanges;

  String? _validateRequiredNonNegativeNumber(String? v) {
    if (v == null || v.trim().isEmpty) return "Required";
    final value = double.tryParse(v.trim());
    if (value == null) return "Number";
    if (value < 0) return "Min 0";
    return null;
  }

  bool get _isPastExpiry {
    if (_exp == null) return false;

    final now = DateTime.now().toUtc();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);

    final expUtc = _exp!.toUtc();
    final expDateOnly = DateTime.utc(expUtc.year, expUtc.month, expUtc.day);

    return expDateOnly.isBefore(todayUtc);
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 100,
    );
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
      });
    }
  }

  Future<void> _selectExpirationDate() async {
    final now = DateTime.now();
    final initial = _exp ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(
        () => _exp = DateTime.utc(picked.year, picked.month, picked.day),
      );
    }
  }

  void _closeWithoutResult() {
    Navigator.pop(context, null);
  }

  Item _buildItem() {
    final now = DateTime.now().toUtc();

    final qty = double.tryParse(_qty.text) ?? 0;
    final price = double.tryParse(_price.text) ?? 0;
    final low = double.tryParse(_low.text) ?? 0;

    final id =
        widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString();

    return Item(
      id: id,
      name: _name.text.trim(),
      quantity: qty,
      unit: _unit.text.trim().isEmpty ? "pcs" : _unit.text.trim(),
      expirationDate: _exp,
      pricePerUnit: price,
      toBuy: _toBuy,
      notifyOnLow: _notifyLow,
      notifyOnExpire: _notifyExp,
      lowThreshold: low,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
      imagePath: _imagePath,
    );
  }

  void _handleSave() {
    if (!_form.currentState!.validate()) return;
    final item = _buildItem();
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final title = isEdit ? "Edit item" : "Add item";

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _form,
          child: ConfirmCancelForm(
            title: title,
            hasChanges: hasChanges,
            onCancelConfirmed: _closeWithoutResult,
            onSave: _handleSave,
            children: [
              Text(
                widget.existing == null ? "Add item" : "Edit item",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Image selector
              ItemImageSelector(
                imagePath: _imagePath,
                onImageChanged: (path) {
                  setState(() {
                    _imagePath = path;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Required" : null,
              ),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qty,
                      decoration: const InputDecoration(labelText: "Quantity"),
                      keyboardType: _numberKeyboard,
                      validator: _validateRequiredNonNegativeNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unit,
                      decoration: const InputDecoration(labelText: "Unit"),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      decoration: const InputDecoration(
                        labelText: "Price per unit",
                      ),
                      keyboardType: _numberKeyboard,
                      validator: _validateRequiredNonNegativeNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _low,
                      decoration: const InputDecoration(
                        labelText: "Low threshold",
                      ),
                      keyboardType: _numberKeyboard,
                      validator: _validateRequiredNonNegativeNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Expiration date"),
                subtitle: Text(
                  _exp == null
                      ? "None"
                      : _exp!.toLocal().toIso8601String().substring(0, 10),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _selectExpirationDate,
                ),
              ),
              if (_isPastExpiry) ...[
                const SizedBox(height: 4),
                const Text(
                  "Note: this expiration date is in the past.",
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],

              SwitchListTile(
                title: const Text("Planned to buy"),
                value: _toBuy,
                onChanged: (v) => setState(() => _toBuy = v),
              ),
              SwitchListTile(
                title: const Text("Notify on low"),
                value: _notifyLow,
                onChanged: (v) => setState(() => _notifyLow = v),
              ),
              SwitchListTile(
                title: const Text("Notify on expire"),
                value: _notifyExp,
                onChanged: (v) => setState(() => _notifyExp = v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

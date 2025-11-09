import "package:flutter/material.dart";
import "package:flutter_fridge_app/models/item.dart";

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

  @override
  Widget build(BuildContext context) {
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
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                widget.existing == null ? "Add item" : "Edit item",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) =>
                          (double.tryParse(v ?? "") == null) ? "Number" : null,
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _low,
                      decoration: const InputDecoration(
                        labelText: "Low threshold",
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) =>
                          (double.tryParse(v ?? "") == null) ? "Number" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Expiration date"),
                subtitle: Text(
                  _exp?.toLocal().toIso8601String().substring(0, 10) ?? "None",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _exp ?? now,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 5),
                    );
                    if (picked != null)
                      setState(
                        () => _exp = DateTime.utc(
                          picked.year,
                          picked.month,
                          picked.day,
                        ),
                      );
                  },
                ),
              ),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text("Cancel"),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (!_form.currentState!.validate()) return;
                      final now = DateTime.now().toUtc();
                      final qty = double.tryParse(_qty.text) ?? 0;
                      final price = double.tryParse(_price.text);
                      final low = double.tryParse(_low.text) ?? 1;
                      final id =
                          widget.existing?.id ??
                          DateTime.now().microsecondsSinceEpoch.toString();

                      final item = Item(
                        id: id,
                        name: _name.text.trim(),
                        quantity: qty,
                        unit: _unit.text.trim().isEmpty
                            ? "pcs"
                            : _unit.text.trim(),
                        expirationDate: _exp,
                        pricePerUnit: price,
                        toBuy: _toBuy,
                        notifyOnLow: _notifyLow,
                        notifyOnExpire: _notifyExp,
                        lowThreshold: low,
                        createdAt: widget.existing?.createdAt ?? now,
                        updatedAt: now,
                      );
                      Navigator.pop(context, item);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

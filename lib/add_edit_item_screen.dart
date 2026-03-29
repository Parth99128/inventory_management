import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';
import '../providers/inventory_provider.dart';

const _uuid = Uuid();

class AddEditItemScreen extends StatefulWidget {
  final InventoryItem? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _quantity;
  late final TextEditingController _threshold;
  late final TextEditingController _costPrice;
  late final TextEditingController _sellingPrice;
  late final TextEditingController _description;
  late final TextEditingController _location;

  late ItemCategory _category;
  bool _saving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _name = TextEditingController(text: i?.name ?? '');
    _sku = TextEditingController(text: i?.sku ?? '');
    _quantity = TextEditingController(
        text: i != null ? i.quantity.toString() : '0');
    _threshold = TextEditingController(
        text: i != null ? i.lowStockThreshold.toString() : '10');
    _costPrice = TextEditingController(
        text: i != null ? i.costPrice.toString() : '');
    _sellingPrice = TextEditingController(
        text: i != null ? i.sellingPrice.toString() : '');
    _description = TextEditingController(text: i?.description ?? '');
    _location = TextEditingController(text: i?.location ?? '');
    _category = i?.category ?? ItemCategory.other;
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _quantity.dispose();
    _threshold.dispose();
    _costPrice.dispose();
    _sellingPrice.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final item = InventoryItem(
      id: widget.item?.id ?? _uuid.v4(),
      name: _name.text.trim(),
      sku: _sku.text.trim(),
      category: _category,
      quantity: int.parse(_quantity.text),
      lowStockThreshold: int.parse(_threshold.text),
      costPrice: double.parse(_costPrice.text),
      sellingPrice: double.parse(_sellingPrice.text),
      description:
          _description.text.isEmpty ? null : _description.text.trim(),
      location: _location.text.isEmpty ? null : _location.text.trim(),
      activityLog: widget.item?.activityLog ?? [],
      createdAt: widget.item?.createdAt ?? now,
      updatedAt: now,
    );

    final inv = context.read<InventoryProvider>();
    if (_isEdit) {
      await inv.updateItem(item);
    } else {
      await inv.addItem(item);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Item' : 'New Item'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text(
                _isEdit ? 'Save' : 'Add',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          children: [
            _SectionHeader('Basic Info'),
            const SizedBox(height: 12),
            _field(_name, 'Product Name', required: true),
            const SizedBox(height: 12),
            _field(_sku, 'SKU / Barcode', required: true),
            const SizedBox(height: 12),
            _CategoryPicker(
              value: _category,
              onChanged: (c) => setState(() => _category = c),
            ),
            const SizedBox(height: 12),
            _field(_description, 'Description (optional)', maxLines: 3),
            const SizedBox(height: 24),

            _SectionHeader('Stock'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _field(_quantity, 'Quantity',
                        number: true, required: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field(_threshold, 'Low Stock Alert',
                        number: true, required: true)),
              ],
            ),
            const SizedBox(height: 12),
            _field(_location, 'Storage Location (optional)'),
            const SizedBox(height: 24),

            _SectionHeader('Pricing'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _field(_costPrice, 'Cost Price',
                        decimal: true, required: true, prefix: '\$')),
                const SizedBox(width: 12),
                Expanded(
                    child: _field(_sellingPrice, 'Selling Price',
                        decimal: true, required: true, prefix: '\$')),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_isEdit ? 'Save Changes' : 'Add to Inventory'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    bool number = false,
    bool decimal = false,
    int maxLines = 1,
    String? prefix,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : number
              ? TextInputType.number
              : null,
      inputFormatters: number || decimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
      ),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if ((number || decimal) && double.tryParse(v) == null)
                return 'Enter a valid number';
              return null;
            }
          : null,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final ItemCategory value;
  final void Function(ItemCategory) onChanged;

  const _CategoryPicker(
      {required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ItemCategory>(
      value: value,
      dropdownColor: Theme.of(context).cardColor,
      decoration: const InputDecoration(labelText: 'Category'),
      items: ItemCategory.values
          .map((c) => DropdownMenuItem(
                value: c,
                child: Text('${c.emoji}  ${c.label}'),
              ))
          .toList(),
      onChanged: (c) => c != null ? onChanged(c) : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';
import '../providers/inventory_provider.dart';
import 'add_edit_item_screen.dart';

class ItemDetailScreen extends StatelessWidget {
  final InventoryItem item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    final inv = context.read<InventoryProvider>();

    // Always read fresh from provider
    final current = context.watch<InventoryProvider>().allItems
        .firstWhere((i) => i.id == item.id, orElse: () => item);

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (current.isOutOfStock) {
      statusColor = Theme.of(context).colorScheme.error;
      statusLabel = 'Out of Stock';
      statusIcon = Icons.remove_shopping_cart_rounded;
    } else if (current.isLowStock) {
      statusColor = const Color(0xFFFF9500);
      statusLabel = 'Low Stock';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = Theme.of(context).colorScheme.primary;
      statusLabel = 'In Stock';
      statusIcon = Icons.check_circle_rounded;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(current.name,
            overflow: TextOverflow.ellipsis, maxLines: 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditItemScreen(item: current),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_rounded,
                color: Theme.of(context).colorScheme.error),
            onPressed: () => _confirmDelete(context, inv, current),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          // Status badge
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 6),
                    Text(statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${current.category.emoji} ${current.category.label}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quantity hero
          _QuantityCard(item: current),
          const SizedBox(height: 16),

          // Info grid
          _InfoGrid(item: current),
          const SizedBox(height: 16),

          // Pricing
          _PricingCard(item: current),
          const SizedBox(height: 16),

          // Stock Adjustment
          _StockAdjustCard(item: current),
          const SizedBox(height: 20),

          // Activity log
          if (current.activityLog.isNotEmpty) ...[
            Text('Activity Log',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            ...current.activityLog
                .take(15)
                .map((a) => _ActivityRow(activity: a))
                .toList(),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, InventoryProvider inv, InventoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Delete Item?'),
        content:
            Text('This will permanently delete "${item.name}".'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              inv.deleteItem(item.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

class _QuantityCard extends StatelessWidget {
  final InventoryItem item;
  const _QuantityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Stock',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  item.quantity.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(
                        color: item.isOutOfStock
                            ? Theme.of(context).colorScheme.error
                            : item.isLowStock
                                ? const Color(0xFFFF9500)
                                : Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text('units',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('SKU',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                item.sku,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: 10),
              if (item.location != null) ...[
                Text('Location',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 14, color: Color(0xFF8891A8)),
                    const SizedBox(width: 4),
                    Text(item.location!,
                        style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final InventoryItem item;
  const _InfoGrid({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.description != null) ...[
            Text('Description',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(item.description!,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                    'Low Stock Threshold',
                    '${item.lowStockThreshold} units'),
              ),
              Expanded(
                child: _InfoItem(
                    'Total Value',
                    '\$${item.totalValue.toStringAsFixed(2)}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  final InventoryItem item;
  const _PricingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pricing',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PriceBox(
                  label: 'Cost',
                  value: currency.format(item.costPrice),
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PriceBox(
                  label: 'Selling',
                  value: currency.format(item.sellingPrice),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PriceBox(
                  label: 'Margin',
                  value: '${item.margin.toStringAsFixed(1)}%',
                  color: const Color(0xFF7B61FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PriceBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _StockAdjustCard extends StatefulWidget {
  final InventoryItem item;
  const _StockAdjustCard({required this.item});

  @override
  State<_StockAdjustCard> createState() => _StockAdjustCardState();
}

class _StockAdjustCardState extends State<_StockAdjustCard> {
  final _noteCtrl = TextEditingController();
  int _delta = 0;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    if (_delta == 0) return;
    context.read<InventoryProvider>().adjustStock(
          widget.item.id,
          _delta,
          _noteCtrl.text.isEmpty ? 'Manual adjustment' : _noteCtrl.text,
        );
    setState(() => _delta = 0);
    _noteCtrl.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_delta > 0
            ? 'Added ${_delta.abs()} units'
            : 'Removed ${_delta.abs()} units'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adjust Stock',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AdjBtn(
                  icon: Icons.remove_rounded,
                  onTap: () => setState(() => _delta--)),
              const SizedBox(width: 16),
              Container(
                width: 80,
                alignment: Alignment.center,
                child: Text(
                  _delta >= 0 ? '+$_delta' : '$_delta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _delta > 0
                        ? Theme.of(context).colorScheme.primary
                        : _delta < 0
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _AdjBtn(
                  icon: Icons.add_rounded,
                  onTap: () => setState(() => _delta++)),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              hintText: 'Note (optional)',
              prefixIcon: Icon(Icons.notes_rounded, size: 18),
              isDense: true,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _delta != 0 ? _apply : null,
              child: const Text('Apply Adjustment'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdjBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AdjBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.3)),
        ),
        child: Icon(icon,
            color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final StockActivity activity;
  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isPositive = activity.quantityChange > 0;
    final color = isPositive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final fmt = DateFormat('MMM d, h:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.note,
                    style: Theme.of(context).textTheme.bodyLarge),
                Text(fmt.format(activity.date),
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Text(
            isPositive
                ? '+${activity.quantityChange}'
                : '${activity.quantityChange}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';
import '../screens/item_detail_screen.dart';

class ItemTile extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onDismissed;
  final bool compact;

  const ItemTile({
    super.key,
    required this.item,
    this.onDismissed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget tile = _buildTile(context);

    if (onDismissed != null) {
      tile = Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.delete_rounded,
              color: Theme.of(context).colorScheme.error),
        ),
        confirmDismiss: (_) => _confirmDelete(context),
        onDismissed: (_) => onDismissed!(),
        child: tile,
      );
    }

    return tile;
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Delete Item?'),
        content: Text('Remove "${item.name}" from inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    Color statusColor;
    if (item.isOutOfStock) {
      statusColor = Theme.of(context).colorScheme.error;
    } else if (item.isLowStock) {
      statusColor = const Color(0xFFFF9500);
    } else {
      statusColor = Theme.of(context).colorScheme.primary;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailScreen(item: item),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (item.isOutOfStock || item.isLowStock)
                ? statusColor.withOpacity(0.3)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            // Category emoji circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(item.category.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.sku,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 4),
                    Text(
                      currency.format(item.sellingPrice),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.isOutOfStock
                        ? 'Out'
                        : '${item.quantity}',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.isOutOfStock
                        ? 'Out of stock'
                        : item.isLowStock
                            ? 'Low stock'
                            : 'In stock',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: Color(0xFF8891A8)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

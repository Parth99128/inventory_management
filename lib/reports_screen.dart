import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inv, _) {
        final currency =
            NumberFormat.currency(symbol: '\$', decimalDigits: 2);

        // Top 5 by value
        final byValue = inv.allItems.toList()
          ..sort((a, b) => b.totalValue.compareTo(a.totalValue));
        final top5 = byValue.take(5).toList();

        // Category value breakdown
        final catValue = <ItemCategory, double>{};
        for (final item in inv.allItems) {
          catValue[item.category] =
              (catValue[item.category] ?? 0) + item.totalValue;
        }
        final sortedCat = catValue.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final totalVal = inv.totalInventoryValue;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.fromLTRB(20, 0, 20, 16),
                title: Text('Reports',
                    style:
                        Theme.of(context).appBarTheme.titleTextStyle),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Summary totals
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Inventory Summary',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium),
                        const SizedBox(height: 16),
                        _Row('Total SKUs',
                            inv.totalItems.toString()),
                        _Row('Total Stock Value',
                            currency.format(totalVal)),
                        _Row('Low Stock Items',
                            inv.lowStockCount.toString()),
                        _Row('Out of Stock',
                            inv.outOfStockCount.toString()),
                        _Row(
                          'Avg Item Value',
                          inv.totalItems > 0
                              ? currency.format(totalVal /
                                  inv.totalItems)
                              : '\$0',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Top items by value
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Top Items by Value',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium),
                        const SizedBox(height: 14),
                        ...top5.asMap().entries.map((e) {
                          final i = e.key;
                          final item = e.value;
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(i == 0
                                            ? 0.3
                                            : 0.1),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                      Text(
                                          '${item.quantity} units',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    ],
                                  ),
                                ),
                                Text(
                                  currency
                                      .format(item.totalValue),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category value breakdown
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Value by Category',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium),
                        const SizedBox(height: 14),
                        ...sortedCat.map((e) {
                          final pct =
                              totalVal > 0 ? e.value / totalVal : 0.0;
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(e.key.emoji,
                                        style: const TextStyle(
                                            fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(e.key.label,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge)),
                                    Text(
                                      currency.format(e.value),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 6,
                                    backgroundColor: Colors.white
                                        .withOpacity(0.07),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${(pct * 100).toStringAsFixed(1)}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

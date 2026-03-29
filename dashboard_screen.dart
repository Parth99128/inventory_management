import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import '../widgets/stat_card.dart';
import '../widgets/item_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inv, _) {
        if (inv.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              sliver: SliverToBoxAdapter(child: _buildStats(context, inv)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              sliver: SliverToBoxAdapter(
                  child: _buildCategoryBreakdown(context, inv)),
            ),
            if (inv.lowStockItems.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: _buildAlertsBanner(context, inv),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Text('Recent Activity',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final item = inv.allItems
                        .toList()
                        .reversed
                        .take(5)
                        .toList()[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ItemTile(item: item, compact: true),
                    );
                  },
                  childCount:
                      inv.allItems.length.clamp(0, 5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    final now = DateFormat('EEEE, MMM d').format(DateTime.now());
    return SliverAppBar(
      floating: true,
      pinned: false,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(now,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.8),
                    )),
            Text('Dashboard',
                style: Theme.of(context).appBarTheme.titleTextStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, InventoryProvider inv) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Total Items',
                value: inv.totalItems.toString(),
                icon: Icons.inventory_2_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Total Value',
                value: currency.format(inv.totalInventoryValue),
                icon: Icons.attach_money_rounded,
                color: const Color(0xFF7B61FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Low Stock',
                value: inv.lowStockCount.toString(),
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFFF9500),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Out of Stock',
                value: inv.outOfStockCount.toString(),
                icon: Icons.remove_shopping_cart_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
      BuildContext context, InventoryProvider inv) {
    final breakdown = inv.categoryBreakdown;
    if (breakdown.isEmpty) return const SizedBox.shrink();

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
          Text('By Category',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 14),
          ...breakdown.entries.map((e) {
            final pct = e.value / inv.totalItems;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(e.key.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key.label,
                                style: Theme.of(context).textTheme.bodyLarge),
                            Text('${e.value}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.w600,
                                    )),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor:
                                Colors.white.withOpacity(0.07),
                            color: Theme.of(context).colorScheme.primary,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAlertsBanner(
      BuildContext context, InventoryProvider inv) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9500).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFFFF9500).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFFF9500), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${inv.lowStockItems.length} item${inv.lowStockItems.length > 1 ? 's' : ''} need restocking',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFFF9500),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

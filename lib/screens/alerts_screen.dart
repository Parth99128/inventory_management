import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import '../widgets/item_tile.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inv, _) {
        final outOfStock =
            inv.allItems.where((i) => i.isOutOfStock).toList();
        final lowStock =
            inv.allItems.where((i) => i.isLowStock).toList();

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.fromLTRB(20, 0, 20, 16),
                title: Text('Alerts',
                    style:
                        Theme.of(context).appBarTheme.titleTextStyle),
              ),
            ),
            if (outOfStock.isEmpty && lowStock.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✅',
                          style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 16),
                      Text('All Good!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                          'All items are sufficiently stocked',
                          style:
                              Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              )
            else ...[
              if (outOfStock.isNotEmpty) ...[
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: _AlertSection(
                      title: 'Out of Stock',
                      count: outOfStock.length,
                      color: Theme.of(context).colorScheme.error,
                      icon: Icons.remove_shopping_cart_rounded,
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child:
                            ItemTile(item: outOfStock[i], compact: true),
                      ),
                      childCount: outOfStock.length,
                    ),
                  ),
                ),
              ],
              if (lowStock.isNotEmpty) ...[
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: _AlertSection(
                      title: 'Low Stock',
                      count: lowStock.length,
                      color: const Color(0xFFFF9500),
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child:
                            ItemTile(item: lowStock[i], compact: true),
                      ),
                      childCount: lowStock.length,
                    ),
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _AlertSection extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _AlertSection({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style:
                Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                    )),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import '../widgets/item_tile.dart';
import 'add_edit_item_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<InventoryProvider>(
        builder: (context, inv, _) => CustomScrollView(
          slivers: [
            _buildAppBar(context, inv),
            _buildFilters(context, inv),
            if (inv.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (inv.items.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📦',
                          style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 16),
                      Text('No items found',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium),
                      const SizedBox(height: 8),
                      Text('Add your first inventory item',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final item = inv.items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ItemTile(
                          item: item,
                          onDismissed: () =>
                              inv.deleteItem(item.id),
                        ),
                      );
                    },
                    childCount: inv.items.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddEditItemScreen(),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, InventoryProvider inv) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Text('Inventory',
            style: Theme.of(context).appBarTheme.titleTextStyle),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: TextField(
            onChanged: inv.setSearch,
            decoration: InputDecoration(
              hintText: 'Search items, SKU...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              isDense: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(
      BuildContext context, InventoryProvider inv) {
    final cats = [null, ...ItemCategory.values];
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = cats[i];
                final selected = inv.selectedCategory == cat;
                return FilterChip(
                  label: Text(cat == null
                      ? 'All'
                      : '${cat.emoji} ${cat.label}'),
                  selected: selected,
                  onSelected: (_) => inv.setCategory(cat),
                  selectedColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.18),
                  labelStyle: TextStyle(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                );
              },
            ),
          ),
          // Sort row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text('${inv.items.length} items',
                    style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                _SortButton(
                  value: inv.sortBy,
                  onChanged: inv.setSortBy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;

  const _SortButton({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sort By',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              ...{
                'name': 'Name A-Z',
                'quantity': 'Quantity (Low first)',
                'value': 'Value (High first)',
                'date': 'Last Updated',
              }.entries.map((e) {
                return ListTile(
                  title: Text(e.value),
                  trailing: value == e.key
                      ? Icon(Icons.check_rounded,
                          color:
                              Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    onChanged(e.key);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.sort_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text('Sort',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  )),
        ],
      ),
    );
  }
}

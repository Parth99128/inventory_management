import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';

const _uuid = Uuid();

class InventoryProvider extends ChangeNotifier {
  List<InventoryItem> _items = [];
  bool _isLoading = false;
  String _searchQuery = '';
  ItemCategory? _selectedCategory;
  String _sortBy = 'name'; // name, quantity, value, date

  List<InventoryItem> get items => _filteredItems;
  List<InventoryItem> get allItems => _items;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  ItemCategory? get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;

  // ── Stats ────────────────────────────────────────────────────────────────
  int get totalItems => _items.length;
  int get lowStockCount => _items.where((i) => i.isLowStock).length;
  int get outOfStockCount => _items.where((i) => i.isOutOfStock).length;
  double get totalInventoryValue =>
      _items.fold(0, (sum, i) => sum + i.totalValue);

  List<InventoryItem> get lowStockItems =>
      _items.where((i) => i.isLowStock || i.isOutOfStock).toList();

  Map<ItemCategory, int> get categoryBreakdown {
    final map = <ItemCategory, int>{};
    for (final item in _items) {
      map[item.category] = (map[item.category] ?? 0) + 1;
    }
    return map;
  }

  // ── Filtering ─────────────────────────────────────────────────────────────
  List<InventoryItem> get _filteredItems {
    var list = _items.toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((i) =>
              i.name.toLowerCase().contains(q) ||
              i.sku.toLowerCase().contains(q) ||
              (i.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    if (_selectedCategory != null) {
      list = list.where((i) => i.category == _selectedCategory).toList();
    }

    switch (_sortBy) {
      case 'quantity':
        list.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'value':
        list.sort((a, b) => b.totalValue.compareTo(a.totalValue));
        break;
      case 'date':
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      default:
        list.sort((a, b) => a.name.compareTo(b.name));
    }

    return list;
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setCategory(ItemCategory? cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void setSortBy(String s) {
    _sortBy = s;
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────
  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('inventory_items');
      if (raw != null) {
        final List decoded = jsonDecode(raw);
        _items = decoded.map((e) => InventoryItem.fromJson(e)).toList();
      } else {
        _items = _sampleData();
        await _persist();
      }
    } catch (_) {
      _items = _sampleData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    _items.add(item);
    await _persist();
    notifyListeners();
  }

  Future<void> updateItem(InventoryItem updated) async {
    final idx = _items.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      _items[idx] = updated;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> adjustStock(
      String itemId, int delta, String note) async {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;

    final item = _items[idx];
    final newQty = (item.quantity + delta).clamp(0, 999999);
    final activity = StockActivity(
      id: _uuid.v4(),
      date: DateTime.now(),
      quantityChange: delta,
      note: note,
    );

    _items[idx] = item.copyWith(
      quantity: newQty,
      updatedAt: DateTime.now(),
    );
    _items[idx].activityLog.insert(0, activity);

    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'inventory_items',
      jsonEncode(_items.map((i) => i.toJson()).toList()),
    );
  }

  // ── Sample seed data ──────────────────────────────────────────────────────
  List<InventoryItem> _sampleData() {
    final now = DateTime.now();
    return [
      InventoryItem(
        id: _uuid.v4(), name: 'MacBook Pro 14"', sku: 'MBP-14-M3',
        category: ItemCategory.electronics, quantity: 12,
        lowStockThreshold: 5, costPrice: 1599, sellingPrice: 1999,
        description: 'Apple M3 chip, 16GB RAM', location: 'Shelf A1',
        createdAt: now, updatedAt: now,
      ),
      InventoryItem(
        id: _uuid.v4(), name: 'Wireless Earbuds Pro', sku: 'WEP-200',
        category: ItemCategory.electronics, quantity: 3,
        lowStockThreshold: 8, costPrice: 45, sellingPrice: 89.99,
        description: 'ANC, 30hr battery life', location: 'Shelf A2',
        createdAt: now, updatedAt: now,
      ),
      InventoryItem(
        id: _uuid.v4(), name: 'Classic White Tee', sku: 'CWT-M-001',
        category: ItemCategory.clothing, quantity: 0,
        lowStockThreshold: 20, costPrice: 8, sellingPrice: 24.99,
        description: 'Organic cotton, size M', location: 'Rack B3',
        createdAt: now, updatedAt: now,
      ),
      InventoryItem(
        id: _uuid.v4(), name: 'Standing Desk Mat', sku: 'SDM-XL',
        category: ItemCategory.office, quantity: 34,
        lowStockThreshold: 10, costPrice: 22, sellingPrice: 49.99,
        location: 'Shelf C1',
        createdAt: now, updatedAt: now,
      ),
      InventoryItem(
        id: _uuid.v4(), name: 'Protein Powder (Vanilla)', sku: 'PP-VAN-1KG',
        category: ItemCategory.food, quantity: 7,
        lowStockThreshold: 15, costPrice: 18, sellingPrice: 39.99,
        description: '1kg, Whey Isolate', location: 'Shelf D2',
        createdAt: now, updatedAt: now,
      ),
      InventoryItem(
        id: _uuid.v4(), name: 'Cordless Drill 18V', sku: 'CD-18V-PRO',
        category: ItemCategory.tools, quantity: 19,
        lowStockThreshold: 5, costPrice: 65, sellingPrice: 129.99,
        location: 'Cage E1',
        createdAt: now, updatedAt: now,
      ),
      InventoryItem(
        id: _uuid.v4(), name: 'Moisturizer SPF 50', sku: 'MST-SPF50',
        category: ItemCategory.beauty, quantity: 45,
        lowStockThreshold: 20, costPrice: 9, sellingPrice: 22.99,
        location: 'Shelf F3',
        createdAt: now, updatedAt: now,
      ),
      InventoryItem(
        id: _uuid.v4(), name: 'Yoga Mat Premium', sku: 'YM-6MM-BLK',
        category: ItemCategory.sports, quantity: 2,
        lowStockThreshold: 8, costPrice: 25, sellingPrice: 64.99,
        description: '6mm non-slip, 183cm', location: 'Shelf G1',
        createdAt: now, updatedAt: now,
      ),
    ];
  }
}

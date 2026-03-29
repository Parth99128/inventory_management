import 'dart:convert';

enum ItemCategory {
  electronics,
  clothing,
  food,
  furniture,
  tools,
  office,
  beauty,
  sports,
  other,
}

extension ItemCategoryExtension on ItemCategory {
  String get label {
    switch (this) {
      case ItemCategory.electronics: return 'Electronics';
      case ItemCategory.clothing: return 'Clothing';
      case ItemCategory.food: return 'Food';
      case ItemCategory.furniture: return 'Furniture';
      case ItemCategory.tools: return 'Tools';
      case ItemCategory.office: return 'Office';
      case ItemCategory.beauty: return 'Beauty';
      case ItemCategory.sports: return 'Sports';
      case ItemCategory.other: return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case ItemCategory.electronics: return '💻';
      case ItemCategory.clothing: return '👕';
      case ItemCategory.food: return '🍎';
      case ItemCategory.furniture: return '🪑';
      case ItemCategory.tools: return '🔧';
      case ItemCategory.office: return '📎';
      case ItemCategory.beauty: return '💄';
      case ItemCategory.sports: return '⚽';
      case ItemCategory.other: return '📦';
    }
  }
}

class StockActivity {
  final String id;
  final DateTime date;
  final int quantityChange;
  final String note;

  StockActivity({
    required this.id,
    required this.date,
    required this.quantityChange,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'quantityChange': quantityChange,
    'note': note,
  };

  factory StockActivity.fromJson(Map<String, dynamic> json) => StockActivity(
    id: json['id'],
    date: DateTime.parse(json['date']),
    quantityChange: json['quantityChange'],
    note: json['note'],
  );
}

class InventoryItem {
  final String id;
  String name;
  String sku;
  ItemCategory category;
  int quantity;
  int lowStockThreshold;
  double costPrice;
  double sellingPrice;
  String? description;
  String? location;
  List<StockActivity> activityLog;
  final DateTime createdAt;
  DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.quantity,
    this.lowStockThreshold = 10,
    required this.costPrice,
    required this.sellingPrice,
    this.description,
    this.location,
    List<StockActivity>? activityLog,
    required this.createdAt,
    required this.updatedAt,
  }) : activityLog = activityLog ?? [];

  bool get isLowStock => quantity <= lowStockThreshold && quantity > 0;
  bool get isOutOfStock => quantity == 0;
  double get totalValue => quantity * costPrice;
  double get margin => sellingPrice > 0
      ? ((sellingPrice - costPrice) / sellingPrice) * 100
      : 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sku': sku,
    'category': category.index,
    'quantity': quantity,
    'lowStockThreshold': lowStockThreshold,
    'costPrice': costPrice,
    'sellingPrice': sellingPrice,
    'description': description,
    'location': location,
    'activityLog': activityLog.map((a) => a.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'],
    name: json['name'],
    sku: json['sku'],
    category: ItemCategory.values[json['category']],
    quantity: json['quantity'],
    lowStockThreshold: json['lowStockThreshold'] ?? 10,
    costPrice: (json['costPrice'] as num).toDouble(),
    sellingPrice: (json['sellingPrice'] as num).toDouble(),
    description: json['description'],
    location: json['location'],
    activityLog: (json['activityLog'] as List<dynamic>?)
        ?.map((a) => StockActivity.fromJson(a))
        .toList() ?? [],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  InventoryItem copyWith({
    String? name,
    String? sku,
    ItemCategory? category,
    int? quantity,
    int? lowStockThreshold,
    double? costPrice,
    double? sellingPrice,
    String? description,
    String? location,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      description: description ?? this.description,
      location: location ?? this.location,
      activityLog: activityLog,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

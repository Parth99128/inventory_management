# 📦 Stockr — Inventory Management App

A production-ready Flutter inventory tracking app with a dark, industrial aesthetic.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Dashboard** | Live stats: total items, value, low/out-of-stock counts, category breakdown |
| **Inventory List** | Search, filter by category, sort by name/quantity/value/date |
| **Item Detail** | Full item info, pricing margin, stock history log |
| **Stock Adjustment** | Inline +/- controls with optional notes + full activity log |
| **Add / Edit Items** | Full form: name, SKU, category, location, pricing, threshold |
| **Swipe to Delete** | With confirmation dialog |
| **Alerts Screen** | Dedicated view for out-of-stock + low stock items |
| **Reports Screen** | Summary stats, top items by value, value by category |
| **Persistent Storage** | `shared_preferences` — survives app restarts |
| **Sample Data** | 8 seed items across all categories on first launch |

---

## 🎨 Design

- **Aesthetic**: Dark industrial — deep navy/charcoal background, electric green accent (`#00E5A0`)
- **Typography**: Space Grotesk (headings) + DM Sans (body)
- **Status Colors**: Green = in stock · Amber = low stock · Red = out of stock

---

## 🚀 Setup

### Prerequisites
- Flutter SDK ≥ 3.0.0 — [install guide](https://docs.flutter.dev/get-started/install)
- Dart ≥ 3.0.0 (bundled with Flutter)

### Run the app

```bash
cd stockr
flutter pub get
flutter run
```

### Build for production

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Android App Bundle (Play Store)
flutter build appbundle --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry + ThemeData
├── models/
│   └── inventory_item.dart      # InventoryItem + StockActivity models
├── providers/
│   └── inventory_provider.dart  # State management (ChangeNotifier)
├── screens/
│   ├── home_screen.dart         # Bottom nav shell
│   ├── dashboard_screen.dart    # Overview + stats
│   ├── inventory_screen.dart    # Searchable item list
│   ├── item_detail_screen.dart  # Detail + stock adjustment
│   ├── add_edit_item_screen.dart# Add/edit form
│   ├── alerts_screen.dart       # Low/out-of-stock alerts
│   └── reports_screen.dart      # Analytics & value reports
└── widgets/
    ├── stat_card.dart           # Reusable stat card
    └── item_tile.dart           # Item list row with swipe-to-delete
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `shared_preferences` | Local persistence |
| `uuid` | Unique item IDs |
| `intl` | Currency/date formatting |
| `google_fonts` | Space Grotesk + DM Sans |
| `flutter_animate` | Animations (optional extension point) |

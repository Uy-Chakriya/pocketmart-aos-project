# PocketMart

PocketMart is a small shopping app built with Flutter. Customers can browse products, add them to a cart, and place cash-on-delivery orders. An admin manages the products, categories and orders from a dashboard.

All data is stored on the device in a local SQLite database. The app does not need a server or an internet connection.

## Features

### Customer

- **Account:** register, log in, "Remember me", edit profile, log out
- **Shopping:** browse by category, search products, view product details and stock, keep a wishlist
- **Cart:** add products, change quantities (limited by stock), remove items, see subtotal, delivery fee and total
- **Checkout:** enter a delivery address and phone, then pay with cash on delivery
- **Orders:** order history (newest first), order details and status, export a receipt as a `.txt` file

### Admin

- **Dashboard:** total products, orders and revenue, average order value, low-stock alerts, recent orders
- **Products:** add, edit and delete products (name, price, stock, category, description, icon)
- **Categories:** add, edit and delete categories
- **Orders:** view all orders and update their status (Pending → Delivering → Completed)
- **Reports:** export a sales report as a `.txt` file

## Tech stack

| Package | Used for |
|---|---|
| `provider` | App state |
| `sqflite`, `path` | Local SQLite database |
| `shared_preferences` | "Remember me" session |
| `crypto` | SHA-256 password hashing |
| `csv` | Reading starting products from `assets/products.csv` |
| `path_provider`, `share_plus` | Saving and sharing exported `.txt` files |
| `sqflite_common_ffi` (dev) | Running the database in unit tests |

## Getting started

### Requirements

- Flutter SDK with Dart 3.x
- Android Studio or VS Code with the Flutter extension
- An Android emulator, iOS simulator or physical device

### Run the app

```bash
flutter pub get
flutter run
```

On first launch the app:

1. Creates the `pocketmart.db` database and a default admin account
2. Loads the starting products and categories from `assets/products.csv`
3. Adds a few demo customers and orders, so the admin dashboard has data to show

To use the app as a customer, tap **Create account** on the login screen.

### Run the tests

```bash
flutter test
```

The tests cover loading the catalog, registration and login, profile updates, the wishlist, cart and stock rules, placing orders, and the admin features.

## Project structure

```
lib/
├── main.dart                 App entry point
├── theme.dart                Colors and text styles
├── strings.dart              All text shown in the app
├── utils.dart                Validation, CSV reader, session, .txt export
├── database/
│   └── db_helper.dart        SQLite tables, seed data and queries
├── models/
│   └── models.dart           User, Category, Product, CartItem, Order, OrderItem
├── providers/
│   └── app_state.dart        Session, catalog, cart, wishlist and orders
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_shell.dart       Bottom navigation (Home, Cart, Orders, Profile)
│   ├── home_screen.dart
│   ├── product_detail_screen.dart
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   ├── order_success_screen.dart
│   ├── orders_screen.dart
│   ├── order_detail_screen.dart
│   ├── profile_screen.dart
│   ├── admin_dashboard_screen.dart
│   ├── admin_products_screen.dart
│   ├── admin_categories_screen.dart
│   └── admin_orders_screen.dart
└── widgets/
    └── common.dart           Shared buttons, chips, steppers and fields

assets/
├── products.csv              Starting products
└── images/products/          Product photos

test/
└── widget_test.dart          Tests for catalog, customer and admin flows
```

## Data storage

Everything is saved on the device:

- **SQLite database** (`pocketmart.db`): tables for users, categories, products, cart, orders, order items and wishlist. Passwords are stored as SHA-256 hashes, not plain text.
- **Shared preferences:** the logged-in user's ID when "Remember me" is ticked.

The data stays between app restarts. It is deleted when the app is uninstalled or its data is cleared. To browse the tables while the app runs, use Android Studio's **App Inspection → Database Inspector**.

## Changing the starting products

Edit `assets/products.csv`. Each row has these columns:

```
category,name,price,stock,icon,description
```

To show a photo for a product, add an image to `assets/images/products/`. The file name is the product name in lowercase with spaces replaced by underscores, for example `ceramic_mug.png`.

Products are only loaded when the database has none, so uninstall the app or clear its data to see your changes.

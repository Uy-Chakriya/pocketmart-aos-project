class AppUser {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? name : parts.first;
  }

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  factory AppUser.fromMap(Map<String, Object?> m) => AppUser(
        id: m['id'] as int,
        name: m['name'] as String,
        email: m['email'] as String,
        phone: m['phone'] as String,
        address: (m['address'] as String?) ?? '',
        role: m['role'] as String,
      );
}

class Category {
  final int id;
  final String name;
  const Category({required this.id, required this.name});

  factory Category.fromMap(Map<String, Object?> m) =>
      Category(id: m['id'] as int, name: m['name'] as String);
}

class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final String image; // icon key, see productIcons
  final int stock;
  final int categoryId;
  final String categoryName;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.stock,
    required this.categoryId,
    required this.categoryName,
  });

  factory Product.fromMap(Map<String, Object?> m) => Product(
        id: m['id'] as int,
        name: m['name'] as String,
        price: (m['price'] as num).toDouble(),
        description: (m['description'] as String?) ?? '',
        image: (m['image'] as String?) ?? 'box',
        stock: m['stock'] as int,
        categoryId: (m['category_id'] as int?) ?? 0,
        categoryName: (m['category_name'] as String?) ?? '',
      );
}

class CartItem {
  final int id;
  final int quantity;
  final Product product;

  const CartItem({
    required this.id,
    required this.quantity,
    required this.product,
  });

  factory CartItem.fromMap(Map<String, Object?> m) => CartItem(
        id: m['cart_id'] as int,
        quantity: m['cart_qty'] as int,
        product: Product.fromMap(m),
      );
}

class Order {
  final int id;
  final int userId;
  final String userName;
  final double total;
  final String address;
  final String phone;
  final String status;
  final String date;
  final int itemCount;

  const Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.total,
    required this.address,
    required this.phone,
    required this.status,
    required this.date,
    required this.itemCount,
  });

  String get number => '#PM-${1000 + id}';

  factory Order.fromMap(Map<String, Object?> m) => Order(
        id: m['id'] as int,
        userId: m['user_id'] as int,
        userName: (m['user_name'] as String?) ?? '',
        total: (m['total'] as num).toDouble(),
        address: m['address'] as String,
        phone: m['phone'] as String,
        status: m['status'] as String,
        date: m['order_date'] as String,
        itemCount: (m['item_count'] as int?) ?? 0,
      );
}

class OrderItem {
  final int productId;
  final String name;
  final String image;
  final int quantity;
  final double price; // price at the time of purchase

  const OrderItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => quantity * price;

  factory OrderItem.fromMap(Map<String, Object?> m) => OrderItem(
        productId: m['product_id'] as int,
        name: m['product_name'] as String,
        image: m['product_image'] as String,
        quantity: m['quantity'] as int,
        price: (m['price'] as num).toDouble(),
      );
}

class AdminStats {
  final int products;
  final int orders;
  final double revenue;
  final int lowStock;

  const AdminStats({
    required this.products,
    required this.orders,
    required this.revenue,
    required this.lowStock,
  });
}

/// One parsed line of assets/products.csv
class SeedProduct {
  final String category;
  final String name;
  final double price;
  final int stock;
  final String icon;
  final String description;

  const SeedProduct({
    required this.category,
    required this.name,
    required this.price,
    required this.stock,
    required this.icon,
    required this.description,
  });
}

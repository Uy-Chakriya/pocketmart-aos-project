import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

const int lowStockLimit = 5;

String hashPassword(String password) =>
    sha256.convert(utf8.encode(password)).toString();

String _now() => DateTime.now().toString().substring(0, 16);

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'pocketmart.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            phone TEXT NOT NULL,
            password TEXT NOT NULL,
            address TEXT NOT NULL DEFAULT '',
            role TEXT NOT NULL DEFAULT 'customer'
          )
        """);
        await db.execute("""
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL COLLATE NOCASE UNIQUE
          )
        """);
        await db.execute("""
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            image TEXT NOT NULL DEFAULT 'box',
            stock INTEGER NOT NULL,
            category_id INTEGER NOT NULL
          )
        """);
        await db.execute("""
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL
          )
        """);
        await db.execute("""
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            total REAL NOT NULL,
            address TEXT NOT NULL,
            phone TEXT NOT NULL,
            status TEXT NOT NULL,
            order_date TEXT NOT NULL
          )
        """);
        await db.execute("""
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            product_name TEXT NOT NULL,
            product_image TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL
          )
        """);
        await db.execute("""
          CREATE TABLE wishlist (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            UNIQUE (user_id, product_id)
          )
        """);

        // Default admin account.
        await db.insert('users', {
          'name': 'Admin',
          'email': 'admin@pocketmart.com',
          'phone': '012000000',
          'password': hashPassword('admin123'),
          'address': '',
          'role': 'admin',
        });
      },
      onOpen: _syncDefaultAccounts,
    );
  }

  /// Keeps the default logins up to date on databases created by older
  /// versions of the app (onCreate only runs on a fresh install).
  Future<void> _syncDefaultAccounts(Database db) async {
    // old email, name, new email, password, role, phone, address
    const accounts = [
      [
        'admin@gmail.com',
        'Admin',
        'admin@pocketmart.com',
        'admin123',
        'admin',
        '012000000',
        '',
      ],
      [
        'chakriya@gmail.com',
        'ya',
        'ya@gmail.com',
        'ya123456',
        'customer',
        '012345111',
        'St. 271, Phnom Penh',
      ],
    ];
    for (final a in accounts) {
      final values = {
        'name': a[1],
        'email': a[2],
        'password': hashPassword(a[3]),
      };
      final updated = await db.update(
        'users',
        values,
        where: 'email = ?',
        whereArgs: [a[2]],
      );
      if (updated > 0) continue;
      final renamed = await db.update(
        'users',
        values,
        where: 'email = ?',
        whereArgs: [a[0]],
      );
      if (renamed > 0) continue;
      await db.insert('users', {
        ...values,
        'phone': a[5],
        'address': a[6],
        'role': a[4],
      });
    }
  }

  // ---------- Seed data from products.csv ----------

  Future<void> seedProducts(List<SeedProduct> rows) async {
    final db = await database;
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM products'),
        ) ??
        0;
    if (count > 0 || rows.isEmpty) return;

    await db.transaction((txn) async {
      final ids = <String, int>{};
      for (final r in rows) {
        final key = r.category.toLowerCase();
        if (!ids.containsKey(key)) {
          ids[key] = await txn.insert('categories', {'name': r.category});
        }
        await txn.insert('products', {
          'name': r.name,
          'price': r.price,
          'description': r.description,
          'image': r.icon,
          'stock': r.stock,
          'category_id': ids[key],
        });
      }
    });
  }

  // ---------- Demo orders ----------

  /// Adds demo customers with past orders when there are no orders yet, so
  /// the admin dashboard has data to show.
  Future<void> seedDemoOrders() async {
    final db = await database;
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM orders'),
        ) ??
        0;
    if (count > 0) return;

    // name, email, phone, address, password
    const customers = [
      ['ya', 'ya@gmail.com', '012345111', 'St. 271, Phnom Penh', 'ya123456'],
      [
        'Dara Kim',
        'dara@demo.com',
        '012345222',
        'Sihanouk Blvd, Phnom Penh',
        'demo123',
      ],
      [
        'Vanna Lim',
        'vanna@demo.com',
        '012345333',
        'Riverside, Siem Reap',
        'demo123',
      ],
    ];
    // customer index, days ago, status, [product name, qty]...
    const orders = [
      [
        0,
        9,
        'Completed',
        [
          ['Ceramic Mug', 2],
          ['Notebook A5', 3],
        ],
      ],
      [
        1,
        7,
        'Completed',
        [
          ['Linen Tote Bag', 1],
          ['Cotton T-Shirt', 2],
        ],
      ],
      [
        2,
        5,
        'Completed',
        [
          ['Desk Plant', 1],
          ['Scented Candle', 1],
        ],
      ],
      [
        0,
        3,
        'Delivering',
        [
          ['Wool Scarf', 1],
          ['Lip Balm Set', 2],
        ],
      ],
      [
        1,
        2,
        'Delivering',
        [
          ['Daily Hand Cream', 2],
        ],
      ],
      [
        2,
        1,
        'Pending',
        [
          ['Cotton T-Shirt', 1],
          ['Ceramic Mug', 1],
        ],
      ],
      [
        0,
        0,
        'Pending',
        [
          ['Scented Candle', 2],
          ['Notebook A5', 1],
        ],
      ],
    ];

    await db.transaction((txn) async {
      final products = <String, Map<String, Object?>>{
        for (final p in await txn.query('products')) p['name'] as String: p,
      };

      final userIds = <int>[];
      for (final c in customers) {
        final found = await txn.query(
          'users',
          where: 'email = ?',
          whereArgs: [c[1]],
          limit: 1,
        );
        userIds.add(
          found.isNotEmpty
              ? found.first['id'] as int
              : await txn.insert('users', {
                  'name': c[0],
                  'email': c[1],
                  'phone': c[2],
                  'password': hashPassword(c[4]),
                  'address': c[3],
                  'role': 'customer',
                }),
        );
      }

      for (final o in orders) {
        final lines = (o[3] as List)
            .where((l) => products.containsKey(l[0]))
            .toList();
        if (lines.isEmpty) continue;
        final customer = customers[o[0] as int];
        final date = DateTime.now()
            .subtract(Duration(days: o[1] as int, hours: 2))
            .toString()
            .substring(0, 16);
        final subtotal = lines.fold<double>(
          0,
          (s, l) =>
              s + (products[l[0]]!['price'] as num).toDouble() * (l[1] as int),
        );

        final orderId = await txn.insert('orders', {
          'user_id': userIds[o[0] as int],
          'total': subtotal + 1.50,
          'address': customer[3],
          'phone': customer[2],
          'status': o[2],
          'order_date': date,
        });
        for (final l in lines) {
          final p = products[l[0]]!;
          await txn.insert('order_items', {
            'order_id': orderId,
            'product_id': p['id'],
            'product_name': p['name'],
            'product_image': p['image'],
            'quantity': l[1],
            'price': p['price'],
          });
        }
      }
    });
  }

  // ---------- Users ----------

  Future<AppUser?> getUser(int id) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<AppUser> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final db = await database;
    final exists = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (exists.isNotEmpty) {
      throw Exception('This email is already registered.');
    }
    final id = await db.insert('users', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': hashPassword(password),
      'address': '',
      'role': 'customer',
    });
    return (await getUser(id))!;
  }

  Future<AppUser?> login(String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashPassword(password)],
      limit: 1,
    );
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<void> updateProfile(
    int id,
    String name,
    String phone,
    String address,
  ) async {
    final db = await database;
    await db.update(
      'users',
      {'name': name, 'phone': phone, 'address': address},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- Categories ----------

  Future<List<Category>> getCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'id');
    return rows.map(Category.fromMap).toList();
  }

  Future<void> insertCategory(String name) async {
    final db = await database;
    try {
      await db.insert('categories', {'name': name});
    } on DatabaseException {
      throw Exception('This category already exists.');
    }
  }

  Future<void> updateCategory(int id, String name) async {
    final db = await database;
    try {
      await db.update(
        'categories',
        {'name': name},
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DatabaseException {
      throw Exception('This category already exists.');
    }
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    final used =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM products WHERE category_id = ?',
            [id],
          ),
        ) ??
        0;
    if (used > 0) {
      throw Exception('Move or delete the products in this category first.');
    }
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Products ----------

  Future<List<Product>> getProducts() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT p.*, c.name AS category_name FROM products p '
      'LEFT JOIN categories c ON c.id = p.category_id ORDER BY p.id',
    );
    return rows.map(Product.fromMap).toList();
  }

  Future<void> insertProduct(Map<String, Object?> data) async {
    final db = await database;
    await db.insert('products', data);
  }

  Future<void> updateProduct(int id, Map<String, Object?> data) async {
    final db = await database;
    await db.update('products', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    await db.delete('cart', where: 'product_id = ?', whereArgs: [id]);
    await db.delete('wishlist', where: 'product_id = ?', whereArgs: [id]);
  }

  // ---------- Cart ----------

  Future<List<CartItem>> getCart(int userId) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT c.id AS cart_id, c.quantity AS cart_qty, p.*, '
      'cat.name AS category_name FROM cart c '
      'JOIN products p ON p.id = c.product_id '
      'LEFT JOIN categories cat ON cat.id = p.category_id '
      'WHERE c.user_id = ? ORDER BY c.id',
      [userId],
    );
    return rows.map(CartItem.fromMap).toList();
  }

  Future<void> addToCart(int userId, int productId, int qty) async {
    final db = await database;
    await db.transaction((txn) async {
      final prod = await txn.query(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
        limit: 1,
      );
      if (prod.isEmpty) throw Exception('Product not found.');
      final stock = prod.first['stock'] as int;
      final rows = await txn.query(
        'cart',
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
        limit: 1,
      );
      final current = rows.isEmpty ? 0 : rows.first['quantity'] as int;
      if (current + qty > stock) throw Exception('Only $stock in stock.');
      if (rows.isEmpty) {
        await txn.insert('cart', {
          'user_id': userId,
          'product_id': productId,
          'quantity': qty,
        });
      } else {
        await txn.update(
          'cart',
          {'quantity': current + qty},
          where: 'id = ?',
          whereArgs: [rows.first['id']],
        );
      }
    });
  }

  Future<void> setCartQty(int cartId, int qty) async {
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.rawQuery(
        'SELECT p.stock AS stock FROM cart c '
        'JOIN products p ON p.id = c.product_id WHERE c.id = ?',
        [cartId],
      );
      if (rows.isEmpty) return;
      final stock = rows.first['stock'] as int;
      if (qty > stock) throw Exception('Only $stock in stock.');
      await txn.update(
        'cart',
        {'quantity': qty},
        where: 'id = ?',
        whereArgs: [cartId],
      );
    });
  }

  Future<void> removeCartItem(int cartId) async {
    final db = await database;
    await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
  }

  // ---------- Wishlist ----------

  Future<Set<int>> getWishlist(int userId) async {
    final db = await database;
    final rows = await db.query(
      'wishlist',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return rows.map((r) => r['product_id'] as int).toSet();
  }

  Future<void> toggleWishlist(int userId, int productId) async {
    final db = await database;
    final rows = await db.query(
      'wishlist',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
      limit: 1,
    );
    if (rows.isEmpty) {
      await db.insert('wishlist', {'user_id': userId, 'product_id': productId});
    } else {
      await db.delete(
        'wishlist',
        where: 'id = ?',
        whereArgs: [rows.first['id']],
      );
    }
  }

  // ---------- Orders ----------

  /// Creates the order, copies the cart lines into order_items with the
  /// current price, reduces stock, and clears the cart. One transaction.
  Future<int> placeOrder(
    int userId,
    String address,
    String phone,
    double fee,
  ) async {
    final db = await database;
    return db.transaction<int>((txn) async {
      final items = await txn.rawQuery(
        'SELECT c.quantity AS qty, p.* FROM cart c '
        'JOIN products p ON p.id = c.product_id WHERE c.user_id = ?',
        [userId],
      );
      if (items.isEmpty) throw Exception('Your cart is empty.');

      var subtotal = 0.0;
      for (final r in items) {
        final qty = r['qty'] as int;
        final stock = r['stock'] as int;
        if (qty > stock) {
          throw Exception('Not enough stock for ${r['name']}.');
        }
        subtotal += qty * (r['price'] as num).toDouble();
      }

      final orderId = await txn.insert('orders', {
        'user_id': userId,
        'total': subtotal + fee,
        'address': address,
        'phone': phone,
        'status': 'Pending',
        'order_date': _now(),
      });

      for (final r in items) {
        final qty = r['qty'] as int;
        await txn.insert('order_items', {
          'order_id': orderId,
          'product_id': r['id'],
          'product_name': r['name'],
          'product_image': r['image'],
          'quantity': qty,
          'price': r['price'],
        });
        await txn.update(
          'products',
          {'stock': (r['stock'] as int) - qty},
          where: 'id = ?',
          whereArgs: [r['id']],
        );
      }

      await txn.delete('cart', where: 'user_id = ?', whereArgs: [userId]);
      return orderId;
    });
  }

  Future<List<Order>> _orderQuery(
    String where,
    List<Object?> args, {
    int? limit,
  }) async {
    final db = await database;
    final limitSql = limit == null ? '' : 'LIMIT $limit';
    final rows = await db.rawQuery(
      'SELECT o.*, u.name AS user_name, '
      '(SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.id) '
      'AS item_count FROM orders o '
      'LEFT JOIN users u ON u.id = o.user_id '
      '$where ORDER BY o.id DESC $limitSql',
      args,
    );
    return rows.map(Order.fromMap).toList();
  }

  Future<List<Order>> getOrders({int? userId, int? limit}) {
    if (userId == null) return _orderQuery('', [], limit: limit);
    return _orderQuery('WHERE o.user_id = ?', [userId], limit: limit);
  }

  Future<Order> getOrder(int id) async {
    final list = await _orderQuery('WHERE o.id = ?', [id]);
    return list.first;
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = await database;
    final rows = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'id',
    );
    return rows.map(OrderItem.fromMap).toList();
  }

  Future<void> updateOrderStatus(int id, String status) async {
    final db = await database;
    await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- Admin stats ----------

  Future<AdminStats> getStats() async {
    final db = await database;
    final products =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM products'),
        ) ??
        0;
    final orders =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM orders'),
        ) ??
        0;
    final low =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM products WHERE stock <= ?', [
            lowStockLimit,
          ]),
        ) ??
        0;
    final rev = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) AS s FROM orders',
    );
    return AdminStats(
      products: products,
      orders: orders,
      revenue: (rev.first['s'] as num).toDouble(),
      lowStock: low,
    );
  }
}

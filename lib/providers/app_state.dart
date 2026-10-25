import 'package:flutter/foundation.dart' hide Category;

import '../database/db_helper.dart';
import '../models/models.dart';
import '../utils.dart';

class AppState extends ChangeNotifier {
  static const double deliveryFee = 1.50;

  final DbHelper _db = DbHelper.instance;
  final SessionManager _session = SessionManager();

  bool ready = false;
  String? initError;
  int tab = 0;

  AppUser? user;
  List<Category> categories = [];
  List<Product> products = [];
  List<CartItem> cart = [];
  Set<int> wishlist = {};
  List<Order> orders = [];

  // ---------- Startup ----------

  Future<void> init() async {
    try {
      final rows = await CsvLoader.loadProducts('assets/products.csv');
      await _db.seedProducts(rows);
      await _db.seedDemoOrders();
      final id = await _session.getUserId();
      if (id != null) user = await _db.getUser(id);
      await loadCatalog(notify: false);
      if (user != null) await _loadUserData();
      ready = true;
    } catch (e) {
      initError = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadCatalog({bool notify = true}) async {
    categories = await _db.getCategories();
    products = await _db.getProducts();
    if (notify) notifyListeners();
  }

  Future<void> _loadUserData() async {
    final u = user;
    if (u == null) return;
    cart = await _db.getCart(u.id);
    wishlist = await _db.getWishlist(u.id);
    orders = await _db.getOrders(userId: u.id);
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  // ---------- Account ----------

  Future<void> login(String email, String password, bool remember) async {
    final u = await _db.login(email, password);
    if (u == null) throw Exception('Wrong email or password.');
    user = u;
    if (remember) {
      await _session.save(u.id);
    } else {
      await _session.clear();
    }
    await loadCatalog(notify: false);
    await _loadUserData();
    tab = 0;
    notifyListeners();
  }

  Future<void> register(
      String name, String email, String phone, String password) async {
    final u = await _db.registerUser(
        name: name, email: email, phone: phone, password: password);
    user = u;
    await _session.save(u.id);
    await loadCatalog(notify: false);
    await _loadUserData();
    tab = 0;
    notifyListeners();
  }

  Future<void> logout() async {
    await _session.clear();
    user = null;
    cart = [];
    wishlist = {};
    orders = [];
    tab = 0;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String phone, String address) async {
    final u = user!;
    await _db.updateProfile(u.id, name, phone, address);
    user = await _db.getUser(u.id);
    notifyListeners();
  }

  // ---------- Cart ----------

  double get subtotal =>
      cart.fold(0.0, (s, c) => s + c.product.price * c.quantity);

  double get total => cart.isEmpty ? 0 : subtotal + deliveryFee;

  Future<void> addToCart(int productId, int qty) async {
    await _db.addToCart(user!.id, productId, qty);
    cart = await _db.getCart(user!.id);
    notifyListeners();
  }

  Future<void> changeQty(CartItem item, int qty) async {
    if (qty < 1) return;
    await _db.setCartQty(item.id, qty);
    cart = await _db.getCart(user!.id);
    notifyListeners();
  }

  Future<void> removeItem(CartItem item) async {
    await _db.removeCartItem(item.id);
    cart = await _db.getCart(user!.id);
    notifyListeners();
  }

  Future<void> toggleWishlist(int productId) async {
    await _db.toggleWishlist(user!.id, productId);
    wishlist = await _db.getWishlist(user!.id);
    notifyListeners();
  }

  // ---------- Orders ----------

  Future<Order> placeOrder(String address, String phone) async {
    final id = await _db.placeOrder(user!.id, address, phone, deliveryFee);
    cart = [];
    await loadCatalog(notify: false);
    orders = await _db.getOrders(userId: user!.id);
    final order = await _db.getOrder(id);
    notifyListeners();
    return order;
  }
}

/// All text shown in the app lives here (the Flutter version of strings.xml).
class S {
  S._();

  static const appName = 'PocketMart';

  // Navigation
  static const navHome = 'Home';
  static const navCart = 'Cart';
  static const navOrders = 'Orders';
  static const navProfile = 'Profile';

  // Login and register
  static const welcomeBack = 'Welcome back';
  static const loginSubtitle = 'Sign in to PocketMart to continue shopping.';
  static const email = 'Email';
  static const emailHint = 'chakriya@email.com';
  static const password = 'Password';
  static const passwordHint = 'Password';
  static const passwordHelper = 'At least 6 characters';
  static const rememberMe = 'Remember me';
  static const logIn = 'Log in';
  static const newToApp = 'New to PocketMart? ';
  static const createAccount = 'Create account';
  static const createSubtitle = 'Join PocketMart in less than a minute.';
  static const fullName = 'Full name';
  static const fullNameHint = 'Dara Sok';
  static const phone = 'Phone';
  static const phoneHint = '012 345 678';
  static const haveAccount = 'Already have an account? ';
  static const errRequired = 'This field is required';
  static const errEmail = 'Please enter a valid email address';
  static const errPhone = 'Please enter a valid phone number';
  static const errPassword = 'Password must be at least 6 characters';
  static const errPrice = 'Enter a price, 0 or more';
  static const errStock = 'Enter a whole number, 0 or more';

  // Home
  static String hello(String name) => 'Hello, $name';
  static const searchHint = 'Search products';
  static const bannerTag = 'NEW IN';
  static const bannerTitle = 'Autumn Essentials';
  static const bannerSub = 'Up to 20% off this week';
  static const shopNow = 'Shop now';
  static const all = 'All';
  static const popular = 'Popular';
  static const results = 'Results';
  static const seeAll = 'See all';
  static const noProducts = 'No products found.';
  static const outOfStock = 'Out of stock';

  // Product detail
  static String leftInStock(int n) => '$n left in stock';
  static const description = 'Description';
  static const quantity = 'Quantity';
  static String maxPerOrder(int n) => 'Max $n per order';
  static const currentlyUnavailable = 'Currently unavailable';
  static const addToCart = 'Add to cart';
  static const addedToCart = 'Added to cart';

  // Cart
  static const myCart = 'My Cart';
  static String itemsCount(int n) => n == 1 ? '1 item' : '$n items';
  static const subtotal = 'Subtotal';
  static const deliveryFee = 'Delivery fee';
  static const total = 'Total';
  static const checkout = 'Checkout';
  static const cartEmpty = 'Your cart is empty';
  static const continueShopping = 'Continue shopping';

  // Checkout and success
  static const deliveryDetails = 'Delivery details';
  static const address = 'Address';
  static const addressHint = 'Street, district, city';
  static const paymentMethod = 'Payment method';
  static const cashOnDelivery = 'Cash on delivery';
  static const cashOnDeliverySub = 'Pay when your order arrives';
  static const orderSummary = 'Order summary';
  static String placeOrder(String total) => 'Place order · $total';
  static const orderPlaced = 'Order placed!';
  static String thankYou(String name) =>
      'Thank you, $name. We are preparing your order now.';
  static const orderNumber = 'Order number';
  static const date = 'Date';
  static const payment = 'Payment';
  static const viewMyOrders = 'View my orders';

  // Orders
  static const myOrders = 'My Orders';
  static const newestFirst = 'Newest first';
  static const noOrders = 'No orders yet.';
  static String itemWord(int n) => n == 1 ? '1 item' : '$n items';
  static String orderTitle(String number) => 'Order $number';
  static String qtyTimes(int q, String price) => 'Qty $q × $price';
  static const exportReceipt = 'Export receipt (.txt)';
  static String savedTo(String path) => 'Saved: $path';
  static String exportFailed(String e) => 'Export failed: $e';

  // Profile
  static const profile = 'Profile';
  static const name = 'Name';
  static const editProfile = 'Edit profile';
  static const saveChanges = 'Save changes';
  static const logOut = 'Log out';
  static const profileSaved = 'Profile updated.';

  // Admin
  static const adminTag = 'ADMIN · POCKETMART';
  static const dashboard = 'Dashboard';
  static const totalProducts = 'Total products';
  static const totalOrders = 'Total orders';
  static const totalRevenue = 'Total revenue';
  static const lowStock = 'Low stock';
  static const products = 'Products';
  static const categories = 'Categories';
  static const orders = 'Orders';
  static const recentOrders = 'Recent orders';
  static const viewAll = 'View all';
  static const goodMorning = 'Good morning';
  static const goodAfternoon = 'Good afternoon';
  static const goodEvening = 'Good evening';
  static const avgOrder = 'Avg. order';
  static const exportReport = 'Export report';
  static const orderStatus = 'Order status';
  static const manage = 'Manage';
  static const needsRestock = 'Needs restock';
  static const allStocked = 'All products are well stocked.';
  static String productsCount(int n) => n == 1 ? '1 product' : '$n products';
  static String categoriesCount(int n) =>
      n == 1 ? '1 category' : '$n categories';
  static String ordersCount(int n) => n == 1 ? '1 order' : '$n orders';
  static String unitsLeft(int n) => n == 0 ? 'Out of stock' : '$n left';
  static const allOrders = 'All orders';
  static const exportSalesReport = 'Export sales report (.txt)';
  static const addProduct = 'Add product';
  static const editProduct = 'Edit product';
  static const productName = 'Product name';
  static const price = 'Price';
  static const stock = 'Stock';
  static const category = 'Category';
  static const icon = 'Icon';
  static const addCategory = 'Add category';
  static const editCategory = 'Edit category';
  static const categoryName = 'Category name';
  static const noCategories = 'No categories yet.';
  static const addCategoryFirst = 'Add a category first.';
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const delete = 'Delete';
  static String deleteQuestion(String name) => 'Delete "$name"?';
}

POCKETMART (Flutter + SQLite)

Admin login: admin@pocketmart.com / admin123
Customer: tap "Create account" on the login screen.

SETUP IN YOUR EXISTING shop_inventory PROJECT
1. Open the Terminal in Android Studio and run:
   flutter pub add shared_preferences crypto
2. Open pubspec.yaml. Find the line "flutter:" near the bottom (no spaces
   before it). Under it, add the assets lines so it looks like this:

flutter:
  uses-material-design: true

  assets:
    - assets/products.csv

   Keep the two spaces before "assets:" and four spaces before "- assets".
3. Copy the assets folder from this zip into the project root, next to
   pubspec.yaml.
4. Delete everything inside the project's lib folder. Copy everything from
   this zip's lib folder into it.
5. Run: flutter pub get
6. Select your emulator or phone and press the green Run button.

FILES
lib/strings.dart            all text shown in the app (like strings.xml)
assets/products.csv         starting products, read on first launch
lib/database/db_helper.dart SQLite tables and queries
lib/models/models.dart      User, Category, Product, CartItem, Order, OrderItem
lib/providers/app_state.dart app state, cart, session, orders
lib/utils.dart              validation, CSV reader, session, .txt export
lib/screens/                the 12 screens plus 3 admin list screens
lib/widgets/common.dart     shared buttons, chips, steppers, fields

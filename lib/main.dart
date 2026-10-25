import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'strings.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PocketMartApp());
}

class PocketMartApp extends StatelessWidget {
  const PocketMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: S.appName,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const Root(),
      ),
    );
  }
}

/// Chooses the first screen from the app state.
class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.initError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Startup error:\n${app.initError}'),
          ),
        ),
      );
    }
    if (!app.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (app.user == null) return const LoginScreen();
    if (app.user!.isAdmin) return const AdminDashboardScreen();
    return const MainShell();
  }
}

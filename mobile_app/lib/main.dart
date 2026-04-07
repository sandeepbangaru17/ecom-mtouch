import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';
import 'services/api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = ApiClient();
  runApp(ShopFlowApp(apiClient: apiClient));
}

class ShopFlowApp extends StatelessWidget {
  const ShopFlowApp({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)..loadSession()),
        ChangeNotifierProvider(create: (_) => ProductProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider(apiClient)),
      ],
      child: MaterialApp(
        title: 'ShopFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFCC5A1A),
            primary: const Color(0xFFCC5A1A),
            secondary: const Color(0xFF2F4858),
            surface: const Color(0xFFF7F1EA),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4EEE8),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
          useMaterial3: true,
        ),
        home: const AppGate(),
      ),
    );
  }
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isBootstrapping) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return auth.isAuthenticated ? const ProductListScreen() : const LoginScreen();
  }
}

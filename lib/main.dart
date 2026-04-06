import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';

// Service & Provider Imports
import 'package:sneaker_recognizer_plateform/services/auth_service.dart';
import 'package:sneaker_recognizer_plateform/providers/cart_provider.dart';
import 'package:sneaker_recognizer_plateform/presentation/app_root.dart';

void main() async {
  // 1. Crucial: Initialize the Flutter binding before any plugin calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configure Stripe
  if (!kIsWeb) {
    try {
      Stripe.publishableKey = "pk_test_your_key"; // Ensure this is your actual key
      Stripe.merchantIdentifier = 'merchant.com.zynex.sneakerapp';
      await Stripe.instance.applySettings();
    } catch (e) {
      // Prevents the app from hanging if Stripe initialization fails
      debugPrint("Stripe Initialization Error: $e");
    }
  }

  // 3. Start the app
  runApp(const MyRoot());
}

class MyRoot extends StatelessWidget {
  const MyRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zynex Sneaker App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const AppRoot(),
    );
  }
}
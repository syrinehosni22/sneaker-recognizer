import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_recognizer_plateform/services/auth_service.dart';
import 'package:sneaker_recognizer_plateform/providers/cart_provider.dart';
import 'package:sneaker_recognizer_plateform/presentation/app_root.dart';

void main() {
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppRoot(),
    );
  }
}
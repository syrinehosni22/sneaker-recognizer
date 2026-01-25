import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_recognizer_plateform/presentation/app_root.dart';
import 'services/auth_service.dart';
import 'providers/cart_provider.dart'; // 👈 import your CartProvider

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 👇 Allow insecure HTTPS (DEV ONLY)
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CartProvider()), // ✅ added
      ],
      child: MaterialApp(
        title: 'Sneaker Recognizer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AppRoot(),
      ),
    );
  }
}

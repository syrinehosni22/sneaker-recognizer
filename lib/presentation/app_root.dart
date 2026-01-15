import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'screens/main/main_screen.dart';
import 'screens/auth/auth_navigator.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    // if (auth.isLoggedIn) {
    return const MainScreen(); // menu + content
    // }

    // // 🔐 Not logged in → auth flow
    // return const AuthNavigator();
  }
}

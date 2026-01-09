import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/presentation/screens/inscription/subscription_page.dart';
import 'package:sneaker_recognizer_plateform/presentation/screens/login/login_page.dart';
import 'package:sneaker_recognizer_plateform/presentation/screens/reset/reset_password_page.dart';

// import 'register/register_page.dart'; // when ready

class AuthNavigator extends StatelessWidget {
  const AuthNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/reset-password':
            return MaterialPageRoute(builder: (_) => ResetPasswordPage());

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());

          default:
            return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
    );
  }
}

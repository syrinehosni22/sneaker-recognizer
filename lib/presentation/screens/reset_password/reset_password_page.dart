import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class ResetPasswordPage extends StatelessWidget {
  ResetPasswordPage({super.key});

  final _emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthService>().resetPassword(
                  _emailCtrl.text.trim(),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset email sent')),
                );
              },
              child: const Text('Send reset link'),
            ),
          ],
        ),
      ),
    );
  }
}

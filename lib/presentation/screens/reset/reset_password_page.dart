import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class ResetPasswordPage extends StatelessWidget {
  ResetPasswordPage({super.key});

  final _emailCtrl = TextEditingController();

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade200,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// APP BAR WITH BACK ARROW
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            /// LOGO
            Image.asset('assets/images/sheoa-logo.png', height: 80),

            const SizedBox(height: 40),

            /// TITLE
            const Text(
              'Reset your password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Enter your email and we will send you a reset link',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 32),

            /// EMAIL FIELD
            TextField(
              controller: _emailCtrl,
              decoration: _inputDecoration('Email'),
              style: TextStyle(color: Colors.grey.shade800),
            ),

            const SizedBox(height: 32),

            /// SEND BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await context.read<AuthService>().resetPassword(
                    _emailCtrl.text.trim(),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset email sent')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'Send reset link',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

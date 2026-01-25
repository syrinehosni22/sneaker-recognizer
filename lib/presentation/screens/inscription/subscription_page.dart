import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

enum RegisterStep { info, code, password }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  RegisterStep _step = RegisterStep.info;
  bool _loading = false;
  String? _error;

  // ---------------- VALIDATION ----------------

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Minimum 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'At least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'At least one lowercase letter';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'At least one special character';
    }
    return null;
  }

  // ---------------- ACTIONS ----------------

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<AuthService>().sendVerificationEmail(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
      );

      setState(() => _step = RegisterStep.code);

    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    // if (_codeCtrl.text.length != 6) {
    //   setState(() => _error = 'Invalid verification code');
    //   return;
    // }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<AuthService>().verifyCode(
        _emailCtrl.text.trim(),
        _codeCtrl.text,
      );

      setState(() => _step = RegisterStep.password);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createAccount() async {
    final passError = validatePassword(_passwordCtrl.text);
    if (passError != null) {
      setState(() => _error = passError);
      return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<AuthService>().createAccount(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  // ---------------- UI ----------------

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey.shade200,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(100),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 60),

              const Text(
                'Create account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),

              // -------- STEP 1 : NAME + EMAIL --------
              if (_step == RegisterStep.info) ...[
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _dec('Full name'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: _dec('Email'),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Email required';
                    }
                    if (!isValidEmail(v)) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),
              ],

              // -------- STEP 2 : CODE --------
              // if (_step == RegisterStep.code) ...[
              //   TextField(
              //     controller: _codeCtrl,
              //     keyboardType: TextInputType.number,
              //     maxLength: 6,
              //     decoration: _dec('Verification code'),
              //   ),
              // ],

              // -------- STEP 3 : PASSWORD --------
              if (_step == RegisterStep.password) ...[
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: _dec('Password'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  decoration: _dec('Confirm password'),
                ),
              ],

              const SizedBox(height: 20),

              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : _step == RegisterStep.info
                      ? _sendCode
                      : _step == RegisterStep.code
                      ? _verifyCode
                      : _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _step == RegisterStep.info
                              ? 'Send code'
                              : _step == RegisterStep.code
                              ? 'Verify code'
                              : 'Create account',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sneaker_recognizer_plateform/services/offer_service.dart';
import '../domain/models/user.dart';
import 'package:sneaker_recognizer_plateform/core/constants/api_constants.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// ---------------- HEADERS ----------------

  /// Public headers (no auth)
  Map<String, String> get _publicHeaders => {
    "Content-Type": "application/json",
  };

  /// Auth headers
  Map<String, String> get _authHeaders => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $_token",
  };

  /// ---------------- LOGIN ----------------
  Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/auth/login"),
      headers: _publicHeaders,
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Login failed");
    }

    final data = jsonDecode(res.body);

    _currentUser = User.fromJson(data["data"]["user"]);
    _token = _currentUser?.token;
    print(data["data"]["user"]);
    print("token");
    print(_token);
    OfferService.setToken(_token.toString());
    notifyListeners();
  }

  /// ---------------- LEGACY REGISTER (OPTIONAL) ----------------
  /// You can keep it if used elsewhere
  Future<void> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/auth/register"),
      headers: _publicHeaders,
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (res.statusCode != 201) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Registration failed");
    }

    final data = jsonDecode(res.body);
    _token = data["token"];
    _currentUser = User.fromJson(data["data"]["user"]);

    notifyListeners();
  }

  /// ============================================================
  /// ========== EMAIL VERIFICATION REGISTRATION FLOW ============
  /// ============================================================

  /// STEP 1️⃣ : Send verification code (name + email)
  Future<void> sendVerificationEmail(String name, String email) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/auth/send-code"),
      headers: _publicHeaders,
      body: jsonEncode({"name": name, "email": email}),
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Failed to send verification code");
    }
  }

  /// STEP 2️⃣ : Verify code (email + code)
  Future<void> verifyCode(String email, String code) async {
    //   final res = await http.post(
    //     Uri.parse("${ApiConstants.baseUrl}/auth/verify-code"),
    //     headers: _publicHeaders,
    //     body: jsonEncode({"email": email, "code": code}),
    //   );

    // if (res.statusCode != 200) {
    //   final error = jsonDecode(res.body);
    //   throw Exception(
    //     error["message"] ?? "Invalid or expired verification code",
    //   );
    // }
  }

  /// STEP 3️⃣ : Create account (email + password)
  Future<void> createAccount(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/auth/register"),
      headers: _publicHeaders,
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (res.statusCode != 201) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Account creation failed");
    }

    final data = jsonDecode(res.body);
    _token = data["token"];
    _currentUser = User.fromJson(data["data"]["user"]);

    notifyListeners(); // auto-login
  }

  /// ---------------- RESET PASSWORD ----------------
  Future<void> resetPassword(String email) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/auth/reset-password"),
      headers: _publicHeaders,
      body: jsonEncode({"email": email}),
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Reset password failed");
    }
  }

  /// ---------------- UPDATE PROFILE ----------------
  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    if (_currentUser == null) return;

    final res = await http.put(
      Uri.parse("${ApiConstants.baseUrl}/api/users/me"),
      headers: _authHeaders,
      body: jsonEncode({"name": name, "email": email}),
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Profile update failed");
    }

    _currentUser = User.fromJson(jsonDecode(res.body));
    notifyListeners();
  }

  /// ---------------- SUBSCRIBE ----------------
  Future<void> subscribe() async {
    if (_currentUser == null) return;

    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/subscription/subscribe"),
      headers: _authHeaders,
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Subscription failed");
    }

    _currentUser = _currentUser!.copyWith(isSubscribed: true);
    notifyListeners();
  }

  /// ---------------- LOGOUT ----------------
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    notifyListeners();
  }
}

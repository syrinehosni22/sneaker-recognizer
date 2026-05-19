import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:sneaker_recognizer_plateform/domain/models/user.dart';

class AuthService with ChangeNotifier {
  static const String baseUrl = "http://92.222.243.150:5000/api";

  User? _currentUser;
  String? _token;
  String? _profileImage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get profileImage => _profileImage;

  Map<String, String> get _publicHeaders => {
    "Content-Type": "application/json",
  };

  Map<String, String> get _authHeaders => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $_token",
  };

  // ================= LOGIN =================
  Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: _publicHeaders,
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Login failed");
    }

    final data = jsonDecode(res.body);

    _currentUser = User.fromJson(data["data"]["user"]);
    _token = data["token"];
    _profileImage = null;

    notifyListeners();
  }

  // ================= REGISTER =================
  Future<void> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: _publicHeaders,
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (res.statusCode != 201) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Registration failed");
    }

    final data = jsonDecode(res.body);

    _currentUser = User.fromJson(data["data"]["user"]);
    _token = data["token"];
    _profileImage = null;

    notifyListeners();
  }

  // ================= CREATE ACCOUNT (USED IN UI FLOW) =================
  Future<void> createAccount(String name, String email, String password) async {
    await register(name, email, password);
  }

  // ================= EMAIL VERIFICATION FLOW =================

  Future<void> sendVerificationEmail(String name, String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/send-code"),
      headers: _publicHeaders,
      body: jsonEncode({"name": name, "email": email}),
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Failed to send code");
    }
  }

  Future<void> verifyCode(String email, String code) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/verify-code"),
      headers: _publicHeaders,
      body: jsonEncode({"email": email, "code": code}),
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Invalid verification code");
    }
  }

  // ================= RESET PASSWORD =================
  Future<void> resetPassword(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/reset-password"),
      headers: _publicHeaders,
      body: jsonEncode({"email": email}),
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Reset password failed");
    }
  }

  // ================= PROFILE IMAGE =================
  Future<void> updateProfileImage(String path) async {
    _profileImage = path;
    notifyListeners();
  }

  // ================= UPDATE PROFILE =================
  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    if (_currentUser == null) return;

    final res = await http.put(
      Uri.parse("$baseUrl/users/me"),
      headers: _authHeaders,
      body: jsonEncode({"name": name, "email": email}),
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Update failed");
    }

    _currentUser = User.fromJson(jsonDecode(res.body));
    notifyListeners();
  }

  // ================= SUBSCRIBE =================
  Future<void> subscribe() async {
    if (_currentUser == null) return;

    final res = await http.post(
      Uri.parse("$baseUrl/subscription/subscribe"),
      headers: _authHeaders,
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error["message"] ?? "Subscription failed");
    }

    _currentUser = _currentUser!.copyWith(isSubscribed: true);
    notifyListeners();
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _profileImage = null;
    notifyListeners();
  }
}

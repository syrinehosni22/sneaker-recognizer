import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../domain/models/user.dart';

class AuthService with ChangeNotifier {
  static const String baseUrl = "https://api.yourbackend.com";

  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    if (_token != null) "Authorization": "Bearer $_token",
  };

  /// LOGIN
  Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: _headers,
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode != 200) {
      throw Exception("Login failed");
    }

    final data = jsonDecode(res.body);
    _token = data["token"];
    _currentUser = User.fromJson(data["user"]);
    notifyListeners();
  }

  /// REGISTER
  Future<void> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: _headers,
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (res.statusCode != 201) {
      throw Exception("Registration failed");
    }

    final data = jsonDecode(res.body);
    _token = data["token"];
    _currentUser = User.fromJson(data["user"]);
    notifyListeners();
  }

  /// RESET PASSWORD
  Future<void> resetPassword(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/reset-password"),
      headers: _headers,
      body: jsonEncode({"email": email}),
    );

    if (res.statusCode != 200) {
      throw Exception("Reset password failed");
    }
  }

  /// UPDATE PROFILE
  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    if (_currentUser == null) return;

    final res = await http.put(
      Uri.parse("$baseUrl/users/me"),
      headers: _headers,
      body: jsonEncode({"name": name, "email": email}),
    );

    if (res.statusCode != 200) {
      throw Exception("Profile update failed");
    }

    _currentUser = User.fromJson(jsonDecode(res.body));
    notifyListeners();
  }

  /// SUBSCRIBE (Stripe subscription)
  Future<void> subscribe() async {
    if (_currentUser == null) return;

    final res = await http.post(
      Uri.parse("$baseUrl/subscription/subscribe"),
      headers: _headers,
    );

    if (res.statusCode != 200) {
      throw Exception("Subscription failed");
    }

    _currentUser = _currentUser!.copyWith(isSubscribed: true);
    notifyListeners();
  }

  /// LOGOUT
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Thrown for any non-2xx response or network/parse failure.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Minimal REST client used by [SettingsRepository] (and anything else
/// that needs to talk to your backend).
///
/// ── HOW TO WIRE THIS UP ──────────────────────────────────────────────
/// 1. Set [baseUrl] to your real API root.
/// 2. Right after a successful login (and on app startup if a session is
///    restored), set `ApiClient.instance.authToken = <token from AuthService>`.
/// 3. On logout, set `ApiClient.instance.authToken = null`.
///
/// Example inside your AuthService:
/// ```dart
/// Future<void> login(...) async {
///   ...
///   ApiClient.instance.authToken = response.token;
/// }
/// Future<void> logout() async {
///   ...
///   ApiClient.instance.authToken = null;
/// }
/// ```
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  /// Same weezo-api root as AuthService.baseUrl — keep these two in sync.
  static const String baseUrl = "http://92.222.243.150:5000/api";

  /// Bearer token used for authenticated requests. Set this from
  /// AuthService after login/refresh, clear it on logout.
  ///
  /// This is a *sanitizing* setter on purpose: "Invalid or expired token"
  /// from the backend almost always means the stored value isn't actually
  /// a raw JWT (stray quotes from `jsonEncode`, an accidental "Bearer "
  /// prefix, the whole login response instead of just `data.token`, a
  /// trailing newline, etc). Setting it here strips the common mistakes
  /// and — in debug builds — logs exactly what got rejected, so a bad
  /// value is visible in the console instead of silently causing 401s.
  String? _authToken;
  String? get authToken => _authToken;
  set authToken(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      _authToken = null;
      return;
    }

    var token = raw.trim();

    // Catches `authToken = someNullableValue.toString()` or
    // `authToken = '$maybeNullToken'` — both silently turn a null token
    // into the 4-character string "null", which then gets sent as
    // "Bearer null" and fails with a confusing "jwt malformed" error.
    if (token.toLowerCase() == 'null' || token.toLowerCase() == 'undefined') {
      if (kDebugMode) {
        debugPrint(
          '⚠️ ApiClient.authToken received the literal string "$raw" — '
          'this means the real token was null/undefined when it got '
          "stringified. Check the JSON path you're reading the token from "
          "(should be response['data']['token'] for weezo-api's login/"
          'register response) and make sure the field actually exists.',
        );
      }
      _authToken = null;
      return;
    }
    // Strip a leading "Bearer " if it was accidentally included upstream —
    // it gets added again by `_headers` below, so keeping it here would
    // send "Bearer Bearer eyJ...".
    if (token.toLowerCase().startsWith('bearer ')) {
      token = token.substring(7).trim();
    }
    // Strip stray surrounding quotes (e.g. from `jsonEncode('"$token"')`
    // or copy-pasting a JSON string value including its quotes).
    if (token.length >= 2 && token.startsWith('"') && token.endsWith('"')) {
      token = token.substring(1, token.length - 1);
    }

    final looksLikeJwt = token.split('.').length == 3;
    if (!looksLikeJwt) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ ApiClient.authToken was set to something that is not a valid '
          'JWT (expected 3 dot-separated segments, got '
          '${token.split('.').length}). Value received: "$raw". '
          "Double-check you're passing response['data']['token'] "
          '(a plain string), not the whole login response.',
        );
      }
    }

    _authToken = token;
  }

  static const Duration _timeout = Duration(seconds: 10);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (authToken != null && authToken!.isNotEmpty)
      'Authorization': 'Bearer $authToken',
  };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  /// weezo-api always responds with `{ success, message, data }` (see
  /// `src/utils/response.js`). This unwraps `data` and turns
  /// `success: false` into an [ApiException], regardless of HTTP status.
  dynamic _decode(http.Response res) {
    Map<String, dynamic>? body;
    if (res.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      } catch (_) {}
    }

    final isHttpOk = res.statusCode >= 200 && res.statusCode < 300;
    final isApiOk = body == null || body['success'] != false;

    if (isHttpOk && isApiOk) {
      return body?['data'] ?? body;
    }

    final message =
        (body?['message'] as String?) ?? 'Request failed (${res.statusCode})';
    throw ApiException(message, statusCode: res.statusCode);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    try {
      final res = await http
          .get(_uri(path, query), headers: _headers)
          .timeout(_timeout);
      return _decode(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await http
          .post(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(_timeout);
      return _decode(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await http
          .patch(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(_timeout);
      return _decode(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await http
          .delete(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(_timeout);
      return _decode(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
}

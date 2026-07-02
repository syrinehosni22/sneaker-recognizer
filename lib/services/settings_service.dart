import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Modes for background location access.
enum LocationAccessMode { never, whileUsing, always }

extension LocationAccessModeLabel on LocationAccessMode {
  String get label {
    switch (this) {
      case LocationAccessMode.never:
        return 'Jamais';
      case LocationAccessMode.whileUsing:
        return "Uniquement pendant l'utilisation";
      case LocationAccessMode.always:
        return 'Toujours';
    }
  }

  String get description {
    switch (this) {
      case LocationAccessMode.never:
        return "L'application ne pourra jamais accéder à votre position.";
      case LocationAccessMode.whileUsing:
        return 'La position est accessible uniquement quand vous utilisez l\'application.';
      case LocationAccessMode.always:
        return "La position reste accessible même en arrière-plan.";
    }
  }
}

/// A very small, dependency-light persistence layer built on top of
/// SharedPreferences. Every setter writes through immediately so the
/// UI never has to worry about a separate "save" step.
class SettingsService {
  static const _kNotifications = 'settings_notifications_enabled';
  static const _kDarkMode = 'settings_dark_mode_enabled';
  static const _kTwoFactor = 'settings_two_factor_enabled';
  static const _kUnusualAlerts = 'settings_unusual_login_alerts';
  static const _kLocationSharing = 'settings_location_sharing_enabled';
  static const _kLocationMode = 'settings_location_access_mode';
  static const _kLanguage = 'settings_language_code';
  static const _kPaymentMethods = 'settings_payment_methods';
  static const _kConnectedDevices = 'settings_connected_devices';

  // ── Preferences ────────────────────────────────────────────────────
  static Future<bool> getNotifications() async =>
      (await _prefs()).getBool(_kNotifications) ?? true;
  static Future<void> setNotifications(bool v) async =>
      (await _prefs()).setBool(_kNotifications, v);

  static Future<bool> getDarkMode() async =>
      (await _prefs()).getBool(_kDarkMode) ?? false;
  static Future<void> setDarkMode(bool v) async =>
      (await _prefs()).setBool(_kDarkMode, v);

  static Future<String> getLanguage() async =>
      (await _prefs()).getString(_kLanguage) ?? 'fr';
  static Future<void> setLanguage(String code) async =>
      (await _prefs()).setString(_kLanguage, code);

  // ── Sécurité du compte ────────────────────────────────────────────
  static Future<bool> getTwoFactor() async =>
      (await _prefs()).getBool(_kTwoFactor) ?? false;
  static Future<void> setTwoFactor(bool v) async =>
      (await _prefs()).setBool(_kTwoFactor, v);

  static Future<bool> getUnusualLoginAlerts() async =>
      (await _prefs()).getBool(_kUnusualAlerts) ?? true;
  static Future<void> setUnusualLoginAlerts(bool v) async =>
      (await _prefs()).setBool(_kUnusualAlerts, v);

  /// Connected devices are stored as a JSON list of {id, name, location, lastActive, current}
  static Future<List<Map<String, dynamic>>> getConnectedDevices() async {
    final raw = (await _prefs()).getString(_kConnectedDevices);
    if (raw == null) {
      // Seed with a plausible default so the screen isn't empty on first run.
      final seed = [
        {
          'id': 'current',
          'name': 'Cet appareil',
          'location': 'Session active',
          'lastActive': "À l'instant",
          'current': true,
        },
      ];
      await setConnectedDevices(seed);
      return seed;
    }
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> setConnectedDevices(
    List<Map<String, dynamic>> devices,
  ) async {
    await (await _prefs()).setString(_kConnectedDevices, jsonEncode(devices));
  }

  // ── Confidentialité de la localisation ────────────────────────────
  static Future<bool> getLocationSharing() async =>
      (await _prefs()).getBool(_kLocationSharing) ?? false;
  static Future<void> setLocationSharing(bool v) async =>
      (await _prefs()).setBool(_kLocationSharing, v);

  static Future<LocationAccessMode> getLocationMode() async {
    final idx =
        (await _prefs()).getInt(_kLocationMode) ??
        LocationAccessMode.whileUsing.index;
    return LocationAccessMode.values[idx];
  }

  static Future<void> setLocationMode(LocationAccessMode mode) async =>
      (await _prefs()).setInt(_kLocationMode, mode.index);

  // ── Moyens de paiement (stockage local, à remplacer par un vrai backend) ──
  static Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final raw = (await _prefs()).getString(_kPaymentMethods);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> setPaymentMethods(
    List<Map<String, dynamic>> methods,
  ) async {
    await (await _prefs()).setString(_kPaymentMethods, jsonEncode(methods));
  }

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();
}

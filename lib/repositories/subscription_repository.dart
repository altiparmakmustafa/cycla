import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  static const String _subsKey = 'cycla_user_subscriptions_v1';
  static const String _settingsKey = 'cycla_user_settings_v1';

  final SharedPreferences _prefs;

  SubscriptionRepository(this._prefs);

  /// Kullanıcının kendi kaydettiği gerçek abonelik ve faturaları yükler.
  /// İlk açılışta tamamen boş liste döner (örnek/test verisi eklenmez).
  List<Subscription> loadSubscriptions() {
    final rawJson = _prefs.getString(_subsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Subscription.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSubscriptions(List<Subscription> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_subsKey, encoded);
  }

  AppSettings loadSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}

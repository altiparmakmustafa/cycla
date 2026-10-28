import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/currency_formatter.dart';
import '../models/app_settings.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  static const String _subsKey = 'cycla_subscriptions_v1';
  static const String _settingsKey = 'cycla_settings_v1';
  static const String _seededKey = 'cycla_seeded_v1';

  final SharedPreferences _prefs;

  SubscriptionRepository(this._prefs);

  List<Subscription> loadSubscriptions() {
    final alreadySeeded = _prefs.getBool(_seededKey) ?? false;
    final rawJson = _prefs.getString(_subsKey);

    if (rawJson == null) {
      if (!alreadySeeded) {
        final demo = buildStarterSampleData();
        saveSubscriptions(demo);
        _prefs.setBool(_seededKey, true);
        return demo;
      }
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
    await _prefs.setBool(_seededKey, true);
  }

  AppSettings loadSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  /// İlk açılışta uygulamanın tüm özelliklerini (döviz çevrimi, ortak abonelik,
  /// deneme sürümü uyarısı, kategori analizi) sergileyen örnek veriler.
  /// Hiçbir tescilli marka logosu içermez; sembolik ikonlar kullanır.
  static List<Subscription> buildStarterSampleData() {
    const uuid = Uuid();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      Subscription(
        id: uuid.v4(),
        name: 'Ev İnterneti (Fiber)',
        amount: 499.90,
        currency: CurrencyCode.tryCode,
        period: BillingPeriod.monthly,
        category: SubscriptionCategory.internetAndMobile,
        nextPaymentDate: today.add(const Duration(days: 3)),
        iconKey: 'wifi',
        colorHex: 0xFF00ACC1,
        reminderDaysBefore: 2,
        sharedWithCount: 2,
        notes: 'Ev arkadaşı ile 2 kişilik ortak ödeme',
      ),
      Subscription(
        id: uuid.v4(),
        name: 'Elektrik Faturası',
        amount: 640.00,
        currency: CurrencyCode.tryCode,
        period: BillingPeriod.monthly,
        category: SubscriptionCategory.utilities,
        nextPaymentDate: today.add(const Duration(days: 6)),
        iconKey: 'electricity',
        colorHex: 0xFFFFB300,
        reminderDaysBefore: 3,
      ),
      Subscription(
        id: uuid.v4(),
        name: 'Netflix',
        amount: 229.99,
        currency: CurrencyCode.tryCode,
        period: BillingPeriod.monthly,
        category: SubscriptionCategory.entertainment,
        nextPaymentDate: today.add(const Duration(days: 9)),
        iconKey: 'movie',
        colorHex: 0xFFE53935,
        reminderDaysBefore: 2,
      ),
      Subscription(
        id: uuid.v4(),
        name: 'Spotify Aile',
        amount: 99.99,
        currency: CurrencyCode.tryCode,
        period: BillingPeriod.monthly,
        category: SubscriptionCategory.entertainment,
        nextPaymentDate: today.add(const Duration(days: 2)),
        iconKey: 'music',
        colorHex: 0xFF1DB954,
        reminderDaysBefore: 1,
        isFreeTrial: true,
        notes: '1 aylık deneme süresi bitmeden kontrol et',
      ),
      Subscription(
        id: uuid.v4(),
        name: 'Bulut Depolama 200 GB',
        amount: 2.99,
        currency: CurrencyCode.usd,
        period: BillingPeriod.monthly,
        category: SubscriptionCategory.softwareAndAi,
        nextPaymentDate: today.add(const Duration(days: 14)),
        iconKey: 'cloud',
        colorHex: 0xFF6C63FF,
        reminderDaysBefore: 2,
      ),
    ];
  }
}


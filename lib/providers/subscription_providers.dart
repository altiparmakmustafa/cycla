import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/legal_texts.dart';
import '../core/services/notification_service.dart';
import '../models/app_settings.dart';
import '../models/subscription.dart';
import '../repositories/subscription_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences main() içinde başlatılmalıdır.');
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SubscriptionRepository(prefs);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SubscriptionRepository _repository;
  final Ref _ref;

  SettingsNotifier(this._repository, this._ref)
      : super(_repository.loadSettings());

  Future<void> updateSettings(AppSettings updated) async {
    state = updated;
    await _repository.saveSettings(updated);
    final subs = _ref.read(subscriptionsProvider);
    await NotificationService.instance.syncAllReminders(subs, state);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return SettingsNotifier(repo, ref);
});

class SubscriptionsNotifier extends StateNotifier<List<Subscription>> {
  final SubscriptionRepository _repository;
  final Ref _ref;

  SubscriptionsNotifier(this._repository, this._ref)
      : super(_repository.loadSubscriptions());

  Future<void> addSubscription(Subscription sub) async {
    final updated = [...state, sub];
    state = updated;
    await _repository.saveSubscriptions(updated);
    await NotificationService.instance.scheduleForSubscription(
      sub,
      _ref.read(settingsProvider),
    );
  }

  Future<void> updateSubscription(Subscription sub) async {
    final updated = [
      for (final item in state)
        if (item.id == sub.id) sub else item,
    ];
    state = updated;
    await _repository.saveSubscriptions(updated);
    await NotificationService.instance.scheduleForSubscription(
      sub,
      _ref.read(settingsProvider),
    );
  }

  Future<void> deleteSubscription(Subscription sub) async {
    final updated = state.where((e) => e.id != sub.id).toList();
    state = updated;
    await _repository.saveSubscriptions(updated);
    await NotificationService.instance.cancelForSubscription(sub);
  }

  /// Mevcut dönem ödendi olarak işaretlenir ve sonraki ödeme tarihine ilerletilir.
  Future<void> markCyclePaidAndAdvance(Subscription sub) async {
    final advanced = sub.advanceToNextCycle();
    await updateSubscription(advanced);
  }

  Future<void> toggleActive(Subscription sub) async {
    final toggled = sub.copyWith(isActive: !sub.isActive);
    await updateSubscription(toggled);
  }

  Future<void> resetToDemoData() async {
    final demo = SubscriptionRepository.buildStarterSampleData();
    state = demo;
    await _repository.saveSubscriptions(demo);
    await NotificationService.instance.syncAllReminders(
      demo,
      _ref.read(settingsProvider),
    );
  }

  Future<void> clearAll() async {
    for (final sub in state) {
      await NotificationService.instance.cancelForSubscription(sub);
    }
    state = [];
    await _repository.saveSubscriptions([]);
  }
}

final subscriptionsProvider =
    StateNotifierProvider<SubscriptionsNotifier, List<Subscription>>((ref) {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionsNotifier(repo, ref);
});

/// Seçili kategori filtresi (null = Tümü)
final selectedCategoryFilterProvider =
    StateProvider<SubscriptionCategory?>((ref) => null);

/// Ödeme aciliyetine göre sıralanmış ve filtrelenmiş abonelik listesi
final filteredSubscriptionsProvider = Provider<List<Subscription>>((ref) {
  final all = ref.watch(subscriptionsProvider);
  final selectedCategory = ref.watch(selectedCategoryFilterProvider);

  final filtered = selectedCategory == null
      ? [...all]
      : all.where((s) => s.category == selectedCategory).toList();

  filtered.sort((a, b) {
    if (a.isActive != b.isActive) {
      return a.isActive ? -1 : 1;
    }
    return a.daysUntilNextPayment().compareTo(b.daysUntilNextPayment());
  });
  return filtered;
});

/// Aktif aboneliklerin aylık normalize edilmiş toplam TL tutarı (kullanıcı payı)
final monthlyTotalTryProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final settings = ref.watch(settingsProvider);
  double total = 0;
  for (final sub in subs) {
    total += sub.monthlyNormalizedTry(
      usdRate: settings.usdRate,
      eurRate: settings.eurRate,
    );
  }
  return total;
});

/// Yıllık toplam tahmini TL gideri
final yearlyTotalTryProvider = Provider<double>((ref) {
  return ref.watch(monthlyTotalTryProvider) * 12.0;
});

/// Önümüzdeki 7 gün içinde ödemesi gelen aktif abonelikler
final upcoming7DaysProvider = Provider<List<Subscription>>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final upcoming = subs.where((s) {
    if (!s.isActive) return false;
    final days = s.daysUntilNextPayment();
    return days >= -3 && days <= 7;
  }).toList();
  upcoming.sort(
    (a, b) => a.daysUntilNextPayment().compareTo(b.daysUntilNextPayment()),
  );
  return upcoming;
});

/// Yakında bitecek (5 gün veya daha az kalmış) ücretsiz deneme sürümleri
final expiringFreeTrialsProvider = Provider<List<Subscription>>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs.where((s) {
    if (!s.isActive || !s.isFreeTrial) return false;
    final days = s.daysUntilNextPayment();
    return days >= 0 && days <= 5;
  }).toList();
});

/// Kategori bazlı aylık TL harcama dağılımı
final categoryBreakdownProvider =
    Provider<Map<SubscriptionCategory, double>>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final settings = ref.watch(settingsProvider);
  final Map<SubscriptionCategory, double> map = {};

  for (final sub in subs) {
    if (!sub.isActive) continue;
    final monthly = sub.monthlyNormalizedTry(
      usdRate: settings.usdRate,
      eurRate: settings.eurRate,
    );
    if (monthly <= 0) continue;
    map[sub.category] = (map[sub.category] ?? 0) + monthly;
  }
  return map;
});

/// Mağaza Ekran Görüntüsü Modu açıksa ismi güvenli jenerik isme çevirir.
extension SubscriptionDisplayX on Subscription {
  String displayName(AppSettings settings) {
    if (!settings.storeSafeScreenshotMode) return name;
    return LegalTexts.toStoreSafeName(name, category.label);
  }
}


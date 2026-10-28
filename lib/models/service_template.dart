import '../core/utils/currency_formatter.dart';
import 'subscription.dart';

/// HUKUKSAL GÜVENLİK:
/// Bu şablonlar tescilli marka logoları veya sahte fiyat verileri İÇERMEZ.
/// Kullanıcının kendi fatura veya aboneliğini hızlıca oluşturabilmesi için
/// yalnızca kategori, sembolik Material ikonu ve renk ön ayarı sunar.
class ServiceTemplate {
  final String name;
  final SubscriptionCategory category;
  final String iconKey;
  final int colorHex;
  final CurrencyCode defaultCurrency;
  final BillingPeriod defaultPeriod;

  const ServiceTemplate({
    required this.name,
    required this.category,
    required this.iconKey,
    required this.colorHex,
    this.defaultCurrency = CurrencyCode.tryCode,
    this.defaultPeriod = BillingPeriod.monthly,
  });

  static const List<ServiceTemplate> presets = [
    ServiceTemplate(
      name: 'Elektrik Faturası',
      category: SubscriptionCategory.utilities,
      iconKey: 'electricity',
      colorHex: 0xFFFFB300,
    ),
    ServiceTemplate(
      name: 'Ev İnterneti',
      category: SubscriptionCategory.internetAndMobile,
      iconKey: 'wifi',
      colorHex: 0xFF00ACC1,
    ),
    ServiceTemplate(
      name: 'Mobil Hat Faturası',
      category: SubscriptionCategory.internetAndMobile,
      iconKey: 'mobile',
      colorHex: 0xFF1E88E5,
    ),
    ServiceTemplate(
      name: 'Su Faturası',
      category: SubscriptionCategory.utilities,
      iconKey: 'water',
      colorHex: 0xFF1E88E5,
    ),
    ServiceTemplate(
      name: 'Doğalgaz Faturası',
      category: SubscriptionCategory.utilities,
      iconKey: 'gas',
      colorHex: 0xFFFF7043,
    ),
    ServiceTemplate(
      name: 'Kira / Site Aidatı',
      category: SubscriptionCategory.housing,
      iconKey: 'home',
      colorHex: 0xFF78909C,
    ),
    ServiceTemplate(
      name: 'Netflix',
      category: SubscriptionCategory.entertainment,
      iconKey: 'movie',
      colorHex: 0xFFE53935,
    ),
    ServiceTemplate(
      name: 'Spotify',
      category: SubscriptionCategory.entertainment,
      iconKey: 'music',
      colorHex: 0xFF1DB954,
    ),
    ServiceTemplate(
      name: 'YouTube Premium',
      category: SubscriptionCategory.entertainment,
      iconKey: 'video',
      colorHex: 0xFFE53935,
    ),
    ServiceTemplate(
      name: 'Bulut Depolama',
      category: SubscriptionCategory.softwareAndAi,
      iconKey: 'cloud',
      colorHex: 0xFF6C63FF,
    ),
    ServiceTemplate(
      name: 'Yapay Zeka Aboneliği',
      category: SubscriptionCategory.softwareAndAi,
      iconKey: 'ai',
      colorHex: 0xFF26A69A,
      defaultCurrency: CurrencyCode.usd,
    ),
    ServiceTemplate(
      name: 'Spor Salonu Üyeliği',
      category: SubscriptionCategory.healthAndFitness,
      iconKey: 'fitness',
      colorHex: 0xFFEC407A,
    ),
  ];
}

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
      colorHex: 0xFFF6AD55,
    ),
    ServiceTemplate(
      name: 'Ev İnterneti',
      category: SubscriptionCategory.internetAndMobile,
      iconKey: 'wifi',
      colorHex: 0xFF4FD1C5,
    ),
    ServiceTemplate(
      name: 'Mobil Hat Faturası',
      category: SubscriptionCategory.internetAndMobile,
      iconKey: 'mobile',
      colorHex: 0xFF63B3ED,
    ),
    ServiceTemplate(
      name: 'Su Faturası',
      category: SubscriptionCategory.utilities,
      iconKey: 'water',
      colorHex: 0xFF63B3ED,
    ),
    ServiceTemplate(
      name: 'Doğalgaz Faturası',
      category: SubscriptionCategory.utilities,
      iconKey: 'gas',
      colorHex: 0xFFFF8A65,
    ),
    ServiceTemplate(
      name: 'Kira / Site Aidatı',
      category: SubscriptionCategory.housing,
      iconKey: 'home',
      colorHex: 0xFF90A4AE,
    ),
    ServiceTemplate(
      name: 'Netflix',
      category: SubscriptionCategory.entertainment,
      iconKey: 'movie',
      colorHex: 0xFFFC8181,
    ),
    ServiceTemplate(
      name: 'Spotify',
      category: SubscriptionCategory.entertainment,
      iconKey: 'music',
      colorHex: 0xFF68D391,
    ),
    ServiceTemplate(
      name: 'YouTube Premium',
      category: SubscriptionCategory.entertainment,
      iconKey: 'video',
      colorHex: 0xFFFC8181,
    ),
    ServiceTemplate(
      name: 'Bulut Depolama',
      category: SubscriptionCategory.softwareAndAi,
      iconKey: 'cloud',
      colorHex: 0xFF7F9CF5,
    ),
    ServiceTemplate(
      name: 'Yapay Zeka Aboneliği',
      category: SubscriptionCategory.softwareAndAi,
      iconKey: 'ai',
      colorHex: 0xFF4DB6AC,
      defaultCurrency: CurrencyCode.usd,
    ),
    ServiceTemplate(
      name: 'Spor Salonu Üyeliği',
      category: SubscriptionCategory.healthAndFitness,
      iconKey: 'fitness',
      colorHex: 0xFFF687B3,
    ),
  ];
}

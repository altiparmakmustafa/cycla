import 'package:cycla/core/constants/legal_texts.dart';
import 'package:cycla/core/utils/currency_formatter.dart';
import 'package:cycla/models/subscription.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Subscription Model & Hesaplama Testleri', () {
    test('Ortak abonelik kişi başı pay ve yıllık/aylık TL çevrimi doğru çalışır', () {
      final sub = Subscription(
        id: 'test-1',
        name: 'Bulut Paketi',
        amount: 120.0,
        currency: CurrencyCode.usd,
        period: BillingPeriod.yearly,
        nextPaymentDate: DateTime(2026, 11, 15),
        sharedWithCount: 2,
      );

      // 120 USD / 2 kişi = 60 USD yıllık -> 5 USD aylık
      expect(sub.userShareAmount, 60.0);

      final monthlyTry = sub.monthlyNormalizedTry(
        usdRate: 35.0,
        eurRate: 38.0,
      );
      // 5 USD * 35 TL = 175 TL / ay
      expect(monthlyTry, closeTo(175.0, 0.001));
    });

    test('Ay sonu (31 Ocak) bir sonraki aya ilerletildiğinde Şubat sonuna kenetlenir', () {
      final janEnd = Subscription(
        id: 'test-2',
        name: 'Ev İnterneti',
        amount: 450.0,
        period: BillingPeriod.monthly,
        nextPaymentDate: DateTime(2026, 1, 31),
        isFreeTrial: true,
      );

      final advanced = janEnd.advanceToNextCycle();
      expect(advanced.nextPaymentDate, DateTime(2026, 2, 28));
      expect(advanced.isFreeTrial, isFalse);
    });

    test('Takvim occursOnDay aylık tekrarları doğru işaretler', () {
      final sub = Subscription(
        id: 'test-3',
        name: 'Elektrik Faturası',
        amount: 500.0,
        period: BillingPeriod.monthly,
        nextPaymentDate: DateTime(2026, 11, 10),
      );

      expect(sub.occursOnDay(DateTime(2026, 10, 10)), isFalse);
      expect(sub.occursOnDay(DateTime(2026, 11, 10)), isTrue);
      expect(sub.occursOnDay(DateTime(2026, 12, 10)), isTrue);
      expect(sub.occursOnDay(DateTime(2027, 1, 10)), isTrue);
    });

    test('Mağaza Ekran Görüntüsü Modu marka adlarını jenerik isme dönüştürür', () {
      expect(
        LegalTexts.toStoreSafeName('Netflix Aile', 'Eğlence & Yayın'),
        'Film & Dizi Platformu',
      );
      expect(
        LegalTexts.toStoreSafeName('Spotify Premium', 'Eğlence & Yayın'),
        'Müzik Akış Servisi',
      );
      expect(
        LegalTexts.toStoreSafeName('Elektrik Faturası', 'Ev Faturaları'),
        'Elektrik Faturası',
      );
    });
  });
}


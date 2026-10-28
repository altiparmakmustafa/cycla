import 'package:cycla/core/services/exchange_rate_service.dart';
import 'package:cycla/core/utils/currency_formatter.dart';
import 'package:cycla/models/subscription.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Subscription Model & Canlı Kur Ayrıştırıcı Testleri', () {
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

      expect(sub.userShareAmount, 60.0);

      final monthlyTry = sub.monthlyNormalizedTry(
        usdRate: 35.0,
        eurRate: 38.0,
      );
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

    test('Anlık spot piyasa kur JSON yanıtı USD/TRY ve EUR/TRY olarak doğru hesaplanır', () {
      const spotJson =
          '{"data":{"currency":"USD","rates":{"TRY":"40.00","EUR":"0.80"}}}';
      final parsed = parseCoinbaseSpotResponse(spotJson);

      expect(parsed.usdTry, closeTo(40.0, 0.0001));
      expect(parsed.eurTry, closeTo(50.0, 0.0001));
    });

    test('ECB / Frankfurter yedek kur JSON yanıtı doğru hesaplanır', () {
      const sampleJson =
          '{"amount":1.0,"base":"EUR","date":"2026-10-28","rates":{"TRY":44.0,"USD":1.1}}';
      final parsed = parseFrankfurterResponse(sampleJson);

      expect(parsed.eurTry, closeTo(44.0, 0.0001));
      expect(parsed.usdTry, closeTo(40.0, 0.0001));
    });
  });
}

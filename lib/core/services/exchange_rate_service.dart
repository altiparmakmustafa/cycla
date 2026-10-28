import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ExchangeRatesSnapshot {
  final double usdTry;
  final double eurTry;
  final String source;
  final DateTime fetchedAt;

  const ExchangeRatesSnapshot({
    required this.usdTry,
    required this.eurTry,
    required this.source,
    required this.fetchedAt,
  });
}

/// Isolate üzerinde çalışabilen üst seviye anlık piyasa (Coinbase Spot v2) ayrıştırıcısı.
ExchangeRatesSnapshot parseCoinbaseSpotResponse(String responseBody) {
  final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
  final data = decoded['data'] as Map<String, dynamic>?;
  final rates = data?['rates'] as Map<String, dynamic>?;
  if (rates == null || rates['TRY'] == null || rates['EUR'] == null) {
    throw const FormatException('Anlık kur verisi eksik.');
  }

  final usdToTry = double.tryParse(rates['TRY'].toString());
  final usdToEur = double.tryParse(rates['EUR'].toString());
  if (usdToTry == null ||
      usdToEur == null ||
      usdToTry <= 0 ||
      usdToEur <= 0) {
    throw const FormatException('Geçersiz anlık kur değeri.');
  }

  final eurToTry = usdToTry / usdToEur;
  return ExchangeRatesSnapshot(
    usdTry: usdToTry,
    eurTry: eurToTry,
    source: 'Anlık Piyasa Kuru',
    fetchedAt: DateTime.now(),
  );
}

/// Isolate üzerinde çalışabilen üst seviye (top-level) ECB / Frankfurter JSON ayrıştırıcısı.
ExchangeRatesSnapshot parseFrankfurterResponse(String responseBody) {
  final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
  final rates = decoded['rates'] as Map<String, dynamic>?;
  if (rates == null || rates['TRY'] == null || rates['USD'] == null) {
    throw const FormatException('Frankfurter kur verisi eksik.');
  }

  final eurToTry = (rates['TRY'] as num).toDouble();
  final eurToUsd = (rates['USD'] as num).toDouble();
  if (eurToTry <= 0 || eurToUsd <= 0) {
    throw const FormatException('Geçersiz kur değeri alındı.');
  }

  final usdToTry = eurToTry / eurToUsd;
  return ExchangeRatesSnapshot(
    usdTry: usdToTry,
    eurTry: eurToTry,
    source: 'Avrupa Merkez Bankası (ECB)',
    fetchedAt: DateTime.now(),
  );
}

/// Isolate üzerinde çalışabilen üst seviye yedek (Open ER-API) JSON ayrıştırıcısı.
ExchangeRatesSnapshot parseOpenErResponse(String responseBody) {
  final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
  final rates = decoded['rates'] as Map<String, dynamic>?;
  if (rates == null || rates['TRY'] == null || rates['EUR'] == null) {
    throw const FormatException('Yedek kur servisi verisi eksik.');
  }

  final usdToTry = (rates['TRY'] as num).toDouble();
  final usdToEur = (rates['EUR'] as num).toDouble();
  if (usdToTry <= 0 || usdToEur <= 0) {
    throw const FormatException('Geçersiz yedek kur değeri.');
  }

  final eurToTry = usdToTry / usdToEur;
  return ExchangeRatesSnapshot(
    usdTry: usdToTry,
    eurTry: eurToTry,
    source: 'Open Exchange Rates',
    fetchedAt: DateTime.now(),
  );
}

/// API anahtarı gerektirmeyen ve Web (CORS), iOS, Android, macOS uyumlu
/// anlık USD/TRY ve EUR/TRY döviz kuru servisi.
class ExchangeRateService {
  ExchangeRateService._();
  static final ExchangeRateService instance = ExchangeRateService._();

  static final Uri _spotMarketUri = Uri.parse(
    'https://api.coinbase.com/v2/exchange-rates?currency=USD',
  );
  static final Uri _ecbPrimaryUri = Uri.parse(
    'https://api.frankfurter.dev/v1/latest?base=EUR&symbols=TRY,USD',
  );
  static final Uri _ecbSecondaryUri = Uri.parse(
    'https://api.frankfurter.app/latest?from=EUR&to=TRY,USD',
  );
  static final Uri _fallbackUri = Uri.parse(
    'https://open.er-api.com/v6/latest/USD',
  );

  Future<ExchangeRatesSnapshot> fetchLatestTryRates({
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    final shouldClose = client == null;

    try {
      // 1. Birincil kaynak: Saniyelik güncellenen anlık spot piyasa kuru
      try {
        final spotResponse = await httpClient
            .get(_spotMarketUri)
            .timeout(const Duration(seconds: 6));
        if (spotResponse.statusCode == 200) {
          return await compute(parseCoinbaseSpotResponse, spotResponse.body);
        }
      } catch (_) {
        // Yedek kaynağa geçilir
      }

      // 2. İkincil kaynak: Frankfurter v1 (ECB güncel kurları)
      try {
        final response = await httpClient
            .get(_ecbPrimaryUri)
            .timeout(const Duration(seconds: 6));
        if (response.statusCode == 200) {
          return await compute(parseFrankfurterResponse, response.body);
        }
      } catch (_) {
        // Diğer yedek kaynağa geçilir
      }

      // 3. Üçüncül kaynak: Frankfurter alternatif alan adı
      try {
        final response = await httpClient
            .get(_ecbSecondaryUri)
            .timeout(const Duration(seconds: 6));
        if (response.statusCode == 200) {
          return await compute(parseFrankfurterResponse, response.body);
        }
      } catch (_) {
        // Son yedek kaynağa geçilir
      }

      // 4. Dördüncül kaynak: Open ExchangeRate API
      final fallbackResponse = await httpClient
          .get(_fallbackUri)
          .timeout(const Duration(seconds: 6));
      if (fallbackResponse.statusCode == 200) {
        return await compute(parseOpenErResponse, fallbackResponse.body);
      }

      throw Exception(
        'Canlı döviz kurları alınamadı (HTTP ${fallbackResponse.statusCode}).',
      );
    } finally {
      if (shouldClose) {
        httpClient.close();
      }
    }
  }
}

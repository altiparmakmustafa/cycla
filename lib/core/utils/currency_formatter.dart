import 'package:intl/intl.dart';

enum CurrencyCode {
  tryCode('TRY', '₺', 'Türk Lirası'),
  usd('USD', '\$', 'ABD Doları'),
  eur('EUR', '€', 'Euro');

  final String code;
  final String symbol;
  final String label;

  const CurrencyCode(this.code, this.symbol, this.label);

  static CurrencyCode fromCode(String? raw) {
    for (final item in CurrencyCode.values) {
      if (item.code == raw) return item;
    }
    return CurrencyCode.tryCode;
  }
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(
    double amount, {
    CurrencyCode currency = CurrencyCode.tryCode,
    int decimalDigits = 2,
  }) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: currency.symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  static double convertToTry(
    double amount, {
    required CurrencyCode currency,
    required double usdRate,
    required double eurRate,
  }) {
    switch (currency) {
      case CurrencyCode.tryCode:
        return amount;
      case CurrencyCode.usd:
        return amount * usdRate;
      case CurrencyCode.eur:
        return amount * eurRate;
    }
  }
}


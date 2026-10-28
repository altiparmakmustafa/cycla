import 'package:flutter/material.dart';
import '../core/utils/currency_formatter.dart';

enum BillingPeriod {
  weekly('weekly', 'Haftalık', 'Hafta'),
  monthly('monthly', 'Aylık', 'Ay'),
  quarterly('quarterly', '3 Aylık', '3 Ay'),
  yearly('yearly', 'Yıllık', 'Yıl');

  final String key;
  final String label;
  final String shortUnit;

  const BillingPeriod(this.key, this.label, this.shortUnit);

  static BillingPeriod fromKey(String? raw) {
    for (final item in BillingPeriod.values) {
      if (item.key == raw) return item;
    }
    return BillingPeriod.monthly;
  }
}

enum SubscriptionCategory {
  entertainment('entertainment', 'Eğlence & Yayın', Icons.movie_outlined),
  utilities('utilities', 'Ev Faturaları', Icons.bolt),
  internetAndMobile('internet_mobile', 'İnternet & GSM', Icons.wifi),
  softwareAndAi('software_ai', 'Yazılım & Bulut', Icons.cloud_outlined),
  healthAndFitness('health_fitness', 'Spor & Sağlık', Icons.fitness_center),
  housing('housing', 'Kira & Aidat', Icons.home_outlined),
  other('other', 'Diğer', Icons.receipt_long_outlined);

  final String key;
  final String label;
  final IconData icon;

  const SubscriptionCategory(this.key, this.label, this.icon);

  static SubscriptionCategory fromKey(String? raw) {
    for (final item in SubscriptionCategory.values) {
      if (item.key == raw) return item;
    }
    return SubscriptionCategory.other;
  }
}

class Subscription {
  final String id;
  final String name;
  final double amount;
  final CurrencyCode currency;
  final BillingPeriod period;
  final SubscriptionCategory category;
  final DateTime nextPaymentDate;
  final String iconKey;
  final String? monogram;
  final int colorHex;
  final int reminderDaysBefore;
  final bool isFreeTrial;
  final int sharedWithCount;
  final String? notes;
  final bool isActive;

  const Subscription({
    required this.id,
    required this.name,
    required this.amount,
    this.currency = CurrencyCode.tryCode,
    this.period = BillingPeriod.monthly,
    this.category = SubscriptionCategory.entertainment,
    required this.nextPaymentDate,
    this.iconKey = 'receipt',
    this.monogram,
    this.colorHex = 0xFF6C63FF,
    this.reminderDaysBefore = 2,
    this.isFreeTrial = false,
    this.sharedWithCount = 1,
    this.notes,
    this.isActive = true,
  });

  /// Ortak aboneliklerde kullanıcının kendi payına düşen tutar.
  double get userShareAmount {
    final divisor = sharedWithCount < 1 ? 1 : sharedWithCount;
    return amount / divisor;
  }

  /// Kullanıcının kendi payının tek dönemlik TL karşılığı.
  double userShareInTry({required double usdRate, required double eurRate}) {
    return CurrencyFormatter.convertToTry(
      userShareAmount,
      currency: currency,
      usdRate: usdRate,
      eurRate: eurRate,
    );
  }

  /// Aylık normalize edilmiş TL maliyeti (ör. yıllık ise 12'ye bölünür).
  double monthlyNormalizedTry({
    required double usdRate,
    required double eurRate,
  }) {
    if (!isActive) return 0;
    final cycleTry = userShareInTry(usdRate: usdRate, eurRate: eurRate);
    switch (period) {
      case BillingPeriod.weekly:
        return cycleTry * (52.0 / 12.0);
      case BillingPeriod.monthly:
        return cycleTry;
      case BillingPeriod.quarterly:
        return cycleTry / 3.0;
      case BillingPeriod.yearly:
        return cycleTry / 12.0;
    }
  }

  /// Yıllık toplam tahmini TL maliyeti.
  double yearlyNormalizedTry({
    required double usdRate,
    required double eurRate,
  }) {
    return monthlyNormalizedTry(usdRate: usdRate, eurRate: eurRate) * 12.0;
  }

  /// Verilen referans güne göre sonraki ödemeye kalan gün sayısı.
  int daysUntilNextPayment([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      nextPaymentDate.year,
      nextPaymentDate.month,
      nextPaymentDate.day,
    );
    return target.difference(today).inDays;
  }

  /// Yerel bildirimler için deterministik pozitif tam sayı kimliği.
  int get notificationId => id.hashCode & 0x3FFFFFFF;

  /// Belirtilen takvim gününde bu aboneliğin ödemesi olup olmadığını hesaplar.
  bool occursOnDay(DateTime day) {
    if (!isActive) return false;
    final target = DateTime(day.year, day.month, day.day);
    final anchor = DateTime(
      nextPaymentDate.year,
      nextPaymentDate.month,
      nextPaymentDate.day,
    );

    if (target.isBefore(anchor)) return false;
    if (target == anchor) return true;

    switch (period) {
      case BillingPeriod.weekly:
        final diffDays = target.difference(anchor).inDays;
        return diffDays % 7 == 0;
      case BillingPeriod.monthly:
        final expectedDay = _clampDayToMonth(
          anchor.day,
          target.year,
          target.month,
        );
        return target.day == expectedDay;
      case BillingPeriod.quarterly:
        final monthDiff =
            (target.year - anchor.year) * 12 + (target.month - anchor.month);
        if (monthDiff < 0 || monthDiff % 3 != 0) return false;
        final expectedDay = _clampDayToMonth(
          anchor.day,
          target.year,
          target.month,
        );
        return target.day == expectedDay;
      case BillingPeriod.yearly:
        if (target.month != anchor.month) return false;
        final expectedDay = _clampDayToMonth(
          anchor.day,
          target.year,
          target.month,
        );
        return target.day == expectedDay;
    }
  }

  /// Ödeme tamamlandığında tarihi bir sonraki periyoda ilerletir.
  Subscription advanceToNextCycle() {
    final anchor = DateTime(
      nextPaymentDate.year,
      nextPaymentDate.month,
      nextPaymentDate.day,
    );
    DateTime nextDate;
    switch (period) {
      case BillingPeriod.weekly:
        nextDate = anchor.add(const Duration(days: 7));
        break;
      case BillingPeriod.monthly:
        nextDate = _addMonthsClamped(anchor, 1);
        break;
      case BillingPeriod.quarterly:
        nextDate = _addMonthsClamped(anchor, 3);
        break;
      case BillingPeriod.yearly:
        nextDate = _addMonthsClamped(anchor, 12);
        break;
    }
    return copyWith(
      nextPaymentDate: nextDate,
      isFreeTrial: false,
    );
  }

  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static int _clampDayToMonth(int desiredDay, int year, int month) {
    final maxDay = _daysInMonth(year, month);
    return desiredDay > maxDay ? maxDay : desiredDay;
  }

  static DateTime _addMonthsClamped(DateTime date, int monthsToAdd) {
    final totalMonths = date.year * 12 + (date.month - 1) + monthsToAdd;
    final newYear = totalMonths ~/ 12;
    final newMonth = (totalMonths % 12) + 1;
    final clampedDay = _clampDayToMonth(date.day, newYear, newMonth);
    return DateTime(newYear, newMonth, clampedDay);
  }

  Subscription copyWith({
    String? id,
    String? name,
    double? amount,
    CurrencyCode? currency,
    BillingPeriod? period,
    SubscriptionCategory? category,
    DateTime? nextPaymentDate,
    String? iconKey,
    String? monogram,
    bool clearMonogram = false,
    int? colorHex,
    int? reminderDaysBefore,
    bool? isFreeTrial,
    int? sharedWithCount,
    String? notes,
    bool clearNotes = false,
    bool? isActive,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      category: category ?? this.category,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      iconKey: iconKey ?? this.iconKey,
      monogram: clearMonogram ? null : (monogram ?? this.monogram),
      colorHex: colorHex ?? this.colorHex,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      isFreeTrial: isFreeTrial ?? this.isFreeTrial,
      sharedWithCount: sharedWithCount ?? this.sharedWithCount,
      notes: clearNotes ? null : (notes ?? this.notes),
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'currency': currency.code,
      'period': period.key,
      'category': category.key,
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'iconKey': iconKey,
      'monogram': monogram,
      'colorHex': colorHex,
      'reminderDaysBefore': reminderDaysBefore,
      'isFreeTrial': isFreeTrial,
      'sharedWithCount': sharedWithCount,
      'notes': notes,
      'isActive': isActive,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: CurrencyCode.fromCode(json['currency'] as String?),
      period: BillingPeriod.fromKey(json['period'] as String?),
      category: SubscriptionCategory.fromKey(json['category'] as String?),
      nextPaymentDate: DateTime.parse(json['nextPaymentDate'] as String),
      iconKey: (json['iconKey'] as String?) ?? 'receipt',
      monogram: json['monogram'] as String?,
      colorHex: (json['colorHex'] as int?) ?? 0xFF6C63FF,
      reminderDaysBefore: (json['reminderDaysBefore'] as int?) ?? 2,
      isFreeTrial: (json['isFreeTrial'] as bool?) ?? false,
      sharedWithCount: (json['sharedWithCount'] as int?) ?? 1,
      notes: json['notes'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }
}


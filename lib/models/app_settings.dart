class AppSettings {
  final double usdRate;
  final double eurRate;
  final bool autoUpdateRates;
  final int rateRefreshSeconds;
  final DateTime? ratesUpdatedAt;
  final String? ratesSource;
  final int reminderHour;
  final bool notificationsEnabled;

  const AppSettings({
    this.usdRate = 34.50,
    this.eurRate = 37.50,
    this.autoUpdateRates = true,
    this.rateRefreshSeconds = 15,
    this.ratesUpdatedAt,
    this.ratesSource,
    this.reminderHour = 9,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    double? usdRate,
    double? eurRate,
    bool? autoUpdateRates,
    int? rateRefreshSeconds,
    DateTime? ratesUpdatedAt,
    String? ratesSource,
    int? reminderHour,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      usdRate: usdRate ?? this.usdRate,
      eurRate: eurRate ?? this.eurRate,
      autoUpdateRates: autoUpdateRates ?? this.autoUpdateRates,
      rateRefreshSeconds: rateRefreshSeconds ?? this.rateRefreshSeconds,
      ratesUpdatedAt: ratesUpdatedAt ?? this.ratesUpdatedAt,
      ratesSource: ratesSource ?? this.ratesSource,
      reminderHour: reminderHour ?? this.reminderHour,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usdRate': usdRate,
      'eurRate': eurRate,
      'autoUpdateRates': autoUpdateRates,
      'rateRefreshSeconds': rateRefreshSeconds,
      'ratesUpdatedAt': ratesUpdatedAt?.toIso8601String(),
      'ratesSource': ratesSource,
      'reminderHour': reminderHour,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawUpdatedAt = json['ratesUpdatedAt'] as String?;
    final rawInterval = (json['rateRefreshSeconds'] as int?) ?? 15;
    final safeInterval = rawInterval < 10 ? 10 : rawInterval;
    return AppSettings(
      usdRate: (json['usdRate'] as num?)?.toDouble() ?? 34.50,
      eurRate: (json['eurRate'] as num?)?.toDouble() ?? 37.50,
      autoUpdateRates: (json['autoUpdateRates'] as bool?) ?? true,
      rateRefreshSeconds: safeInterval,
      ratesUpdatedAt:
          rawUpdatedAt != null ? DateTime.tryParse(rawUpdatedAt) : null,
      ratesSource: json['ratesSource'] as String?,
      reminderHour: (json['reminderHour'] as int?) ?? 9,
      notificationsEnabled: (json['notificationsEnabled'] as bool?) ?? true,
    );
  }
}

class AppSettings {
  final double usdRate;
  final double eurRate;
  final int reminderHour;
  final bool notificationsEnabled;
  final bool storeSafeScreenshotMode;

  const AppSettings({
    this.usdRate = 34.50,
    this.eurRate = 37.50,
    this.reminderHour = 9,
    this.notificationsEnabled = true,
    this.storeSafeScreenshotMode = false,
  });

  AppSettings copyWith({
    double? usdRate,
    double? eurRate,
    int? reminderHour,
    bool? notificationsEnabled,
    bool? storeSafeScreenshotMode,
  }) {
    return AppSettings(
      usdRate: usdRate ?? this.usdRate,
      eurRate: eurRate ?? this.eurRate,
      reminderHour: reminderHour ?? this.reminderHour,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      storeSafeScreenshotMode:
          storeSafeScreenshotMode ?? this.storeSafeScreenshotMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usdRate': usdRate,
      'eurRate': eurRate,
      'reminderHour': reminderHour,
      'notificationsEnabled': notificationsEnabled,
      'storeSafeScreenshotMode': storeSafeScreenshotMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      usdRate: (json['usdRate'] as num?)?.toDouble() ?? 34.50,
      eurRate: (json['eurRate'] as num?)?.toDouble() ?? 37.50,
      reminderHour: (json['reminderHour'] as int?) ?? 9,
      notificationsEnabled: (json['notificationsEnabled'] as bool?) ?? true,
      storeSafeScreenshotMode:
          (json['storeSafeScreenshotMode'] as bool?) ?? false,
    );
  }
}


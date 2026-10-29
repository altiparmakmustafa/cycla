import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../models/app_settings.dart';
import '../../models/subscription.dart';
import '../utils/currency_formatter.dart';

/// Sunucu gerektirmeyen, çevrimdışı (offline) cihaz içi bildirim motoru.
/// Web üzerinde çalıştırıldığında güvenli şekilde devre dışı kalır (crash olmaz).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (_) {
      // Varsayılan yerel saat dilimi korunur
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);

    // Android 13+ (API 33+) cihazlarda çalışma zamanı bildirim izni isteği
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> syncAllReminders(
    List<Subscription> subscriptions,
    AppSettings settings,
  ) async {
    if (kIsWeb || !_initialized) return;

    await _plugin.cancelAll();
    if (!settings.notificationsEnabled) return;

    for (final sub in subscriptions) {
      if (sub.isActive) {
        await scheduleForSubscription(sub, settings);
      }
    }
  }

  Future<void> scheduleForSubscription(
    Subscription sub,
    AppSettings settings,
  ) async {
    if (kIsWeb || !_initialized || !settings.notificationsEnabled) return;

    await cancelForSubscription(sub);
    if (!sub.isActive) return;

    final now = tz.TZDateTime.now(tz.local);
    final reminderDate = sub.nextPaymentDate.subtract(
      Duration(days: sub.reminderDaysBefore),
    );

    final scheduledTime = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      settings.reminderHour,
      0,
    );

    final formattedPrice = CurrencyFormatter.format(
      sub.userShareAmount,
      currency: sub.currency,
    );

    if (scheduledTime.isAfter(now)) {
      final dayText = sub.reminderDaysBefore == 0
          ? 'bugün'
          : '${sub.reminderDaysBefore} gün sonra';

      await _plugin.zonedSchedule(
        sub.notificationId,
        'Ödeme Hatırlatması: ${sub.name}',
        '${sub.name} için $formattedPrice tutarındaki ödemeniz $dayText gerçekleşecek.',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'subscription_reminders',
            'Fatura ve Abonelik Hatırlatıcıları',
            channelDescription: 'Yaklaşan fatura ve abonelik ödeme uyarıları',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    // Deneme sürümü savar: Çekimden 24 saat önce ekstra kritik uyarı!
    if (sub.isFreeTrial && sub.reminderDaysBefore != 1) {
      final trialWarnDate =
          sub.nextPaymentDate.subtract(const Duration(days: 1));
      final trialWarnTime = tz.TZDateTime(
        tz.local,
        trialWarnDate.year,
        trialWarnDate.month,
        trialWarnDate.day,
        settings.reminderHour,
        30,
      );

      if (trialWarnTime.isAfter(now)) {
        await _plugin.zonedSchedule(
          sub.notificationId + 100000,
          'Deneme Sürümü Yarın Bitiyor: ${sub.name}',
          'Devam etmek istemiyorsanız bugün iptal edin; aksi halde yarın $formattedPrice çekilecek.',
          trialWarnTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'free_trial_alerts',
              'Deneme Sürümü Uyarıları',
              channelDescription: 'Ücretsiz deneme bitiş uyarıları',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBanner: true,
              presentList: true,
              presentBadge: true,
              presentSound: true,
            ),
            macOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBanner: true,
              presentList: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  Future<void> cancelForSubscription(Subscription sub) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(sub.notificationId);
    await _plugin.cancel(sub.notificationId + 100000);
  }
}


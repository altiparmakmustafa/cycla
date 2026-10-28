import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/legal_texts.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/cycla_logo.dart';
import '../../models/app_settings.dart';
import '../../providers/subscription_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _usdController;
  late TextEditingController _eurController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _usdController =
        TextEditingController(text: settings.usdRate.toStringAsFixed(2));
    _eurController =
        TextEditingController(text: settings.eurRate.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _usdController.dispose();
    _eurController.dispose();
    super.dispose();
  }

  Future<void> _saveManualRates() async {
    final settings = ref.read(settingsProvider);
    final usd =
        double.tryParse(_usdController.text.trim().replaceAll(',', '.')) ??
            settings.usdRate;
    final eur =
        double.tryParse(_eurController.text.trim().replaceAll(',', '.')) ??
            settings.eurRate;

    await ref.read(settingsProvider.notifier).updateSettings(
          settings.copyWith(
            usdRate: usd > 0 ? usd : settings.usdRate,
            eurRate: eur > 0 ? eur : settings.eurRate,
            ratesUpdatedAt: DateTime.now(),
            ratesSource: 'Manuel Giriş',
          ),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manuel döviz kurları kaydedildi.')),
      );
    }
  }

  Future<void> _confirmClearAll() async {
    final count = ref.read(subscriptionsProvider).length;
    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silinecek kayıt bulunmuyor.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Tüm Kayıtları Sil'),
        content: Text(
          'Kayıtlı $count adet fatura/abonelik kalıcı olarak silinecek. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tümünü Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(subscriptionsProvider.notifier).clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tüm kayıtlarınız temizlendi.')),
        );
      }
    }
  }

  void _showLegalDisclaimerDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Row(
          children: [
            Icon(Icons.gavel_outlined, color: AppColors.secondary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                LegalTexts.disclaimerTitle,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            LegalTexts.trademarkDisclaimer,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Canlı kur otomatik güncellendiğinde metin kutularını eşitle
    ref.listen<AppSettings>(settingsProvider, (previous, next) {
      if (previous?.usdRate != next.usdRate) {
        _usdController.text = next.usdRate.toStringAsFixed(2);
      }
      if (previous?.eurRate != next.eurRate) {
        _eurController.text = next.eurRate.toStringAsFixed(2);
      }
    });

    final settings = ref.watch(settingsProvider);
    final isFetching = ref.watch(isFetchingRatesProvider);

    final lastUpdateLabel = settings.ratesUpdatedAt != null
        ? 'Son otomatik güncelleme: ${DateFormat('HH:mm:ss', 'tr_TR').format(settings.ratesUpdatedAt!)} (${settings.ratesSource ?? 'Canlı'})'
        : 'Canlı kurlar otomatik alınıyor...';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayarlar',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          // Canlı Döviz Kuru Bölümü (Tam Otomatik Periyodik Güncelleme)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Canlı Döviz Kurları (USD & EUR)',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    if (isFetching)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  lastUpdateLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: settings.ratesUpdatedAt != null
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Anlık Kur Bilgi Kartları
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '1 USD',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(settings.usdRate),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '1 EUR',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(settings.eurRate),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Otomatik Canlı Kur Güncelleme'),
                  subtitle: Text(
                    settings.autoUpdateRates
                        ? 'Her ${settings.rateRefreshSeconds} saniyede bir otomatik güncellenir'
                        : 'Otomatik güncelleme kapalı (manuel kur aktif)',
                  ),
                  value: settings.autoUpdateRates,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).updateSettings(
                          settings.copyWith(autoUpdateRates: val),
                        );
                  },
                ),

                if (settings.autoUpdateRates) ...[
                  const Text(
                    'Otomatik Güncelleme Sıklığı',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final sec in [10, 15, 30])
                        ChoiceChip(
                          label: Text('$sec Saniye'),
                          selected: settings.rateRefreshSeconds == sec,
                          onSelected: (_) {
                            ref.read(settingsProvider.notifier).updateSettings(
                                  settings.copyWith(rateRefreshSeconds: sec),
                                );
                          },
                        ),
                    ],
                  ),
                ] else ...[
                  const Divider(),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usdController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: '1 USD (₺)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _eurController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: '1 EUR (₺)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _saveManualRates,
                      icon: const Icon(Icons.save_outlined, size: 17),
                      label: const Text('Manuel Kuru Kaydet'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bildirim Ayarları
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bildirimler',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ödeme Hatırlatıcıları'),
                  subtitle: const Text(
                    'Yaklaşan fatura ve deneme sürümü uyarılarını etkinleştir',
                  ),
                  value: settings.notificationsEnabled,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).updateSettings(
                          settings.copyWith(notificationsEnabled: val),
                        );
                  },
                ),
                const Divider(),
                const Text(
                  'Günlük Hatırlatma Saati',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final hour in [8, 9, 10, 12, 18, 20])
                      ChoiceChip(
                        label: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                        ),
                        selected: settings.reminderHour == hour,
                        onSelected: (_) {
                          ref.read(settingsProvider.notifier).updateSettings(
                                settings.copyWith(reminderHour: hour),
                              );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Veri Yönetimi ve Hakkında
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Veri ve Yasal Bilgiler',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.gavel_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(LegalTexts.disclaimerTitle),
                  subtitle: const Text(
                    'Marka hakları ve dürüst tanımlayıcı kullanım bildirimi',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showLegalDisclaimerDialog,
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.delete_sweep_outlined,
                    color: AppColors.danger,
                  ),
                  title: const Text(
                    'Tüm Kayıtlarımı Sil',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  subtitle: const Text(
                    'Eklediğiniz tüm fatura ve abonelikleri cihazdan kaldırır',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: _confirmClearAll,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Column(
            children: [
              CyclaLogo(size: 46, borderRadius: 13),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Cycla v1.0.0 • Tüm verileriniz yalnızca kendi cihazınızda saklanır.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

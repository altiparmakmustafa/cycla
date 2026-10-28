import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/legal_texts.dart';
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

  Future<void> _saveRates() async {
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
          ),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Döviz kurları güncellendi.')),
      );
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
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayarlar & Yasal Bilgiler',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
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

          // Döviz Kurları
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
                  'Döviz Kuru Hesaplama (Çevrimdışı)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'USD ve EUR bazlı aboneliklerin TL karşılığını hesaplamak için kullanılır.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
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
                  child: FilledButton.tonalIcon(
                    onPressed: _saveRates,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Kurları Güncelle'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Hukuki ve Mağaza Güvenliği Modu (App Store / Google Play İnceleme Koruması)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.secondary.withOpacityFactor(0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Mağaza & Marka Hukuku Koruması',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mağaza Ekran Görüntüsü Modu'),
                  subtitle: const Text(
                    LegalTexts.storeSafeModeExplanation,
                    style: TextStyle(fontSize: 12),
                  ),
                  value: settings.storeSafeScreenshotMode,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).updateSettings(
                          settings.copyWith(storeSafeScreenshotMode: val),
                        );
                  },
                ),
                const Divider(),
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
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Veri Yönetimi
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
                  'Veri Yönetimi',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.restore_outlined,
                    color: AppColors.secondary,
                  ),
                  title: const Text('Örnek Verileri Yeniden Yükle'),
                  onTap: () async {
                    await ref
                        .read(subscriptionsProvider.notifier)
                        .resetToDemoData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Örnek abonelik listesi yüklendi.'),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.delete_sweep_outlined,
                    color: AppColors.danger,
                  ),
                  title: const Text(
                    'Tüm Kayıtları Temizle',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  onTap: () async {
                    await ref.read(subscriptionsProvider.notifier).clearAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tüm kayıtlar temizlendi.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Alt Bilgi Yasal Feragatname Özeti
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Bu uygulamada hiçbir şirketin tescilli logosu yer almaz. '
              'Hizmet adları yalnızca kişisel bütçe takibi amacıyla tanımlayıcı olarak gösterilir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


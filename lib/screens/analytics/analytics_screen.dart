import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/subscription.dart';
import '../../providers/subscription_providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _touchedIndex = -1;

  static const List<Color> _chartPalette = [
    Color(0xFF6C63FF),
    Color(0xFF00D2B8),
    Color(0xFFFFB74D),
    Color(0xFFE53935),
    Color(0xFF29B6F6),
    Color(0xFFAB47BC),
    Color(0xFF78909C),
  ];

  @override
  Widget build(BuildContext context) {
    final breakdown = ref.watch(categoryBreakdownProvider);
    final monthlyTotal = ref.watch(monthlyTotalTryProvider);
    final yearlyTotal = ref.watch(yearlyTotalTryProvider);
    final allSubs = ref.watch(subscriptionsProvider);
    final settings = ref.watch(settingsProvider);

    final activeSubs = allSubs.where((s) => s.isActive).toList()
      ..sort(
        (a, b) => b
            .yearlyNormalizedTry(
              usdRate: settings.usdRate,
              eurRate: settings.eurRate,
            )
            .compareTo(
              a.yearlyNormalizedTry(
                usdRate: settings.usdRate,
                eurRate: settings.eurRate,
              ),
            ),
      );

    final entries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Tasarruf ipucu için en yüksek maliyetli dijital/eğlence aboneliği bul
    final optionalCandidates = activeSubs.where((s) {
      return s.category == SubscriptionCategory.entertainment ||
          s.category == SubscriptionCategory.softwareAndAi ||
          s.category == SubscriptionCategory.healthAndFitness;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Harcama Analizi',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: entries.isEmpty
          ? const Center(
              child: Text(
                'Analiz için en az bir aktif abonelik ekleyin.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
              children: [
                // Kategori Dağılımı Pasta Grafiği
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aylık Kategori Dağılımı',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 210,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 50,
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, response) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      response == null ||
                                      response.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = response
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sections: [
                              for (int i = 0; i < entries.length; i++)
                                PieChartSectionData(
                                  color: _chartPalette[i % _chartPalette.length],
                                  value: entries[i].value,
                                  radius: i == _touchedIndex ? 62 : 52,
                                  title: monthlyTotal > 0
                                      ? '%${((entries[i].value / monthlyTotal) * 100).round()}'
                                      : '',
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      for (int i = 0; i < entries.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color:
                                      _chartPalette[i % _chartPalette.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entries[i].key.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${CurrencyFormatter.format(entries[i].value)} / ay',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Akıllı Tasarruf Önerisi ("Kullanıyor musun?" Dedektifi)
                if (optionalCandidates.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final topSub = optionalCandidates.first;
                      final annualCost = topSub.yearlyNormalizedTry(
                        usdRate: settings.usdRate,
                        eurRate: settings.eurRate,
                      );
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacityFactor(0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.secondary.withOpacityFactor(0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.savings_outlined,
                              color: AppColors.secondary,
                              size: 26,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tasarruf İpucu',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${topSub.displayName(settings)}" aboneliğinizi aktif kullanmıyorsanız duraklatarak yılda yaklaşık ${CurrencyFormatter.format(annualCost, decimalDigits: 0)} tasarruf edebilirsiniz.',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Yıllık Maliyet Sıralaması
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Yıllık Maliyet Sıralaması',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Toplam: ${CurrencyFormatter.format(yearlyTotal, decimalDigits: 0)}/yıl',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      for (final sub in activeSubs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      sub.displayName(settings),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${CurrencyFormatter.format(sub.yearlyNormalizedTry(usdRate: settings.usdRate, eurRate: settings.eurRate), decimalDigits: 0)} / yıl',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: yearlyTotal > 0
                                      ? (sub.yearlyNormalizedTry(
                                                usdRate: settings.usdRate,
                                                eurRate: settings.eurRate,
                                              ) /
                                              yearlyTotal)
                                          .clamp(0.0, 1.0)
                                      : 0,
                                  minHeight: 7,
                                  backgroundColor: Colors.white10,
                                  color: Color(sub.colorHex),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}


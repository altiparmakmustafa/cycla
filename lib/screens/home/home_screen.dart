import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/symbolic_icons.dart';
import '../../core/widgets/cycla_logo.dart';
import '../../models/service_template.dart';
import '../../models/subscription.dart';
import '../../providers/subscription_providers.dart';
import '../add_edit/add_edit_subscription_screen.dart';
import 'widgets/live_rates_bar.dart';
import 'widgets/subscription_tile.dart';
import 'widgets/summary_hero_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSubs = ref.watch(subscriptionsProvider);
    final filteredSubs = ref.watch(filteredSubscriptionsProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final monthlyTotal = ref.watch(monthlyTotalTryProvider);
    final yearlyTotal = ref.watch(yearlyTotalTryProvider);
    final upcoming = ref.watch(upcoming7DaysProvider);
    final expiringTrials = ref.watch(expiringFreeTrialsProvider);
    final settings = ref.watch(settingsProvider);

    final activeCount = allSubs.where((s) => s.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CyclaLogo(size: 38, borderRadius: 11),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cycla',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 21),
                ),
                Text(
                  'Fatura & Abonelik Takipçisi',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Yeni Fatura / Abonelik Ekle',
            onPressed: () => _openAddOrEdit(context),
            icon: const Icon(Icons.add_circle_outline, size: 26),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          SummaryHeroCard(
            monthlyTotalTry: monthlyTotal,
            yearlyTotalTry: yearlyTotal,
            activeCount: activeCount,
            upcomingCount: upcoming.length,
          ),
          const SizedBox(height: 12),
          const LiveRatesBar(),
          const SizedBox(height: 16),

          // Deneme Sürümü Savar Uyarı Kartı
          if (expiringTrials.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacityFactor(0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withOpacityFactor(0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deneme Sürümü Bitiş Uyarısı!',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expiringTrials
                              .map(
                                (s) =>
                                    '${s.name} (${s.daysUntilNextPayment()} gün kaldı)',
                              )
                              .join(', '),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Eğer kullanıcının henüz hiç kaydı yoksa karşılama ve hızlı ekleme ekranı
          if (allSubs.isEmpty)
            _buildFirstTimeOnboardingCard(context)
          else ...[
            // Kategori Filtre Çubuğu
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Tümü'),
                      selected: selectedCategory == null,
                      onSelected: (_) {
                        ref
                            .read(selectedCategoryFilterProvider.notifier)
                            .state = null;
                      },
                    ),
                  ),
                  for (final category in SubscriptionCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(category.icon, size: 16),
                        label: Text(category.label),
                        selected: selectedCategory == category,
                        onSelected: (_) {
                          ref
                              .read(selectedCategoryFilterProvider.notifier)
                              .state = selectedCategory == category
                              ? null
                              : category;
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCategory == null
                      ? 'Ödeme Sırasına Göre Kayıtlarım'
                      : selectedCategory.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${filteredSubs.length} kayıt',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (filteredSubs.isEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.filter_list_off,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Seçili kategoride henüz bir kaydınız bulunmuyor.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _openAddOrEdit(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Bu Kategoriye Ekle'),
                    ),
                  ],
                ),
              )
            else
              for (final sub in filteredSubs)
                SubscriptionTile(
                  subscription: sub,
                  settings: settings,
                  onEdit: () => _openAddOrEdit(context, existing: sub),
                  onMarkPaid: () {
                    ref
                        .read(subscriptionsProvider.notifier)
                        .markCyclePaidAndAdvance(sub);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${sub.name} sonraki döneme ilerletildi.',
                        ),
                      ),
                    );
                  },
                  onToggleActive: () {
                    ref.read(subscriptionsProvider.notifier).toggleActive(sub);
                  },
                  onDelete: () {
                    ref
                        .read(subscriptionsProvider.notifier)
                        .deleteSubscription(sub);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${sub.name} silindi.'),
                      ),
                    );
                  },
                ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddOrEdit(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text(
          'Fatura / Abonelik Ekle',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildFirstTimeOnboardingCard(BuildContext context) {
    final quickTemplates = ServiceTemplate.presets.take(6).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withOpacityFactor(0.28),
        ),
      ),
      child: Column(
        children: [
          const CyclaLogo(size: 72, borderRadius: 20),
          const SizedBox(height: 16),
          const Text(
            'Henüz Fatura veya Abonelik Eklemediniz',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aylık sabit giderlerinizi görmek, takvimde takip etmek ve ödeme yaklaşınca bildirim almak için kendi fatura veya aboneliklerinizi ekleyin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _openAddOrEdit(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Kendi Kaydımı Oluştur',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          const SizedBox(height: 22),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            'Veya hazır şablonla hızlıca ekleyin:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final tpl in quickTemplates)
                ActionChip(
                  avatar: Icon(
                    SymbolicIcons.fromKey(tpl.iconKey),
                    size: 16,
                    color: Color(tpl.colorHex),
                  ),
                  label: Text('+ ${tpl.name}'),
                  onPressed: () =>
                      _openAddOrEdit(context, initialTemplate: tpl),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _openAddOrEdit(
    BuildContext context, {
    Subscription? existing,
    ServiceTemplate? initialTemplate,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditSubscriptionScreen(
          existing: existing,
          initialTemplate: initialTemplate,
        ),
      ),
    );
  }
}

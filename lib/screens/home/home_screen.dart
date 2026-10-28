import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/subscription.dart';
import '../../providers/subscription_providers.dart';
import '../add_edit/add_edit_subscription_screen.dart';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cycla',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            Text(
              settings.storeSafeScreenshotMode
                  ? 'Mağaza Görünümü Aktif (Jenerik İsimler)'
                  : 'Fatura & Abonelik Takipçisi',
              style: TextStyle(
                fontSize: 11.5,
                color: settings.storeSafeScreenshotMode
                    ? AppColors.secondary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Yeni Ekle',
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
                                    '${s.displayName(settings)} (${s.daysUntilNextPayment()} gün kaldı)',
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
                      ref.read(selectedCategoryFilterProvider.notifier).state =
                          null;
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
                    ? 'Ödeme Sırasına Göre Kayıtlar'
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
              padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bu görünümde henüz fatura veya abonelik yok.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _openAddOrEdit(context),
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Aboneliği Ekle'),
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
                        '${sub.displayName(settings)} sonraki döneme ilerletildi.',
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
                      content: Text('${sub.displayName(settings)} silindi.'),
                    ),
                  );
                },
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddOrEdit(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Yeni Ekle',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _openAddOrEdit(BuildContext context, {Subscription? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditSubscriptionScreen(existing: existing),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/symbolic_icons.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/app_settings.dart';
import '../../../models/subscription.dart';
import '../../../providers/subscription_providers.dart';

class SubscriptionTile extends StatelessWidget {
  final Subscription subscription;
  final AppSettings settings;
  final VoidCallback onEdit;
  final VoidCallback onMarkPaid;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const SubscriptionTile({
    super.key,
    required this.subscription,
    required this.settings,
    required this.onEdit,
    required this.onMarkPaid,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(subscription.colorHex);
    final daysLeft = subscription.daysUntilNextPayment();
    final title = subscription.displayName(settings);
    final sharePrice = CurrencyFormatter.format(
      subscription.userShareAmount,
      currency: subscription.currency,
    );
    final tryEquivalent = subscription.userShareInTry(
      usdRate: settings.usdRate,
      eurRate: settings.eurRate,
    );

    final statusColor = _resolveCountdownColor(daysLeft, subscription.isActive);
    final statusLabel = _resolveCountdownText(daysLeft, subscription.isActive);
    final dateText =
        DateFormat('d MMM yyyy', 'tr_TR').format(subscription.nextPaymentDate);

    return Opacity(
      opacity: subscription.isActive ? 1.0 : 0.55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: subscription.isFreeTrial && subscription.isActive
                ? AppColors.warning.withOpacityFactor(0.55)
                : Colors.white.withOpacityFactor(0.06),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showActionSheet(context, title),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Sembolik İkon veya Kullanıcı Rozeti (Tescilli logo içermez)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacityFactor(0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accentColor.withOpacityFactor(0.45),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: (subscription.monogram != null &&
                          subscription.monogram!.trim().isNotEmpty)
                      ? Text(
                          subscription.monogram!.trim(),
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        )
                      : Icon(
                          SymbolicIcons.fromKey(subscription.iconKey),
                          color: accentColor,
                          size: 25,
                        ),
                ),
                const SizedBox(width: 14),

                // Başlık, Etiketler ve Sonraki Tarih
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (subscription.isFreeTrial) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacityFactor(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'DENEME',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '$dateText • ${subscription.period.label}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (subscription.sharedWithCount > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.secondary.withOpacityFactor(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${subscription.sharedWithCount} Kişi Ortak',
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Tutar ve Kalan Gün
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      sharePrice,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subscription.currency != CurrencyCode.tryCode)
                      Text(
                        '≈ ${CurrencyFormatter.format(tryEquivalent)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacityFactor(0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _resolveCountdownColor(int daysLeft, bool isActive) {
    if (!isActive) return AppColors.textSecondary;
    if (daysLeft < 0) return AppColors.danger;
    if (daysLeft <= 3) return AppColors.warning;
    return AppColors.secondary;
  }

  String _resolveCountdownText(int daysLeft, bool isActive) {
    if (!isActive) return 'Duraklatıldı';
    if (daysLeft < 0) return '${daysLeft.abs()} gün gecikti';
    if (daysLeft == 0) return 'Bugün!';
    if (daysLeft == 1) return 'Yarın';
    return '$daysLeft gün kaldı';
  }

  void _showActionSheet(BuildContext context, String displayTitle) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                ListTile(
                  title: Text(
                    displayTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: subscription.notes != null &&
                          subscription.notes!.trim().isNotEmpty
                      ? Text(subscription.notes!)
                      : Text(subscription.category.label),
                ),
                const Divider(height: 8),
                if (subscription.isActive)
                  ListTile(
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                    title: const Text('Ödendi İşaretle (Sonraki Döneme Geç)'),
                    subtitle: Text(
                      'Sonraki ödeme tarihini 1 ${subscription.period.shortUnit.toLowerCase()} ileri taşır',
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onMarkPaid();
                    },
                  ),
                if (subscription.sharedWithCount > 1)
                  ListTile(
                    leading: const Icon(
                      Icons.copy_rounded,
                      color: AppColors.secondary,
                    ),
                    title: const Text('Ortak Ödeme Hatırlatmasını Kopyala'),
                    subtitle: const Text(
                      'WhatsApp / mesajlaşma uygulamalarında paylaşmak için',
                    ),
                    onTap: () {
                      final totalFormatted = CurrencyFormatter.format(
                        subscription.amount,
                        currency: subscription.currency,
                      );
                      final shareFormatted = CurrencyFormatter.format(
                        subscription.userShareAmount,
                        currency: subscription.currency,
                      );
                      final dateStr = DateFormat('d MMMM', 'tr_TR')
                          .format(subscription.nextPaymentDate);
                      final msg =
                          'Merhaba! $displayTitle ödemesi ($totalFormatted) $dateStr tarihinde gerçekleşecek. '
                          '${subscription.sharedWithCount} kişilik ortak planda kişi başı payımız: $shareFormatted.';
                      Clipboard.setData(ClipboardData(text: msg));
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ortak ödeme mesajı panoya kopyalandı!',
                          ),
                        ),
                      );
                    },
                  ),
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Düzenle'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onEdit();
                  },
                ),
                ListTile(
                  leading: Icon(
                    subscription.isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    color: AppColors.warning,
                  ),
                  title: Text(
                    subscription.isActive
                        ? 'Aboneliği Duraklat'
                        : 'Aboneliği Yeniden Aktifleştir',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onToggleActive();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.danger,
                  ),
                  title: const Text(
                    'Sil',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


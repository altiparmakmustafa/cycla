import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/symbolic_icons.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/service_template.dart';
import '../../models/subscription.dart';
import '../../providers/subscription_providers.dart';

class AddEditSubscriptionScreen extends ConsumerStatefulWidget {
  final Subscription? existing;
  final ServiceTemplate? initialTemplate;

  const AddEditSubscriptionScreen({
    super.key,
    this.existing,
    this.initialTemplate,
  });

  @override
  ConsumerState<AddEditSubscriptionScreen> createState() =>
      _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState
    extends ConsumerState<AddEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountFocusNode = FocusNode();

  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _monogramController;
  late final TextEditingController _notesController;

  late CurrencyCode _currency;
  late BillingPeriod _period;
  late SubscriptionCategory _category;
  late DateTime _nextPaymentDate;
  late String _iconKey;
  late int _colorHex;
  late int _reminderDaysBefore;
  late bool _isFreeTrial;
  late int _sharedWithCount;

  @override
  void initState() {
    super.initState();
    final sub = widget.existing;
    final tpl = widget.initialTemplate;

    _nameController = TextEditingController(
      text: sub?.name ?? tpl?.name ?? '',
    );
    _amountController = TextEditingController(
      text: sub != null ? sub.amount.toStringAsFixed(2) : '',
    );
    _monogramController = TextEditingController(text: sub?.monogram ?? '');
    _notesController = TextEditingController(text: sub?.notes ?? '');

    _currency = sub?.currency ?? tpl?.defaultCurrency ?? CurrencyCode.tryCode;
    _period = sub?.period ?? tpl?.defaultPeriod ?? BillingPeriod.monthly;
    _category =
        sub?.category ?? tpl?.category ?? SubscriptionCategory.utilities;
    _nextPaymentDate =
        sub?.nextPaymentDate ?? DateTime.now().add(const Duration(days: 7));
    _iconKey = sub?.iconKey ?? tpl?.iconKey ?? 'receipt';
    _colorHex =
        sub?.colorHex ?? tpl?.colorHex ?? AppColors.selectableCardColors.first;
    _reminderDaysBefore = sub?.reminderDaysBefore ?? 2;
    _isFreeTrial = sub?.isFreeTrial ?? false;
    _sharedWithCount = sub?.sharedWithCount ?? 1;

    if (tpl != null && sub == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _amountFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _monogramController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyTemplate(ServiceTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _category = template.category;
      _iconKey = template.iconKey;
      _colorHex = template.colorHex;
      _currency = template.defaultCurrency;
      _period = template.defaultPeriod;
    });
    _amountFocusNode.requestFocus();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextPaymentDate,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: DateTime(now.year + 5, 12, 31),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        _nextPaymentDate = picked;
      });
    }
  }

  Future<void> _confirmAndDelete() async {
    final sub = widget.existing;
    if (sub == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Kaydı Sil'),
        content: Text('"${sub.name}" kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(subscriptionsProvider.notifier).deleteSubscription(sub);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final rawAmount = _amountController.text.trim().replaceAll(',', '.');
    final parsedAmount = double.tryParse(rawAmount);
    if (parsedAmount == null || parsedAmount <= 0) return;

    final monogramText = _monogramController.text.trim();
    final notesText = _notesController.text.trim();

    final subscription = Subscription(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      amount: parsedAmount,
      currency: _currency,
      period: _period,
      category: _category,
      nextPaymentDate: DateTime(
        _nextPaymentDate.year,
        _nextPaymentDate.month,
        _nextPaymentDate.day,
      ),
      iconKey: _iconKey,
      monogram: monogramText.isEmpty ? null : monogramText,
      colorHex: _colorHex,
      reminderDaysBefore: _reminderDaysBefore,
      isFreeTrial: _isFreeTrial,
      sharedWithCount: _sharedWithCount,
      notes: notesText.isEmpty ? null : notesText,
      isActive: widget.existing?.isActive ?? true,
    );

    final notifier = ref.read(subscriptionsProvider.notifier);
    if (widget.existing == null) {
      await notifier.addSubscription(subscription);
    } else {
      await notifier.updateSubscription(subscription);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final enteredAmount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Kaydı Düzenle' : 'Yeni Fatura / Abonelik'),
        actions: [
          if (isEditing)
            IconButton(
              tooltip: 'Kaydı Sil',
              onPressed: _confirmAndDelete,
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
          children: [
            // Hızlı Şablon Seçici (Sadece Yeni Eklerken)
            if (!isEditing) ...[
              const Text(
                'Hızlı Seçim Şablonları (İsteğe Bağlı)',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ServiceTemplate.presets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tpl = ServiceTemplate.presets[index];
                    final tplColor = Color(tpl.colorHex);
                    return ActionChip(
                      avatar: Icon(
                        SymbolicIcons.fromKey(tpl.iconKey),
                        size: 17,
                        color: tplColor,
                      ),
                      label: Text(tpl.name),
                      onPressed: () => _applyTemplate(tpl),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // İsim
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Hizmet veya Fatura Adı',
                hintText: 'Örn: Elektrik, Ev İnterneti, Netflix, Kira',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Lütfen bir isim girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tutar ve Para Birimi
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Toplam Tutar (${_currency.symbol})',
                      hintText: 'Örn: 350.00',
                      prefixIcon: const Icon(Icons.payments_outlined),
                    ),
                    validator: (val) {
                      final parsed = double.tryParse(
                        (val ?? '').trim().replaceAll(',', '.'),
                      );
                      if (parsed == null || parsed <= 0) {
                        return 'Geçerli tutar girin';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final curr in CurrencyCode.values)
                        ChoiceChip(
                          label: Text(curr.code),
                          selected: _currency == curr,
                          onSelected: (_) => setState(() => _currency = curr),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ödeme Periyodu
            const Text(
              'Ödeme Periyodu',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in BillingPeriod.values)
                  ChoiceChip(
                    label: Text(p.label),
                    selected: _period == p,
                    onSelected: (_) => setState(() => _period = p),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Sonraki Ödeme Tarihi ve Hatırlatıcı
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.event_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Sonraki Ödeme / Son Fatura Tarihi'),
                    subtitle: Text(
                      DateFormat('d MMMM yyyy, EEEE', 'tr_TR')
                          .format(_nextPaymentDate),
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: _pickDate,
                      child: const Text('Tarih Seç'),
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'Bildirim Zamanı',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final days in [0, 1, 2, 3, 7])
                        ChoiceChip(
                          label: Text(
                            days == 0 ? 'Aynı Gün' : '$days Gün Önce',
                          ),
                          selected: _reminderDaysBefore == days,
                          onSelected: (_) =>
                              setState(() => _reminderDaysBefore = days),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Kategori Seçimi
            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cat in SubscriptionCategory.values)
                  ChoiceChip(
                    avatar: Icon(cat.icon, size: 16),
                    label: Text(cat.label),
                    selected: _category == cat,
                    onSelected: (_) => setState(() => _category = cat),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Deneme Sürümü & Ortak Bölüşüm
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(
                      Icons.timer_outlined,
                      color: AppColors.warning,
                    ),
                    title: const Text('Ücretsiz Deneme Sürümü (Free Trial)'),
                    subtitle: const Text(
                      'Çekimden 24 saat önce ekstra iptal hatırlatması gönderir',
                    ),
                    value: _isFreeTrial,
                    onChanged: (val) => setState(() => _isFreeTrial = val),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ortak Kişi Sayısı',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Aile planı veya ev arkadaşlarıyla bölüşüm',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _sharedWithCount > 1
                                ? () => setState(() => _sharedWithCount--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '$_sharedWithCount',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          IconButton(
                            onPressed: _sharedWithCount < 10
                                ? () => setState(() => _sharedWithCount++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_sharedWithCount > 1 && enteredAmount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Senin dönemlik payın: ${CurrencyFormatter.format(enteredAmount / _sharedWithCount, currency: _currency)}',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sembolik İkon, Harf Rozeti ve Renk Seçimi
            const Text(
              'Kart Görünümü (Sembolik İkon veya Harf Rozeti)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final hex in AppColors.selectableCardColors)
                  GestureDetector(
                    onTap: () => setState(() => _colorHex = hex),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color(hex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorHex == hex
                              ? Colors.white
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: _colorHex == hex
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in SymbolicIcons.catalog)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _iconKey = item.key),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _iconKey == item.key
                            ? Color(_colorHex).withOpacityFactor(0.25)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _iconKey == item.key
                              ? Color(_colorHex)
                              : Colors.white12,
                        ),
                      ),
                      child: Tooltip(
                        message: item.label,
                        child: Icon(
                          item.icon,
                          color: _iconKey == item.key
                              ? Color(_colorHex)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _monogramController,
              maxLength: 3,
              decoration: const InputDecoration(
                labelText: 'Özel Harf / Emoji Rozeti (İsteğe Bağlı)',
                hintText: 'Örn: EL, 🎵, ⚡ (Boş bırakılırsa sembolik ikon görünür)',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 8),

            // Notlar / Abone No / İptal Linki
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notlar / Abone No / İptal Bilgisi (İsteğe Bağlı)',
                hintText: 'Örn: Abone numarası veya iptal notu',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.check),
              label: Text(
                isEditing ? 'Değişiklikleri Kaydet' : 'Kaydet',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

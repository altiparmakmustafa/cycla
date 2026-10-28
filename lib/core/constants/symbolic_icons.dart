import 'package:flutter/material.dart';

/// HUKUKSAL GÜVENLİK KATMANI:
/// Üçüncü taraf şirketlerin tescilli logolarını uygulamaya gömmek yerine,
/// standart Material sembolik ikonlarını anahtar (string key) bazında tutarız.
/// Böylece telif/marka ihlali ve App Store / Google Play reddi riski sıfırlanır.
class SymbolicIconEntry {
  final String key;
  final String label;
  final IconData icon;

  const SymbolicIconEntry({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class SymbolicIcons {
  SymbolicIcons._();

  static const List<SymbolicIconEntry> catalog = [
    SymbolicIconEntry(
      key: 'movie',
      label: 'Sinema & Dizi',
      icon: Icons.movie_outlined,
    ),
    SymbolicIconEntry(
      key: 'music',
      label: 'Müzik & Podcast',
      icon: Icons.headphones_outlined,
    ),
    SymbolicIconEntry(
      key: 'video',
      label: 'Video Platformu',
      icon: Icons.play_circle_outline,
    ),
    SymbolicIconEntry(
      key: 'cloud',
      label: 'Bulut Depolama',
      icon: Icons.cloud_outlined,
    ),
    SymbolicIconEntry(
      key: 'wifi',
      label: 'Ev İnterneti',
      icon: Icons.wifi,
    ),
    SymbolicIconEntry(
      key: 'mobile',
      label: 'Mobil Hat / GSM',
      icon: Icons.phone_iphone,
    ),
    SymbolicIconEntry(
      key: 'electricity',
      label: 'Elektrik',
      icon: Icons.bolt,
    ),
    SymbolicIconEntry(
      key: 'water',
      label: 'Su Faturası',
      icon: Icons.water_drop_outlined,
    ),
    SymbolicIconEntry(
      key: 'gas',
      label: 'Doğalgaz / Isınma',
      icon: Icons.local_fire_department_outlined,
    ),
    SymbolicIconEntry(
      key: 'ai',
      label: 'Yapay Zeka & Araçlar',
      icon: Icons.auto_awesome_outlined,
    ),
    SymbolicIconEntry(
      key: 'code',
      label: 'Yazılım & Geliştirici',
      icon: Icons.code,
    ),
    SymbolicIconEntry(
      key: 'gaming',
      label: 'Oyun Servisi',
      icon: Icons.sports_esports_outlined,
    ),
    SymbolicIconEntry(
      key: 'fitness',
      label: 'Spor & Sağlık',
      icon: Icons.fitness_center,
    ),
    SymbolicIconEntry(
      key: 'education',
      label: 'Eğitim & Kitap',
      icon: Icons.school_outlined,
    ),
    SymbolicIconEntry(
      key: 'shopping',
      label: 'Alışveriş & Kargo Üyeliği',
      icon: Icons.shopping_bag_outlined,
    ),
    SymbolicIconEntry(
      key: 'home',
      label: 'Kira & Site Aidatı',
      icon: Icons.home_outlined,
    ),
    SymbolicIconEntry(
      key: 'security',
      label: 'Sigorta & Güvenlik',
      icon: Icons.security_outlined,
    ),
    SymbolicIconEntry(
      key: 'receipt',
      label: 'Genel Fatura',
      icon: Icons.receipt_long_outlined,
    ),
  ];

  static IconData fromKey(String? key) {
    if (key == null) return Icons.receipt_long_outlined;
    for (final entry in catalog) {
      if (entry.key == key) return entry.icon;
    }
    return Icons.receipt_long_outlined;
  }
}


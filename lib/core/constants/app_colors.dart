import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan modern Neo-Fintech renk paleti
/// ve sembolik abonelik kartları için seçilebilir renk havuzu.
class AppColors {
  AppColors._();

  // Ana Tema Renkleri (Koyu Mod Odaklı)
  static const Color background = Color(0xFF0F111A);
  static const Color surface = Color(0xFF1A1D2B);
  static const Color surfaceElevated = Color(0xFF24283B);
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF00D2B8);
  static const Color warning = Color(0xFFFFB74D);
  static const Color danger = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);

  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFF9EA4B8);

  /// Marka logoları yerine sembolik ikonlarla eşleştirilebilecek
  /// kullanıcı tarafından seçilebilir kart renkleri (ARGB Hex).
  static const List<int> selectableCardColors = [
    0xFFE53935, // Kırmızı (Sinema / Video)
    0xFF1DB954, // Yeşil (Müzik / Ses)
    0xFF6C63FF, // İndigo (Bulut / Yazılım)
    0xFF00ACC1, // Camgöbeği (İnternet / İletişim)
    0xFFFFB300, // Kehribar (Elektrik / Enerji)
    0xFF1E88E5, // Mavi (Su / Hizmetler)
    0xFFFF7043, // Turuncu (Doğalgaz / Isınma)
    0xFF8E24AA, // Mor (Oyun / Eğlence)
    0xFFEC407A, // Pembe (Spor / Sağlık)
    0xFF26A69A, // Turkuaz (Yapay Zeka / Üretkenlik)
    0xFF5C6BC0, // Lacivert (Eğitim / Kitap)
    0xFF78909C, // Gri-Mavi (Genel Fatura / Aidat)
  ];
}

/// Tüm Flutter sürümleriyle (3.19 - 3.29+) uyarı vermeden çalışan
/// güvenli opaklık yardımcı eklentisi.
extension ColorAlphaX on Color {
  Color withOpacityFactor(double factor) {
    final clamped = factor.clamp(0.0, 1.0);
    return withAlpha((clamped * 255).round());
  }
}


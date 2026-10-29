import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan göz yormayan "Kadife Okaliptüs" renk paleti
/// ve sembolik abonelik kartları için seçilebilir renk havuzu.
class AppColors {
  AppColors._();

  // Kadife Okaliptüs Ana Tema Renkleri (Yumuşak Kontrast & Göz Dinlendirici)
  static const Color background = Color(0xFF1B252C);
  static const Color surface = Color(0xFF24313A);
  static const Color surfaceElevated = Color(0xFF2E3E49);

  static const Color primary = Color(0xFF4FD1C5); // Pastel Nane / Okaliptüs
  static const Color onPrimary = Color(0xFF132A2E); // Buton içi yüksek kontrast koyu çam
  static const Color secondary = Color(0xFFF6AD55); // Sıcak Kayısı Vurgu

  static const Color heroGradientStart = Color(0xFF2C7A7B);
  static const Color heroGradientEnd = Color(0xFF3182CE);

  static const Color warning = Color(0xFFF6AD55);
  static const Color danger = Color(0xFFEF6461);
  static const Color success = Color(0xFF68D391);

  static const Color textPrimary = Color(0xFFEDF2F7);
  static const Color textSecondary = Color(0xFFA0B1BF);

  /// Marka logoları yerine sembolik ikonlarla eşleştirilebilecek
  /// kullanıcı tarafından seçilebilir yumuşak kart renkleri (ARGB Hex).
  static const List<int> selectableCardColors = [
    0xFF4FD1C5, // Pastel Nane (Bulut / Yazılım)
    0xFF63B3ED, // Gökyüzü Mavisi (İnternet / Su)
    0xFFF6AD55, // Sıcak Kayısı (Elektrik / Enerji)
    0xFF68D391, // Adaçayı Yeşili (Müzik / Ses)
    0xFFFC8181, // Yumuşak Mercan (Sinema / Video)
    0xFFB794F4, // Yumuşak Lavanta (Oyun / Eğlence)
    0xFFF687B3, // Gül Kurusu (Spor / Sağlık)
    0xFF4DB6AC, // Deniz Yeşili (Yapay Zeka / Üretkenlik)
    0xFFFF8A65, // Şeftali Turuncu (Doğalgaz / Isınma)
    0xFF7F9CF5, // İris Mavisi (Eğitim / Kitap)
    0xFFECC94B, // Bal Sarısı (Alışveriş / Üyelik)
    0xFF90A4AE, // Sis Grisi (Genel Fatura / Aidat)
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

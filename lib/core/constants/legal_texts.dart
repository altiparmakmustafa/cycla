/// Uygulama içi Yasal Uyarı (Disclaimer) ve Mağaza Güvenliği metinleri.
class LegalTexts {
  LegalTexts._();

  static const String disclaimerTitle = 'Yasal Uyarı ve Marka Bildirimi';

  static const String trademarkDisclaimer =
      'Bu uygulamada kullanıcılar tarafından girilen veya tanımlayıcı şablon '
      'olarak sunulan tüm şirket, ürün ve hizmet adları yalnızca kişisel '
      'bütçe takibi amacıyla (6769 sayılı Sınai Mülkiyet Kanunu kapsamında '
      'dürüst tanımlayıcı kullanım çerçevesinde) yer almaktadır.\n\n'
      'Uygulama içerisinde hiçbir üçüncü taraf şirketin tescilli logosu veya '
      'ticari görseli barındırılmamaktadır; bunun yerine sembolik kategori '
      'ikonları ve kullanıcı tercihli renk/harf rozetleri kullanılmaktadır.\n\n'
      'Adı geçen markalar ilgili sahiplerinin mülkiyetindedir. Bu uygulamanın '
      'herhangi bir yayın platformu, telekomünikasyon operatörü veya fatura '
      'kurumu ile resmi bağı, ortaklığı veya sponsorluk ilişkisi bulunmamaktadır.';

  static const String storeSafeModeExplanation =
      'App Store ve Google Play mağaza ekran görüntüsü (screenshot) alırken '
      'üçüncü taraf marka isimlerinin görünmemesi için bu modu açabilirsiniz. '
      'Açıldığında marka adları otomatik olarak jenerik hizmet isimlerine '
      '("Film & Dizi Platformu", "Müzik Akış Servisi" vb.) dönüştürülür.';

  /// Marka adlarını mağaza incelemesine (App Store / Google Play) uygun
  /// jenerik isimlere dönüştüren yardımcı eşleştirici.
  static String toStoreSafeName(String rawName, String categoryLabel) {
    final lower = rawName.toLowerCase().trim();
    if (lower.contains('netflix') ||
        lower.contains('disney') ||
        lower.contains('exxen') ||
        lower.contains('blutv') ||
        lower.contains('mubi') ||
        lower.contains('prime')) {
      return 'Film & Dizi Platformu';
    }
    if (lower.contains('spotify') ||
        lower.contains('apple music') ||
        lower.contains('deezer') ||
        lower.contains('fizy')) {
      return 'Müzik Akış Servisi';
    }
    if (lower.contains('youtube')) {
      return 'Video Üyelik Paketi';
    }
    if (lower.contains('icloud') ||
        lower.contains('google one') ||
        lower.contains('dropbox') ||
        lower.contains('onedrive')) {
      return 'Bulut Depolama Paketi';
    }
    if (lower.contains('chatgpt') ||
        lower.contains('claude') ||
        lower.contains('midjourney') ||
        lower.contains('copilot') ||
        lower.contains('gemini')) {
      return 'Yapay Zeka Asistanı';
    }
    if (lower.contains('turkcell') ||
        lower.contains('vodafone') ||
        lower.contains('türk telekom') ||
        lower.contains('turk telekom') ||
        lower.contains('superonline') ||
        lower.contains('turknet')) {
      return 'İnternet & İletişim Paketi';
    }
    if (lower.contains('xbox') ||
        lower.contains('playstation') ||
        lower.contains('ps plus') ||
        lower.contains('game pass') ||
        lower.contains('steam')) {
      return 'Oyun Üyelik Paketi';
    }
    return rawName;
  }
}


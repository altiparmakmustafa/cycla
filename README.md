# Cycla — Fatura & Abonelik Takipçisi (Flutter)

Tüm aboneliklerinizi ve faturalarınızı çevrimdışı öncelikli (offline-first) mimariyle tek bir yerde toplayan, ödeme yaklaşınca yerel bildirim gönderen ve aylık/yıllık harcama analizini gösteren Flutter uygulaması.

## Hukuki ve Mağaza Uyumluluk Tasarımı

Uygulama geliştirilirken marka ve telif hukuku ilkeleri doğrudan kod mimarisine entegre edilmiştir:

1. **Sıfır Tescilli Logo:** Uygulama paketinde hiçbir üçüncü taraf şirketin tescilli logosu (SVG/PNG) bulunmaz. Bunun yerine `SymbolicIcons` (`lib/core/constants/symbolic_icons.dart`) üzerinden kategori bazlı sembolik Material ikonları, renk paleti ve kullanıcı tanımlı harf/emoji rozetleri kullanılır.
2. **Dürüst Tanımlayıcı Kullanım (Nominative Fair Use):** İsimler yalnızca kullanıcının kendi bütçe kalemini tanımlaması amacıyla yerel cihaz hafızasında metin olarak saklanır.
3. **Yasal Uyarı & Marka Feragatnamesi:** Ayarlar ekranında açık bir yasal bildirim metni (`LegalTexts`) yer alır.

## Öne Çıkan Özellikler

- **Aylık & Yıllık Normalize Maliyet Hesabı:** Haftalık, aylık, 3 aylık ve yıllık abonelikleri aylık sabit gidere normalize eder.
- **Çoklu Para Birimi (TRY, USD, EUR):** Döviz bazlı abonelikleri çevrimdışı kur ayarlarıyla anlık olarak TL'ye çevirir.
- **Deneme Sürümü Savar (Free Trial Buster):** Ücretsiz denemelerin bitimine 5 gün kala ana ekranda uyarı gösterir ve çekimden 24 saat önce ekstra yerel bildirim planlar.
- **Ortak Abonelik Bölüşümü:** Aile planı veya ev arkadaşlarıyla paylaşılan faturalarda kişi başı payı hesaplar ve tek dokunuşla WhatsApp/mesajlaşma paylaşım metnini panoya kopyalar.
- **İnteraktif Takvim & Pasta Grafik Analizi:** `table_calendar` ile gelecek aylardaki ödeme günlerini ve `fl_chart` ile kategori dağılımını görselleştirir.

## Kurulum ve Çalıştırma

```bash
git clone https://github.com/altiparmakmustafa/cycla.git
cd cycla

# Paketleri indirir
flutter pub get

# Testleri çalıştırır
flutter test

# Uygulamayı başlatır (Chrome, iOS Simülatör, Android Emülatör veya macOS)
flutter run -d chrome
```

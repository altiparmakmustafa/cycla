<p align="center">
  <img src="assets/images/cycla_logo.png" width="120" alt="Cycla Logo" />
</p>

<h1 align="center">Cycla — Fatura & Abonelik Takipçisi</h1>

<p align="center">
  Tüm aboneliklerinizi ve faturalarınızı çevrimdışı öncelikli (offline-first) mimariyle tek bir yerde toplayan, canlı döviz kurlarıyla TL karşılıklarını hesaplayan, ödeme yaklaşınca yerel bildirim gönderen ve aylık/yıllık harcama analizini gösteren çoklu platform Flutter uygulaması.
</p>

---

## Öne Çıkan Özellikler

- **Tam Otomatik Canlı Döviz Kurları (`USD` & `EUR`):** API anahtarı veya ücretli abonelik gerektirmeyen 4 kademeli yedekli kur motoru (`ExchangeRateService` — Coinbase Spot, Frankfurter ECB ve Open ER-API) ile seçilen sıklıkta (**10 sn / 15 sn / 30 sn**) kurları otomatik günceller; çevrimdışı durumda son kaydedilen veya manuel girilen kurla kesintisiz çalışmaya devam eder.
- **Aylık & Yıllık Normalize Maliyet Hesabı:** Haftalık, aylık, 3 aylık ve yıllık abonelikleri tek bir aylık sabit gider ve yıllık toplam projeksiyon altında normalize eder.
- **Sunucusuz Yerel Bildirimler (`NotificationService`):** iOS, Android ve macOS üzerinde hiçbir dış sunucuya veri göndermeden cihaz içi zamanlanmış ödeme hatırlatmaları kurar (Android 13+ izin akışı, telefon yeniden başlatma sonrası alarm koruma ve iOS ön plan banner bildirimleri dahildir).
- **Deneme Sürümü Savar (Free Trial Koruması):** Ücretsiz deneme sürelerinin bitimine 5 gün kala ana ekranda uyarı gösterir ve ilk para çekiminden **24 saat önce** yüksek öncelikli ekstra iptal bildirimi gönderir.
- **Ortak Abonelik & Fatura Bölüşümü:** Aile planı veya ev arkadaşlarıyla paylaşılan faturalarda kişi başı düşen tutarı hesaplar; tek dokunuşla WhatsApp/mesajlaşma paylaşım metnini panoya kopyalar.
- **İnteraktif Takvim & Harcama Analizi:** `table_calendar` ile ödeme günlerini takvim üzerinde işaretler, `fl_chart` pasta grafiği ile kategori bazlı harcama yüzdelerini görselleştirir.
- **%100 Gizlilik & Sıfır Sunucu Maliyeti:** Tüm veriler yalnızca kullanıcının kendi cihazında (`SharedPreferences`) saklanır; hesap açma zorunluluğu veya bulut veri paylaşımı yoktur.

---

## Hukuki ve Mağaza Uyumluluk Tasarımı

Uygulama geliştirilirken marka ve telif hukuku ilkeleri doğrudan kod mimarisine entegre edilmiştir:

1. **Sıfır Üçüncü Taraf Tescilli Logo:** Uygulama paketinde hiçbir üçüncü taraf şirketin tescilli logosu (SVG/PNG) bulunmaz. Bunun yerine `SymbolicIcons` (`lib/core/constants/symbolic_icons.dart`) üzerinden kategori bazlı sembolik Material ikonları, renk paleti ve kullanıcı tanımlı harf/emoji rozetleri kullanılır.
2. **Dürüst Tanımlayıcı Kullanım (Nominative Fair Use):** Hizmet veya fatura adları yalnızca kullanıcının kendi bütçe kalemini tanımlaması amacıyla yerel cihaz hafızasında metin olarak tutulur.
3. **Yasal Uyarı & Marka Feragatnamesi:** Ayarlar ekranında açık bir yasal bildirim ve marka feragatnamesi (`LegalTexts`) yer alır.

---

## Desteklenen Platformlar

| Platform | Durum | Notlar |
| :--- | :--- | :--- |
| **iOS (iPhone / iPad)** | Hazır | Yerel bildirimler, ön plan banner uyarısı ve uygulama ikonları tanımlı |
| **Android** | Hazır | Android 13+ bildirim izni, `BOOT_COMPLETED` alıcıları ve Core Library Desugaring tanımlı |
| **Web (Chrome vb.)** | Hazır | CORS uyumlu otomatik canlı kur motoru ile tarayıcıda doğrudan çalışır |
| **macOS** | Hazır | Ağ istemci yetkileri (`entitlements`), yerel bildirimler ve masaüstü ikonları tanımlı |

---

## Kurulum ve Çalıştırma

```bash
git clone https://github.com/altiparmakmustafa/cycla.git
cd cycla

# Bağımlılıkları yükler
flutter pub get

# Statik kod analizini ve testleri çalıştırır
dart analyze
flutter test
```

### Farklı Platformlarda Başlatma

```bash
# Web (Chrome) üzerinde çalıştırma
flutter run -d chrome

# iOS Simülatör (Mac + Xcode) üzerinde çalıştırma
flutter emulators --launch apple_ios_simulator
flutter run

# macOS masaüstü uygulaması olarak çalıştırma
flutter run -d macos

# Android kurulum paketi (.apk) üretme (Android SDK kuruluysa)
flutter build apk --release
```

---

## Teknoloji Yığını

- **Framework & Dil:** Flutter & Dart
- **Durum Yönetimi (State Management):** `flutter_riverpod`
- **Yerel Veri Saklama:** `shared_preferences`
- **Canlı Döviz Kuru İstemcisi:** `http` + arka plan `Isolate` (`compute`) ayrıştırma
- **Yerel Bildirimler & Zaman Dilimi:** `flutter_local_notifications` + `timezone` (`Europe/Istanbul`)
- **Takvim & Grafikler:** `table_calendar`, `fl_chart`, `intl`

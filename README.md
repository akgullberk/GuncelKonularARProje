Berk AKGÜL 220541027
# 🌊 AR Balık: Artırılmış Gerçeklik Ansiklopedisi & Av Oyunu

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10.7-02569B?logo=flutter&logoColor=white&style=for-the-badge" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white&style=for-the-badge" alt="Dart Version" />
  <img src="https://img.shields.io/badge/State--Management-BLoC-02569B?style=for-the-badge" alt="State Management" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge" alt="Platforms" />
</p>

**AR Balık**, deniz yaşamını eğlenceli ve etkileşimli bir şekilde öğrenmeyi sağlayan, kamera ve görüntü tabanlı Artırılmış Gerçeklik (AR) teknolojisine sahip modern bir Flutter mobil uygulamasıdır. Kullanıcılar çektikleri zemin fotoğrafları üzerinde 3D animasyonlu balıkları inceleyebilir, keşifler yapabilir ve süreli balık avı görevleriyle kendilerini test edebilirler.

---

## ✨ Özellikler

*   **📸 Görüntü Tabanlı Artırılmış Gerçeklik (AR):** Kamera donanımını kullanarak ortamın fotoğrafını çeker ve bu görüntüyü dinamik bir akvaryum arka planı haline getirerek 3D balıkları ekranda yüzdürür.
*   **🐠 Etkileşimli 3D Model İnceleme:** Balıklara dokunulduğunda açılan detaylı bilgi ekranında, balığın Türkçe adı, Latince bilimsel adı ve açıklaması gösterilir. Üst kısımdaki 3D model parmak hareketleriyle döndürülüp yakından incelenebilir.
*   **⏱️ Balık Bul Oyunu (Timed Hunt):** Kullanıcıya rastgele verilen hedefleri (örn: *2 Betta, 1 Palyaço Balığı*) süre bitmeden ekranda bulup dokunmaya dayalı heyecanlı bir oyun modu.
*   **🏆 Keşif ve İlerleme Takibi (Discovery):** Keşif modunda yeni balık türlerini inceledikçe keşif sayacı güncellenir ve kullanıcının ilerlemesi cihazın yerel hafızasında saklanır.
*   **🔌 Çevrimdışı Çalışma Desteği:** 3D GLB modelleri yerel olarak uygulamanın içinde barındırıldığı için internet bağlantısı olmadan da tüm özellikler sorunsuz çalışır.

---

## 🛠️ Teknoloji Yığını & Mimari

Uygulama, profesyonel yazılım geliştirme standartlarına uygun olarak tasarlanmıştır:

*   **Mimari Yapı:** Feature-Driven Clean Architecture (Sunum, İş Mantığı, Domain ve Veri Katmanlarının Net Ayrımı).
*   **Durum Yönetimi (State Management):** Deterministik durum geçişleri ve kararlılık için `flutter_bloc` (BLoC Pattern).
*   **Bağımlılık Enjeksiyonu (Dependency Injection):** Servislerin gevşek bağlı yönetimi için `get_it`.
*   **3D Görselleştirme:** Google'ın `<model-viewer>` altyapısını kullanan `model_viewer_plus`.
*   **Yerel Depolama:** Keşif verilerini kaydetmek için `shared_preferences`.
*   **Donanım Erişimi:** Kamera yönetimi için `camera` kütüphanesi.

---

## 📁 Proje Dosya Yapısı

```text
lib/
├── app/                  # Uygulama başlangıç ve tema yapılandırması
├── core/
│   ├── di/               # get_it bağımlılık enjeksiyonu (injection.dart)
│   └── theme/            # Uygulama renk paleti ve yazı tipleri
└── features/
    ├── ar_aquarium/      # AR Akvaryum ve Oyun özellikleri
    │   ├── data/         # Veri kaynakları ve repository impl
    │   ├── domain/       # Use-case'ler ve entities
    │   └── presentation/ # BLoC Cubit'leri ve UI sayfaları (home, camera, aquarium)
    └── fish_catalog/     # Balık Kataloğu özelliği (modeller ve görünümler)
```

---

## 📄 Mühendislik ve Analiz Dokümanları (`/docs`)

Proje kapsamında hazırlanan ve sistem mühendisliği standartlarını içeren raporlara aşağıdaki bağlantılardan erişebilirsiniz:

1.  **[SWOT Analizi Raporu](file:///c:/Users/berka/G-ncel-Konular-Proje/docs/SWOT.pdf) (SWOT.pdf):** Projenin içsel güçlü/zayıf yönleri ile dışsal fırsat/tehdit analizleri ve stratejik SWOT matrisi.
2.  **[RAMS Raporu](file:///c:/Users/berka/G-ncel-Konular-Proje/docs/RAMS.pdf) (RAMS.pdf):** Sistemin Güvenilirlik (Reliability), Erişilebilirlik (Availability), Bakım Yapılabilirlik (Maintainability) ve Emniyet/Güvenlik (Safety) analizi.
3.  **[Teknoloji Hazırlık Seviyesi Raporu](file:///c:/Users/berka/G-ncel-Konular-Proje/docs/THS_report.pdf) (THS_report.pdf):** Projenin mevcut THS 4 (Laboratuvarda Doğrulama) durum gerekçeleri ve THS 9'a ulaşma yol haritası.
4.  **[Sistem Gereksinimleri Dokümanı](file:///c:/Users/berka/G-ncel-Konular-Proje/docs/Requirements.pdf) (Requirements.pdf):** Detaylı fonksiyonel (FR) ve fonksiyonel olmayan (NFR) gereksinimler listesi.
5.  **[Kullanıcı Senaryoları Raporu](file:///c:/Users/berka/G-ncel-Konular-Proje/docs/UserScenario.pdf) (UserScenario.pdf):** Explore ve Timed Hunt modları için uçtan uca hazırlanan kullanıcı deneyimi (UX) senaryoları.

---

## 🚀 Başlangıç

### Gereksinimler

*   Flutter SDK (v3.10.7 veya üzeri)
*   Dart SDK
*   Android Studio / VS Code
*   Kamera donanımına sahip fiziksel bir cihaz (veya kamera emülasyonu açık emülatör)

### Kurulum ve Çalıştırma

1.  Projeyi klonlayın veya proje dizinine gidin:
    ```bash
    cd ar_balik_projesi
    ```

2.  Bağımlılıkları yükleyin:
    ```bash
    flutter pub get
    ```

3.  Uygulamayı çalıştırın:
    ```bash
    flutter run
    ```

---

## 👤 Geliştirici

Bu proje, Deniz Yaşamı Farkındalığı ve Artırılmış Gerçeklik Teknolojilerinin Eğitimde Kullanımı amacıyla geliştirilmiştir.

# 🧠 Subscription Tracker - Production Plan v2

## 1. 🎯 Ürün Vizyonu
Kullanıcıların aboneliklerini offline-first, gizlilik odaklı ve finansal farkındalık sağlayacak şekilde yönetmesini sağlamak.

---

## 2. 🚀 Özellikler

### Abonelik Yönetimi
- Şablondan ekleme
- Manuel ekleme
- Çoklu abonelik (label destekli)

### Faturalama Sistemi
- Monthly / Yearly / Weekly
- Trial yönetimi
- Otomatik ödeme hesaplama

### Bildirimler
- Ödeme öncesi uyarı
- Trial bitiş uyarısı
- Retry & reschedule

### Finansal Analiz
- Aylık & yıllık toplam
- Kategori bazlı analiz
- Gereksiz abonelik uyarısı

### Çoklu Para Birimi
- Kur desteği
- Manuel / API rate

### Veri Güvenilirliği
- Source URL
- Verified flag
- Last checked

### Yedekleme
- JSON export/import
- Opsiyonel cloud backup

---

## 3. 🏗️ Teknik Mimari

### Stack
- **Flutter**: 3.16+ (stable)
- **State Management**: Riverpod (v2.x) - Clean Architecture + MVVM
- **Database**: Sqflite + SQLCipher (encrypted)
- **HTTP**: Dio (retry, interceptor support)
- **Notifications**: flutter_local_notifications
- **Background**: Workmanager (periodic sync)
- **Dependency Injection**: Riverpod

### Mimari Pattern
```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
└── main.dart
```

### Error Handling
- Result<T, E> pattern (Either)
- Global error handler
- User-friendly error messages
- Retry mechanism (exponential backoff)

---

## 4. 🧩 Veri Modeli

### Subscriptions
- id
- name
- category
- price
- currency
- billing_cycle
- next_payment_date
- notification_enabled (bool)
- notification_days_before (int)
- timezone
- created_at
- updated_at

### Payment History
- id
- subscription_id
- amount
- currency
- paid_at
- notes

### Notification Settings
- id
- subscription_id
- payment_reminder (bool)
- trial_expiry_reminder (bool)
- price_change_alert (bool)
- days_before_payment (int) - default: 3

### User Preferences
- default_currency
- default_timezone
- theme (light/dark/system)
- language
- biometric_lock (bool)

### Service Templates
- id
- name
- default_price
- source_url
- verified

---

## 5. 🔄 Veri Akışı
1. App açılır
2. Local DB yüklenir
3. Remote JSON sync yapılır

---

## 6. 📱 UX

### Ekranlar
- Onboarding (ilk açılış)
  - Hoşgeldin + değer önerisi
  - Bildirim izni isteği
  - İlk abonelik ekleme (şablondan veya manuel)
  - Premium tanıtım (opsiyonel skip)
- Dashboard
- Analiz
- Ekle
- Ayarlar

### UX Detayları
- Search & Filter (abonelik listesinde)
- Pull-to-refresh (manuel sync)
- Swipe actions (düzenle/sil)
- Empty states (ilk kullanım için rehber)
- Accessibility labels (VoiceOver/TalkBack)

---

## 7. ⚠️ Edge Cases
- Fiyat değişimi → lock
- Duplicate → label
- Offline → cache
- Timezone değişimi → next_payment_date recalculate
- Offline currency conversion → last known rate veya manual override
- Yılsonu geçişi (31 Aralık → 1 Ocak) → yıllık toplam reset
- Data migration → version-based migration scripts
- Notification permission denied → graceful fallback + re-prompt strategy

---

## 8. 📈 Fazlar

### Faz 1: Core Foundation
- Veri modeli implementasyonu
- Local DB kurulumu (Sqflite + SQLCipher)
- CRUD operasyonları
- Riverpod provider'ları
- Basit dashboard

### Faz 2: UI/UX
- Tasarım sistemi (colors, typography, components)
- Tüm ekranlar implementasyonu
- Navigation yapısı
- Onboarding flow
- Empty states & error states

### Faz 3: Notifications
- Local notification setup
- Payment reminder scheduling
- Trial expiry alerts
- Notification preferences

### Faz 4: Sync & Currency
- JSON service templates (remote)
- Currency API integration
- Background sync (Workmanager)
- Offline-first data flow

### Faz 5: Advanced Features
- Widget (Home screen)
- Analytics integration
- Biometric lock
- Backup/restore (JSON)

---

## 9. 💰 Monetization
- Free: 15 abonelik
- Premium: sınırsız + analiz + backup + widget
- Premium fiyatı: $4.99/ay veya $39.99/yıl
- 7 günlük premium trial

---

## 10. 🏆 Başarı Faktörleri
- Offline-first
- Basit UX
- Doğru hesaplama
- Güvenilir veri

---

## 11. 🔒 Güvenlik
- Local DB encryption (SQLCipher)
- Biometric lock option (Face ID / Touch ID / Fingerprint)
- Secure backup encryption (AES-256)
- No cloud dependency (privacy first)

---

## 12. 🧪 Test Stratejisi
- **Unit tests**: Riverpod providers, hesaplama fonksiyonları
- **Widget tests**: Kritik UI flow'lar (ekleme, düzenleme, silme)
- **Integration tests**: Tam kullanıcı senaryoları
- **Manual QA**: Edge case'ler, timezone değişimi, offline senaryoları

---

## 13. 📅 Zaman Çizelgesi
| Faz | Süre | İçerik |
|-----|------|--------|
| Faz 1: Core | 2 hafta | Veri modeli, CRUD, local DB |
| Faz 2: UI | 2 hafta | Tasarım, ekranlar, navigation |
| Faz 3: Notifications | 1 hafta | Local notifications, scheduling |
| Faz 4: Sync | 1 hafta | JSON sync, currency API |
| Faz 5: Advanced | 2 hafta | Widget, analytics, polish |
| **Toplam** | **8 hafta** | MVP + extras |

---

## 14. 📊 Analytics (Anonymized)
- Crashlytics (crash reporting)
- Abonelik ekleme funnel'i
- Premium conversion rate
- En çok kullanılan şablonlar
- Ortalama abonelik sayısı (free vs premium)
- Kullanıcı retention (D1, D7, D30)

---

## 15. 📦 Widget & Extensions
- Home screen widget (Android/iOS)
  - Yaklaşan ödemeler
  - Aylık toplam
- Quick actions (3D Touch / Long press)
- Share extension (URL'den abonelik ekleme)

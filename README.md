CLAUDE BUAT NI.
ADA ZIP KUTARUH TU

# AA-PoDiTa — Setup & Panduan Pengembang

**Posyandu Digital Terpadu Bayi Balita**
> *Aman Datanya, Aman Anaknya*

---

## Struktur File (Auth Module)

```
lib/
├── main.dart                          ← Entry point
├── utils/
│   ├── app_theme.dart                 ← Warna, tema, gradient
│   └── app_constants.dart             ← Konstanta app & Firestore
├── services/
│   └── auth_service.dart              ← Register & Login (Firebase placeholder)
├── widgets/
│   ├── custom_text_field.dart         ← Input field reusable
│   └── gradient_button.dart           ← Tombol gradient animasi
└── screens/
    └── auth/
        ├── landing_screen.dart        ← Halaman awal (2 tombol masuk)
        ├── login_kepala_screen.dart   ← Login Kepala Puskesmas
        ├── login_kader_screen.dart    ← Login Kader Posyandu
        ├── daftar_kepala_screen.dart  ← Daftar akun Kepala
        └── daftar_kader_screen.dart   ← Daftar akun Kader
```

---

## Alur Penggunaan

```
Landing → [Masuk sebagai Kepala] → LoginKepala → [Daftar] → DaftarKepala
       ↘ [Masuk sebagai Kader]  → LoginKader  → [Daftar] → DaftarKader
```

**Alur Daftar:**
1. Developer/operator input username ke Firestore collection `username_pool` (sebagai string/dokumen)
2. User buka halaman Daftar, masukkan username tersebut
3. User isi: Nama Lengkap, Password, Konfirmasi Password, NIK, Nomor HP
4. Sistem verifikasi username ada di pool → buat akun Firebase Auth → simpan data ke Firestore
5. User bisa login dengan username + password

**Catatan:** User yang hanya punya username dari developer **belum bisa login** karena akun Firebase Auth belum dibuat. Akun terbentuk saat user mengisi form Daftar.

---

## Setup Firebase

### 1. Buat project Firebase
- Buka [Firebase Console](https://console.firebase.google.com/)
- Buat project baru

### 2. Tambahkan Android App
- Package name: `com.yourcompany.aa_podita` (sesuaikan di `android/app/build.gradle`)
- Download `google-services.json` → taruh di `android/app/`

### 3. Enable Firebase Services
- **Authentication** → Sign-in method → Email/Password → Enable
- **Firestore Database** → Create database (mode production/test)

### 4. Struktur Firestore yang Dibutuhkan

```
username_pool/          ← Collection (developer isi manual)
  └── {username}        ← Document ID = username yang diberikan ke user
      └── role: "kader" | "kepala"
      └── createdAt: timestamp

kader/                  ← Collection akun kader
  └── {uid}
      ├── username: string
      ├── namaLengkap: string
      ├── nik: string
      ├── nomorHp: string
      ├── role: "kader"
      └── createdAt: timestamp

kepala_puskesmas/       ← Collection akun kepala
  └── {uid}
      ├── username: string
      ├── namaLengkap: string
      ├── nik: string
      ├── nomorHp: string
      ├── role: "kepala"
      └── createdAt: timestamp
```

### 5. Aktifkan Firebase di kode

Di `main.dart`, uncomment:
```dart
import 'package:firebase_core/firebase_core.dart';
// ...
await Firebase.initializeApp();
```

Di `auth_service.dart`, uncomment semua blok `// TODO: Uncomment...`

---

## Logo

Taruh file `logo.png` di `assets/images/logo.png`

Di `landing_screen.dart`, ganti widget `_LogoPlaceholder()` dengan:
```dart
child: Image.asset(
  'assets/images/logo.png',
  fit: BoxFit.contain,
),
```

---

## Dependencies

```yaml
firebase_core: ^2.24.2
firebase_auth: ^4.15.3
cloud_firestore: ^4.13.6
google_fonts: ^6.1.0
flutter_svg: ^2.0.9
shared_preferences: ^2.2.2
intl: ^0.18.1
```

Jalankan: `flutter pub get`

---

## Warna Utama

| Elemen | Warna |
|--------|-------|
| Pink (Kader) | `#FF6B9D` |
| Biru (Kepala) | `#0288D1` |
| Background | `#F8FAFB` |
| Teks Utama | `#1A1A2E` |

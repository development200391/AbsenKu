# AbsenKu

Aplikasi mobile (Flutter) untuk absensi karyawan berbasis lokasi (GPS), terhubung langsung ke backend **SINARA ERP** (`ERP.API`, modul HR). Karyawan login pakai akun ERP yang sama, lalu bisa check-in/check-out dan mengajukan izin dari HP tanpa perlu buka aplikasi web ERP.

## Alur Aplikasi & Menu

### 1. Login
- Layar pertama yang muncul kalau belum ada sesi aktif.
- Pakai **username & password akun ERP** yang sudah ada (tidak ada akun terpisah khusus mobile).
- Setelah login, access token & refresh token disimpan aman di HP (`flutter_secure_storage`). Refresh token dipakai otomatis untuk memperpanjang sesi kalau access token kedaluwarsa (interceptor di `lib/core/api_client.dart`), jadi karyawan tidak perlu login ulang tiap hari.
- Endpoint: `POST /api/v1/auth/login`, `POST /api/v1/auth/refresh-token`.

**Login biometrik (app-lock)** — kalau sudah pernah login sebelumnya (ada sesi tersimpan di HP) dan perangkat punya sidik jari/Face ID terdaftar, layar login tidak langsung menampilkan form password. Yang muncul duluan adalah gerbang verifikasi biometrik ("Buka dengan Sidik Jari / Face ID"). Berhasil verifikasi → langsung masuk Beranda tanpa ketik ulang password. Kalau device tidak punya biometrik, atau user memilih "Login dengan Password", form password tetap tersedia sebagai jalur normal/cadangan. Ini murni gerbang keamanan tambahan di atas sesi yang sudah ada — **tidak** menyimpan password di HP, jadi tidak menggantikan proses login awal.
- Implementasi: `lib/core/biometric_auth_service.dart` (wrapper paket `local_auth`), `lib/core/auth_session.dart` (`hasStoredSession` vs `isAuthenticated`), `lib/features/auth/login_screen.dart`.

### 2. Beranda (Home) — Check-in / Check-out
Layar utama setelah login. Menampilkan:
- Tanggal hari ini, dan **jam berjalan real-time** yang disinkronkan ke waktu server (bukan jam HP) — supaya karyawan melihat jam yang sama persis dengan yang nantinya dicatat saat check-in/out, walau jam HP-nya salah/diubah.
- Jam check-in & check-out hari ini (kalau sudah dilakukan).
- Status kehadiran hari ini (default "Hadir", atau status yang diajukan lewat menu Izin).
- Peringatan kalau admin belum mengatur lokasi kantor.

**Tombol utama** berubah otomatis sesuai kondisi:
- Belum check-in → tombol **"Check In"**.
- Sudah check-in, belum check-out → tombol **"Check Out"**.
- Sudah check-out juga → tombol tetap aktif, berlabel **"Perbarui Check Out"**. Check-out **boleh ditekan berkali-kali**; setiap submit menimpa jam check-out sebelumnya dengan yang terbaru (dari waktu server). Ini disengaja — supaya karyawan yang salah pencet check-out kecepetan bisa merevisi ke jam yang benar tanpa perlu minta bantuan admin.

Saat tombol ditekan:
1. App minta izin lokasi (kalau belum diizinkan) dan mengambil koordinat GPS HP saat itu.
2. Koordinat dikirim ke server (`POST /api/v1/hr/attendance/self/check-in` atau `/check-out`).
3. **Server** (bukan app) yang menghitung jarak ke titik kantor (rumus Haversine) dan menolak (pesan error jarak dalam meter) kalau di luar radius yang diatur admin. Ini supaya karyawan tidak bisa mengakali validasi jarak dari sisi HP.
4. Jam check-in/check-out dicatat pakai waktu server, bukan jam HP — supaya tidak bisa dimanipulasi lewat ubah jam HP.

Status kehadiran (Hadir/Terlambat, dst) **tidak** dihitung otomatis dari jam check-in — itu keputusan desain: check-in/check-out normal hanya mencatat waktu & lokasi, tidak mengubah status.

**Jam server (server-time)** — jam yang tampil di Beranda diambil sekali lewat `GET /api/v1/diagnostics/server-time` saat layar dibuka, lalu app menghitung selisih (offset) ke jam HP dan menjalankan jam itu sendiri di client (tick tiap detik) tanpa perlu polling server terus-menerus. Kalau jam HP diubah user setelah offset dihitung, tampilan tetap akurat karena berbasis offset, bukan jam HP mentah.

### 3. Ajukan Izin / Sakit / Cuti / Setengah Hari
Diakses lewat tombol "Ajukan Izin..." di Beranda. Dipakai kalau karyawan **tidak** melakukan check-in/check-out normal hari itu, tapi perlu mencatatkan alasan:
- Pilih tanggal (default hari ini, bisa mundur/maju).
- Pilih jenis: **Setengah Hari, Sakit, Cuti,** atau **Absen**.
- Catatan opsional (alasan singkat).
- Kirim → langsung tersimpan sebagai status hari itu, **tanpa proses approval** (beda dengan modul Leave/Cuti di ERP Web yang butuh persetujuan HR — ini disengaja dibuat simpel untuk versi awal).
- Tidak bisa dipakai untuk tanggal yang sudah ada check-in/check-out di hari itu (dianggap konflik).
- Endpoint: `POST /api/v1/hr/attendance/self/mark`.

### 4. Riwayat Absensi (History)
Diakses lewat ikon jam di pojok kanan atas Beranda. Menampilkan daftar semua catatan absensi karyawan yang login: tanggal, jam check-in/out, dan status — untuk melihat rekap tanpa perlu buka ERP Web.
- Endpoint: `GET /api/v1/hr/attendance/self/history`.

### 5. Logout
Ikon logout di pojok kanan atas Beranda. Menghapus token yang tersimpan di HP dan memberitahu server untuk mencabut refresh token tersebut.

### 6. Bahasa (Language)
Ikon globe (🌐) di Beranda maupun layar Login membuka dialog pilih bahasa: **Ikuti Bahasa Sistem** (default, ikut setting HP), **Bahasa Indonesia**, **English**, atau **日本語**. Pilihan disimpan di HP secara terpisah dari sesi login — jadi **tidak ikut terhapus saat logout**, dan tetap kepakai walau app di-restart.
- Semua teks UI (label, tombol, pesan validasi, dll) diterjemahkan lewat `flutter_localizations` + file ARB (`lib/l10n/app_id.arb`, `app_en.arb`, `app_ja.arb`). Format tanggal (nama hari/bulan) ikut menyesuaikan bahasa yang aktif.
- **Yang tidak ikut diterjemahkan**: pesan error yang datang langsung dari API (field `message` di response gagal, mis. validasi jarak kantor atau error login) — itu ditampilkan apa adanya sesuai bahasa yang ditulis di backend, karena `ERP.API` sendiri belum punya mekanisme multi-bahasa untuk pesan error. Hanya pesan client-side (koneksi gagal, validasi form, dll) yang mengikuti pilihan bahasa di atas.
- Implementasi: `lib/core/locale_controller.dart`, `lib/core/language_picker.dart`.

## Konfigurasi Terkait (untuk Admin HR di ERP Web)
Sebelum karyawan bisa check-in, admin HR perlu mengisi **lokasi kantor & radius** di halaman *HR → Attendance → Attendance Setting* (ERP Web): latitude, longitude, dan radius (meter) toleransi jarak. Field ini baru ditambahkan bersamaan dengan fitur mobile ini.

## Arsitektur Singkat
```
lib/
  core/            # koneksi API (dio + auto-refresh token + correlation id), secure storage,
                   # sesi login, login biometrik, pilihan bahasa, tipe exception bersama, error reporting
  features/
    auth/          # login
    attendance/
      models/      # model data (AttendanceRecord, AttendanceSettings, status enum)
      data/        # pemanggilan API + helper lokasi GPS
      presentation/# layar Beranda, Ajukan Izin, Riwayat
  l10n/            # file ARB (id/en/ja) + AppLocalizations hasil generate (flutter gen-l10n)
```
File inti di `core/`: `api_client.dart`, `api_exception.dart` (tipe error bersama: `ConnectionException`/`ApiException`/`UnknownApiException`), `auth_session.dart`, `biometric_auth_service.dart`, `locale_controller.dart`, `language_picker.dart`, `secure_storage.dart`.

Backend: `D:\NET\SINARA\ERP.API` (ASP.NET Core 8 + PostgreSQL), khususnya `Controllers/v1/HR/SelfAttendanceController.cs`, `Services/HR/AttendanceService.cs`, dan `Controllers/v1/DiagnosticsController.cs` (endpoint `server-time`).

## Penanganan Error & Logging
Supaya error yang terjadi di HP karyawan tidak "hilang begitu saja" (tidak ada console yang bisa dilihat developer), ada mekanisme berikut:

**Correlation ID** — setiap request dari app ke API disertai header `X-Correlation-Id` (dibuat di `lib/core/correlation.dart`, dipasang otomatis lewat interceptor di `lib/core/api_client.dart`). Backend ikut mencatat ID ini, jadi satu request dari app bisa ditelusuri baris log-nya di server pakai ID yang sama.

**Error tak tertangani (crash)** — `lib/main.dart` mendaftarkan `FlutterError.onError` (error dari framework Flutter: build/layout/gesture) dan `PlatformDispatcher.instance.onError` (error async yang lolos dari try/catch manapun). Keduanya meneruskan error ke `lib/core/diagnostics_reporter.dart`, yang:
- Mengirim `POST /api/v1/diagnostics/client-log` (endpoint anonymous, tidak perlu login) berisi pesan error, stack trace, correlation ID baru untuk laporan ini, dan correlation ID request terakhir sebagai referensi.
- Fire-and-forget dan dibatasi cooldown 5 menit per jenis error, supaya kegagalan kirim log atau error yang berulang-ulang tidak menambah crash baru / membanjiri log.

**Sisi backend (`ERP.API`)** — semua request (termasuk `client-log` di atas) dicatat oleh `Middleware/RequestLoggingMiddleware.cs` ke file `logs/requests-{yyyy-MM-dd-HH}.txt`, kalau `RequestLogging:Enabled = true` di `appsettings.json` (aktif di development; production diaktifkan manual saat dibutuhkan). Endpoint `client-log` sendiri ada di `Controllers/v1/DiagnosticsController.cs` dan dibatasi rate limit 20 request/menit (`Program.cs`).

Ini murni logging untuk memudahkan debugging — pesan error yang sudah ditampilkan ke user di tiap layar (`_errorMessage`) tidak berubah.

## Menjalankan untuk Development
- Jalankan `flutter pub get` setelah clone/pull (ada dependency `local_auth` untuk biometrik dan `flutter_localizations` untuk bahasa; `generate: true` di `pubspec.yaml` otomatis men-generate `lib/l10n/app_localizations*.dart` dari file ARB — kalau perlu generate ulang manual setelah edit file ARB, jalankan `flutter gen-l10n`).
- Biometrik (`local_auth`) butuh Android `minSdk` 23+ (sudah diatur di `android/app/build.gradle.kts`) dan `MainActivity` bertipe `FlutterFragmentActivity` (sudah diatur) — kalau bikin activity Android custom baru, jangan sampai balik ke `FlutterActivity` biasa.
- Pastikan `ERP.API` sedang berjalan (default `http://127.0.0.1:60043`).
- **Emulator Android**: base URL di `lib/core/api_config.dart` perlu diarahkan ke `http://10.0.2.2:60043/api/v1`.
- **HP fisik via USB**: base URL tetap `127.0.0.1`, tapi jalankan 
`"C:\Users\kokos\AppData\Local\Android\Sdk\platform-tools\adb.exe" reverse tcp:60043 tcp:60043` dulu supaya HP bisa "menembus" ke API di laptop lewat kabel USB. Perlu diulang tiap kali HP dicabut-pasang atau adb/laptop restart.
- Akun ERP yang dipakai login harus terhubung ke data karyawan (`HrEmployee.UserId` terisi), kalau tidak endpoint absen akan menolak dengan pesan "No employee profile is linked to this account."

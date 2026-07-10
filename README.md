# AbsenKu

Aplikasi mobile (Flutter) untuk absensi karyawan berbasis lokasi (GPS), terhubung langsung ke backend **SINARA ERP** (`ERP.API`, modul HR). Karyawan login pakai akun ERP yang sama, lalu bisa check-in/check-out dan mengajukan izin dari HP tanpa perlu buka aplikasi web ERP.

## Alur Aplikasi & Menu

### 1. Login
- Layar pertama yang muncul kalau belum ada sesi aktif.
- Pakai **username & password akun ERP** yang sudah ada (tidak ada akun terpisah khusus mobile).
- Setelah login, access token & refresh token disimpan aman di HP (`flutter_secure_storage`). Refresh token dipakai otomatis untuk memperpanjang sesi kalau access token kedaluwarsa (interceptor di `lib/core/api_client.dart`), jadi karyawan tidak perlu login ulang tiap hari.
- Endpoint: `POST /api/v1/auth/login`, `POST /api/v1/auth/refresh-token`.

### 2. Beranda (Home) — Check-in / Check-out
Layar utama setelah login. Menampilkan:
- Tanggal hari ini.
- Jam check-in & check-out hari ini (kalau sudah dilakukan).
- Status kehadiran hari ini (default "Hadir", atau status yang diajukan lewat menu Izin).
- Peringatan kalau admin belum mengatur lokasi kantor.

**Tombol utama** berubah otomatis sesuai kondisi:
- Belum check-in → tombol **"Check In"**.
- Sudah check-in, belum check-out → tombol **"Check Out"**.
- Sudah keduanya → tombol nonaktif **"Selesai hari ini"**.

Saat tombol ditekan:
1. App minta izin lokasi (kalau belum diizinkan) dan mengambil koordinat GPS HP saat itu.
2. Koordinat dikirim ke server (`POST /api/v1/hr/attendance/self/check-in` atau `/check-out`).
3. **Server** (bukan app) yang menghitung jarak ke titik kantor (rumus Haversine) dan menolak (pesan error jarak dalam meter) kalau di luar radius yang diatur admin. Ini supaya karyawan tidak bisa mengakali validasi jarak dari sisi HP.
4. Jam check-in/check-out dicatat pakai waktu server, bukan jam HP — supaya tidak bisa dimanipulasi lewat ubah jam HP.

Status kehadiran (Hadir/Terlambat, dst) **tidak** dihitung otomatis dari jam check-in — itu keputusan desain: check-in/check-out normal hanya mencatat waktu & lokasi, tidak mengubah status.

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

## Konfigurasi Terkait (untuk Admin HR di ERP Web)
Sebelum karyawan bisa check-in, admin HR perlu mengisi **lokasi kantor & radius** di halaman *HR → Attendance → Attendance Setting* (ERP Web): latitude, longitude, dan radius (meter) toleransi jarak. Field ini baru ditambahkan bersamaan dengan fitur mobile ini.

## Arsitektur Singkat
```
lib/
  core/            # koneksi API (dio + auto-refresh token + correlation id), secure storage, sesi login, error reporting
  features/
    auth/          # login
    attendance/
      models/      # model data (AttendanceRecord, AttendanceSettings, status enum)
      data/        # pemanggilan API + helper lokasi GPS
      presentation/# layar Beranda, Ajukan Izin, Riwayat
```
Backend: `D:\NET\SINARA\ERP.API` (ASP.NET Core 8 + PostgreSQL), khususnya `Controllers/v1/HR/SelfAttendanceController.cs` dan `Services/HR/AttendanceService.cs`.

## Penanganan Error & Logging
Supaya error yang terjadi di HP karyawan tidak "hilang begitu saja" (tidak ada console yang bisa dilihat developer), ada mekanisme berikut:

**Correlation ID** — setiap request dari app ke API disertai header `X-Correlation-Id` (dibuat di `lib/core/correlation.dart`, dipasang otomatis lewat interceptor di `lib/core/api_client.dart`). Backend ikut mencatat ID ini, jadi satu request dari app bisa ditelusuri baris log-nya di server pakai ID yang sama.

**Error tak tertangani (crash)** — `lib/main.dart` mendaftarkan `FlutterError.onError` (error dari framework Flutter: build/layout/gesture) dan `PlatformDispatcher.instance.onError` (error async yang lolos dari try/catch manapun). Keduanya meneruskan error ke `lib/core/diagnostics_reporter.dart`, yang:
- Mengirim `POST /api/v1/diagnostics/client-log` (endpoint anonymous, tidak perlu login) berisi pesan error, stack trace, correlation ID baru untuk laporan ini, dan correlation ID request terakhir sebagai referensi.
- Fire-and-forget dan dibatasi cooldown 5 menit per jenis error, supaya kegagalan kirim log atau error yang berulang-ulang tidak menambah crash baru / membanjiri log.

**Sisi backend (`ERP.API`)** — semua request (termasuk `client-log` di atas) dicatat oleh `Middleware/RequestLoggingMiddleware.cs` ke file `logs/requests-{yyyy-MM-dd-HH}.txt`, kalau `RequestLogging:Enabled = true` di `appsettings.json` (aktif di development; production diaktifkan manual saat dibutuhkan). Endpoint `client-log` sendiri ada di `Controllers/v1/DiagnosticsController.cs` dan dibatasi rate limit 20 request/menit (`Program.cs`).

Ini murni logging untuk memudahkan debugging — pesan error yang sudah ditampilkan ke user di tiap layar (`_errorMessage`) tidak berubah.

## Menjalankan untuk Development
- Pastikan `ERP.API` sedang berjalan (default `http://127.0.0.1:60043`).
- **Emulator Android**: base URL di `lib/core/api_config.dart` perlu diarahkan ke `http://10.0.2.2:60043/api/v1`.
- **HP fisik via USB**: base URL tetap `127.0.0.1`, tapi jalankan 
`"C:\Users\kokos\AppData\Local\Android\Sdk\platform-tools\adb.exe" reverse tcp:60043 tcp:60043` dulu supaya HP bisa "menembus" ke API di laptop lewat kabel USB. Perlu diulang tiap kali HP dicabut-pasang atau adb/laptop restart.
- Akun ERP yang dipakai login harus terhubung ke data karyawan (`HrEmployee.UserId` terisi), kalau tidak endpoint absen akan menolak dengan pesan "No employee profile is linked to this account."
 API reference.

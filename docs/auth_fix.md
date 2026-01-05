# Perbaikan Masalah Logout Otomatis

## Masalah
Aplikasi mengalami logout otomatis saat token expired atau tidak valid, yang menyebabkan pengalaman pengguna yang buruk.

## Penyebab
- Banyak file memanggil `_forceLogout()` atau `_logout()` saat mendapatkan status 401 dari API
- Tidak ada penanganan token expired yang konsisten di seluruh aplikasi
- Setiap API request menangani authentikasi secara terpisah

## Solusi
1. Membuat `AuthService` untuk mengelola logout secara konsisten
2. Membuat `ApiClient` sebagai wrapper untuk HTTP requests dengan penanganan auth otomatis
3. Memperbarui semua file untuk menggunakan `ApiClient` daripada HTTP client langsung
4. Mengganti semua panggilan `_forceLogout()` dengan panggilan ke `AuthService.instance.logout(context)`

## File yang Diubah
- `lib/core/services/auth_service.dart` - Baru, untuk manajemen logout
- `lib/core/services/api_client.dart` - Baru, untuk wrapper HTTP requests
- `lib/features/home/screens/home_tab.dart` - Menggunakan ApiClient
- `lib/features/log_bimbingan/screens/bimbingan_log.dart` - Menggunakan ApiClient
- `lib/features/log_bimbingan/screens/add_log_screen.dart` - Menggunakan ApiClient
- `lib/features/profile/screens/profile_tab.dart` - Menggunakan ApiClient
- `lib/core/services/api_service.dart` - Menggunakan ApiClient
- Beberapa file lain yang memanggil logout

## Manfaat
- Penanganan authentikasi yang konsisten di seluruh aplikasi
- Tidak ada logout otomatis yang tidak diinginkan
- Kode lebih terorganisir dan mudah dipelihara
- Pengalaman pengguna yang lebih baik

## Catatan
- Jika server mengembalikan status 401, ApiClient akan secara otomatis logout pengguna
- Logout hanya terjadi saat benar-benar tidak ada token atau token tidak valid
- Semua API request sekarang menggunakan pendekatan yang seragam
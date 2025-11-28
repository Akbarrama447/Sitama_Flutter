# TODO: Buat Screen Daftar Tugas Akhir

## Langkah-langkah:
1. [x] Buat file baru: lib/features/tugas_akhir/screens/daftar_tugas_akhir_screen.dart
   - [x] Implementasi StatefulWidget dengan Form
   - [x] TextFormField untuk judul tugas akhir (wajib)
   - [x] TextFormField untuk anggota kelompok (masukkan nama dipisah koma, wajib)
   - [x] Tombol submit yang validasi dan post ke API /api/tugas-akhir
   - [x] Handle loading, success/error message, logout jika 401

2. [x] Edit lib/features/home/screens/home_tab.dart
   - [x] Di _showTugasAkhirMenu, ganti TODO untuk "Daftar Tugas Akhir" dengan Navigator.push ke screen baru

3. Test: Jalankan app dan navigasi ke screen baru

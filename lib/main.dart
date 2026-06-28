// ============================================================
// FILE: lib/main.dart
// Deskripsi: Entry point utama aplikasi PanganTech
//            Setup: Provider, Theme, Route awal (Login)
// Nama Proyek  : UAS_[Kelas]_[Nama] - PanganTech
// Dosen Pengampu: Samso Supriyatna, S.Kom., M.Kom
// Universitas  : Universitas Pamulang
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';       // Untuk mengatur orientasi layar
import 'package:provider/provider.dart';      // State management
import 'constants/app_colors.dart';            // Tema warna aplikasi
import 'services/app_provider.dart';           // Provider: Theme, Cart, Auth
import 'screens/auth/login_screen.dart';       // Halaman login (halaman awal)

// ========================
// FUNGSI UTAMA (MAIN)
// Titik masuk eksekusi program Flutter
// ========================
void main() async {
  // Pastikan binding Flutter sudah siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // Paksa orientasi layar hanya Portrait (tegak)
  // Agar tampilan tidak berubah saat device diputar
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Jalankan aplikasi Flutter
  runApp(const PanganTechApp());
}

// ========================
// WIDGET ROOT APLIKASI
// Seluruh aplikasi dibungkus di sini
// ========================
class PanganTechApp extends StatelessWidget {
  const PanganTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider: Mendaftarkan semua Provider agar bisa diakses
    // di seluruh widget tree (dari mana saja dalam aplikasi)
    return MultiProvider(
      providers: [
        // Provider untuk mengelola tema gelap/terang
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Provider untuk mengelola status login pengguna
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Provider untuk mengelola keranjang belanja
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],

      // Consumer<ThemeProvider>: Widget yang akan rebuild saat tema berubah
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            // ---- Konfigurasi Dasar App ----
            title: 'PanganTech',         // Nama app di task switcher
            debugShowCheckedModeBanner: false, // Sembunyikan banner "DEBUG"

            // ---- Tema Aplikasi ----
            // Tema aktif dipilih berdasarkan status isDarkMode dari ThemeProvider
            theme: AppTheme.lightTheme,           // Tema terang
            darkTheme: AppTheme.darkTheme,         // Tema gelap
            themeMode: themeProvider.isDarkMode    // Pilih tema berdasarkan setting
                ? ThemeMode.dark
                : ThemeMode.light,

            // ---- Halaman Pertama yang Ditampilkan ----
            home: const LoginScreen(), // Pengguna harus login terlebih dahulu

            // ---- Konfigurasi Route Named (opsional, untuk navigasi dengan string) ----
            // Bisa digunakan sebagai alternatif Navigator.push
            // routes: {
            //   '/login': (context) => const LoginScreen(),
            //   '/home': (context) => const MainNavigation(),
            // },
          );
        },
      ),
    );
  }
}
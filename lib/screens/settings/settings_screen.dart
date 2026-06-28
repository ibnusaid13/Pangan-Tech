// ============================================================
// FILE: lib/screens/settings/settings_screen.dart
// Deskripsi: Halaman Pengaturan Aplikasi
//            Fitur: Toggle Dark Mode, Tentang Aplikasi, Reset Data
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../database/database_helper.dart';
import '../../services/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final DatabaseHelper dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          // ---- Seksi Tampilan ----
          _buildSectionHeader('Tampilan'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                // Toggle Dark/Light Mode
                SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.primary,
                  ),
                  title: const Text('Mode Gelap'),
                  subtitle: Text(themeProvider.isDarkMode ? 'Aktif' : 'Tidak aktif'),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // ---- Seksi Notifikasi ----
          _buildSectionHeader('Notifikasi'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                  title: const Text('Notifikasi Promo'),
                  subtitle: const Text('Dapatkan info promo terbaru'),
                  value: true,
                  onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? 'Notifikasi diaktifkan' : 'Notifikasi dinonaktifkan'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  activeColor: AppColors.primary,
                ),
                const Divider(height: 1, indent: 54),
                SwitchListTile(
                  secondary: const Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                  title: const Text('Update Pengiriman'),
                  subtitle: const Text('Notifikasi status pesanan'),
                  value: true,
                  onChanged: (_) {},
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // ---- Seksi Data ----
          _buildSectionHeader('Data & Privasi'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.restore, color: AppColors.warning),
                  title: const Text('Reset Data Sembako'),
                  subtitle: const Text('Kembalikan data ke kondisi awal'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showResetDialog(context, dbHelper),
                ),
                const Divider(height: 1, indent: 54),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.error),
                  title: const Text('Hapus Semua Data'),
                  subtitle: const Text('Tidak dapat dibatalkan!'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDeleteAllDialog(context, dbHelper),
                ),
              ],
            ),
          ),

          // ---- Seksi Tentang ----
          _buildSectionHeader('Tentang Aplikasi'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: const Text('Versi Aplikasi'),
                  trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textSecondary)),
                ),
                const Divider(height: 1, indent: 54),
                ListTile(
                  leading: const Icon(Icons.school_outlined, color: AppColors.primary),
                  title: const Text('Tentang Proyek'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1, indent: 54),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                  title: const Text('Lisensi'),
                  subtitle: const Text('MIT License'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ---- Footer ----
          const Center(
            child: Text(
              '🌾 PanganTech\nUAS Mobile Programming - Universitas Pamulang\nTA 2025/2026',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Future<void> _showResetDialog(BuildContext context, DatabaseHelper dbHelper) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.restore, color: AppColors.warning, size: 36),
        title: const Text('Reset Data Sembako?'),
        content: const Text(
          'Data produk sembako akan dikembalikan ke kondisi awal. Keranjang belanja juga akan dikosongkan.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await dbHelper.resetDatabase();
      context.read<CartProvider>().clearCart();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data berhasil direset ke kondisi awal'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteAllDialog(BuildContext context, DatabaseHelper dbHelper) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 36),
        title: const Text('⚠️ Hapus Semua Data'),
        content: const Text(
          'PERINGATAN: Semua data produk dan keranjang akan dihapus permanen.\n\nTindakan ini TIDAK DAPAT dibatalkan!',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await dbHelper.clearCart();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil dihapus'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Text('🌾 ', style: TextStyle(fontSize: 24)),
            Text('PanganTech'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aplikasi Toko Sembako Modern', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Dibuat sebagai tugas UAS Mata Kuliah Mobile Programming '
                'Semester Genap TA 2025/2026.'),
            SizedBox(height: 8),
            Text('Universitas Pamulang\nFakultas Ilmu Komputer\nProgram Studi Sistem Informasi S-1'),
            SizedBox(height: 8),
            Text('Dosen: Samso Supriyatna, S.Kom., M.Kom'),
            Divider(),
            Text('Teknologi: Flutter + SQLite + REST API'),
            Text('Versi: 1.0.0'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
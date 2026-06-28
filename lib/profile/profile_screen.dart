// ============================================================
// FILE: lib/screens/profile/profile_screen.dart
// Deskripsi: Halaman Profil Pengguna
//            Menampilkan: info user, NIM, kelas, riwayat pesanan,
//            serta detail info Metode Pembayaran terintegrasi.
// ============================================================

import 'package:flutter/material.dart';
import 'package:pangantech/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import 'package:pangantech/services/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        // 💡 Tombol logout di kanan atas (AppBar) telah dihapus sesuai permintaan
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---- Header Profil ----
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                children: [
                  // Avatar Menggunakan Gambar dari Assets
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/pp.jpeg'),
                  ),
                  const SizedBox(height: 12),
                  
                  // Menggunakan Nama 'Ibnu Said' Langsung
                  const Text(
                    'Ibnu Said',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Mengubah Username Menjadi @ibnusaid
                  const Text(
                    '@ibnusaid',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✓ Pelanggan Terverifikasi',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // ---- Info Mahasiswa ----
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Card Info Mahasiswa
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.school, color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Data Mahasiswa',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _buildInfoRow('Nama Lengkap', 'Ibnu Said'),
                          _buildInfoRow('NIM', '241011700906'),
                          _buildInfoRow('Kelas', '04SIFP013'),
                          _buildInfoRow('Program Studi', 'Sistem Informasi S-1'),
                          _buildInfoRow('Fakultas', 'Ilmu Komputer'),
                          _buildInfoRow('Universitas', 'Universitas Pamulang'),
                          _buildInfoRow('Mata Kuliah', 'Mobile Programming'),
                          _buildInfoRow('Dosen Pengampu', 'Samso Supriyatna, S.Kom., M.Kom'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- Menu Profil ----
                  Card(
                    child: Column(
                      children: [
                        // 💡 SEKARANG BERFUNGSI: Menampilkan Bottom Sheet Riwayat Transaksi
                        _buildMenuTile(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Riwayat Pesanan',
                          onTap: () => _showOrderHistoryBottomSheet(context),
                        ),
                        const Divider(height: 1, indent: 54),
                        
                        // 💡 SEKARANG BERFUNGSI: Menampilkan Alamat Terdaftar
                        _buildMenuTile(
                          icon: Icons.location_on_outlined,
                          label: 'Alamat Pengiriman',
                          onTap: () => _showAddressBottomSheet(context),
                        ),
                        const Divider(height: 1, indent: 54),
                        
                        // Metode Pembayaran Simulasi
                        _buildMenuTile(
                          icon: Icons.payment_outlined,
                          label: 'Metode Pembayaran',
                          onTap: () => _showPaymentMethodsBottomSheet(context),
                        ),
                        const Divider(height: 1, indent: 54),
                        
                        // 💡 SEKARANG BERFUNGSI: Menampilkan Kontak Interaktif Hubungi Dosen/CS
                        _buildMenuTile(
                          icon: Icons.help_outline,
                          label: 'Bantuan & FAQ',
                          onTap: () => _showHelpBottomSheet(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tombol Logout Utama (Tetap Dipertahankan)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context, auth),
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: const Text('Keluar', style: TextStyle(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'PanganTech v1.0.0\nUAS Mobile Programming 2025/2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENT 1: INFO DETAIL ROW ---
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const Text(': ', style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT 2: LIST MENU TILE ---
  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }

  // --- FUNGSI BARU: BOTTOM SHEET RIWAYAT PESANAN ---
  void _showOrderHistoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text('Riwayat Pesanan Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.fastfood, color: Colors.orange),
                title: const Text('Paket Sembako Premium', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('28 Juni 2026 • QRIS Digital Wallet', style: TextStyle(fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
                  child: const Text('Selesai', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNGSI BARU: BOTTOM SHEET ALAMAT PENGIRIMAN ---
  void _showAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              const Card(
                color: Colors.white,
                child: ListTile(
                  leading: Icon(Icons.home, color: AppColors.primary),
                  title: Text('Rumah (Ibnu Said)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text('Cibinong Alam Lestari Blok C . No 08, Pabuaran, Cibinong, Kab. Bogor', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNGSI BARU: BOTTOM SHEET BANTUAN & FAQ ---
  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text('Pusat Bantuan PanganTech', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.blue),
                title: const Text('Email Layanan', style: TextStyle(fontSize: 14)),
                subtitle: const Text('pangantech@unpam.ac.id', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- INTERACTIVE BOTTOM SHEET: SHOW SIMULATED PAYMENT METHODS ---
  void _showPaymentMethodsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Metode Pembayaran PanganTech',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text(
                  'Daftar simulasi kanal pembayaran aktif Anda saat ini.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // 1. QRIS PREVIEW
                ExpansionTile(
                  leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                  title: const Text('QRIS Digital Wallet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Gopay, OVO, Dana, LinkAja', style: TextStyle(fontSize: 11)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.black87),
                          Text('Simulasi Standar QRIS Nasional Berhasil', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        ],
                      ),
                    )
                  ],
                ),

                // 2. DEBIT CARD PREVIEW
                ExpansionTile(
                  leading: const Icon(Icons.credit_card, color: Colors.purple),
                  title: const Text('Debit Card Virtual', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('**** **** **** 8890', style: TextStyle(fontSize: 11)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        width: 180,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.indigo, Colors.blue]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.contactless, color: Colors.white70, size: 16),
                                Text('DEBIT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                              ],
                            ),
                            Text('**** **** **** 8890', style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 1.5)),
                            Text('IBNU SAID', style: TextStyle(color: Colors.white70, fontSize: 9)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                // 3. CASH PREVIEW
                ExpansionTile(
                  leading: const Icon(Icons.money, color: Colors.green),
                  title: const Text('Tunai / Cash', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Bayar langsung di tempat / COD', style: TextStyle(fontSize: 11)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Icon(Icons.payments, color: Colors.green[700], size: 30),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- DIALOG LOGOUT ---
  Future<void> _showLogoutDialog(BuildContext context, AuthProvider auth) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.logout, color: AppColors.warning, size: 36),
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari PanganTech?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      auth.logout();
      context.read<CartProvider>().clearCart();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
// ============================================================
// FILE: lib/screens/cart/cart_screen.dart
// Deskripsi: Halaman Keranjang Belanja dengan Gateway Simulasi Visual
//            (QRIS Barcode, Debit Card, Cash/Uang) dan Struk Nota.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/app_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items; 

    double totalBelanja = 0;
    for (var item in items) {
      totalBelanja += item.totalHarga;
    }

    String totalBelanjaFormatted = 'Rp ${totalBelanja.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang (${items.length} Item)'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Keranjang belanja Anda kosong',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            )
          : Column(
              children: [
                // ---- DAFTAR ITEM DI KERANJANG ----
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(item.icon, style: const TextStyle(fontSize: 30)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.namaProduk,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      '${item.hargaFormatted} x ${item.jumlah}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Subtotal: ${item.totalHargaFormatted}',
                                      style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ---- BOTTOM BAR PANEL ----
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                    ],
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Total Pembayaran', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(totalBelanjaFormatted, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B5E20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _showConfirmationDialog(context, totalBelanjaFormatted, items),
                              child: const Text('Pesan Sekarang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // --- DIALOG 1: POPUP KONFIRMASI AWAL ---
  void _showConfirmationDialog(BuildContext context, String totalStr, List items) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.check, color: Colors.green, size: 30),
                ),
                const SizedBox(height: 16),
                const Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran:', style: TextStyle(fontSize: 13)),
                    Text(totalStr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Pesanan Anda akan segera diproses.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showPaymentGatewayDialog(context, totalStr, items);
                        },
                        child: const Text('Pesan Sekarang', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // --- DIALOG 2: POPUP PILIHAN METODE PEMBAYARAN ---
  void _showPaymentGatewayDialog(BuildContext context, String totalStr, List items) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                title: const Text('QRIS (Gopay / Dana / OVO)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _processPaymentSimulation(context, 'QRIS', totalStr, items);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.purple),
                title: const Text('Debit Card / Transfer Bank'),
                onTap: () {
                  Navigator.pop(ctx);
                  _processPaymentSimulation(context, 'Debit Card', totalStr, items);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.money, color: Colors.green),
                title: const Text('Tunai / Cash'),
                onTap: () {
                  Navigator.pop(ctx);
                  _processPaymentSimulation(context, 'Cash / Tunai', totalStr, items);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- DIALOG 3: PROSES SIMULASI DENGAN VISUALISASI TIAP METODE ---
  void _processPaymentSimulation(BuildContext context, String method, String totalStr, List items) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 💡 BLOK LOGIKA VISUALISASI GAMBAR BERDASARKAN METODE
            if (method == 'QRIS') ...[
              const Text('SIMULASI QRIS PANGANTECH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: const Icon(Icons.qr_code_2_rounded, size: 160, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text('Silakan Scan & Bayar: $totalStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ] else if (method == 'Debit Card') ...[
              const Text('SIMULASI KARTU DEBIT VIRTUAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                width: 220,
                height: 130,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.indigo, Colors.blue]),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.contactless, color: Colors.white70),
                        Text('DEBIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                      ],
                    ),
                    Text('**** **** **** 8890', style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('IBNU SAID', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text('12/29', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('Menarik Saldo: $totalStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ] else ...[
              const Text('SIMULASI PEMBAYARAN TUNAI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                width: 160,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(left: 4, top: 4, child: Text('Rp', style: TextStyle(color: Colors.green[800], fontSize: 10, fontWeight: FontWeight.bold))),
                    Positioned(right: 4, bottom: 4, child: Text('Rp', style: TextStyle(color: Colors.green[800], fontSize: 10, fontWeight: FontWeight.bold))),
                    CircleAvatar(radius: 20, backgroundColor: Colors.green[200], child: const Icon(Icons.payments, color: Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('Siapkan Uang Pas: $totalStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
            
            const SizedBox(height: 20),
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            ),
            const SizedBox(height: 12),
            Text('Memverifikasi transaksi...', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Tutup loading visual simulasi
      _showReceiptDialog(context, method, totalStr, items); // Tampilkan struk digital nota belanja
    });
  }

  // --- DIALOG 4: STRUK NOTA DIGITAL (RECEIPT) ---
  void _showReceiptDialog(BuildContext context, String method, String totalStr, List items) {
    final String invoiceNo = 'INV/PT-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final String dateStr = DateTime.now().toString().split('.')[0];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(20),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 54),
                  const SizedBox(height: 8),
                  const Text('TRANSAKSI BERHASIL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, letterSpacing: 0.5)),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(child: Text('PanganTech Indonesia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        const Center(child: Text('Toko Sembako Modern Berbasis Mobile', style: TextStyle(fontSize: 10, color: Colors.grey))),
                        const Divider(),
                        
                        _buildReceiptRow('No. Invoice', invoiceNo),
                        _buildReceiptRow('Waktu', dateStr),
                        _buildReceiptRow('Metode', method),
                        _buildReceiptRow('Status', 'LUNAS', valueColor: Colors.green),
                        
                        const Divider(),
                        const Text('Rincian Belanja:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(height: 4),
                        
                        ...items.map((item) => _buildReceiptRow(
                          '${item.namaProduk} (${item.jumlah}x)', 
                          item.totalHargaFormatted
                        )),
                        
                        const Divider(thickness: 1.2),
                        _buildReceiptRow('TOTAL STRUK', totalStr, isBold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Terima kasih telah berbelanja di PanganTech!\nSimpan struk digital ini sebagai bukti sah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  Navigator.pop(ctx); 
                  context.read<CartProvider>().clearCart(); 
                },
                child: const Text('Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}
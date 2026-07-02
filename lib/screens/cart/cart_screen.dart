// ============================================================
// FILE: lib/screens/cart/cart_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database_helper.dart';
import '../../services/app_provider.dart'; // Pastikan path ke app_provider Anda benar

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).loadCart();
    });
  }

  // --- TAMPILKAN STRUK BELANJA SPESIFIK UNTUK MASING-MASING PEMBAYARAN ---
  void _tampilkanStrukSpesifik(BuildContext context, String metode, List<dynamic> listStruk, double totalStruk) {
    final tanggalKini = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    Widget headerVisual;
    String infoTambahan = '';

    // Kustomisasi visualisasi struk berdasarkan masing-masing metode pembayaran
    if (metode == 'PanganPay') {
      headerVisual = const Column(
        children: [
          Icon(Icons.check_circle_rounded, size: 70, color: Colors.green),
          SizedBox(height: 8),
          Text('PANGANPAY BERHASIL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
        ],
      );
      infoTambahan = 'Status: Saldo Terpotong Otomatis';
    } else if (metode == 'QRIS') {
      headerVisual = const Column(
        children: [
          Icon(Icons.qr_code_2_rounded, size: 85, color: Colors.blue),
          SizedBox(height: 4),
          Text('QRIS PANGANTECH', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)),
        ],
      );
      infoTambahan = 'Status: Simulasi Scan QR Berhasil';
    } else if (metode == 'Debit') {
      headerVisual = const Column(
        children: [
          Icon(Icons.credit_card_rounded, size: 70, color: Colors.orange),
          SizedBox(height: 8),
          Text('DEBIT / TRANSFER BANK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16)),
        ],
      );
      infoTambahan = 'No. Ref: DB-${DateTime.now().millisecond}99X\nStatus: Terverifikasi';
    } else {
      headerVisual = const Column(
        children: [
          Icon(Icons.payments_outlined, size: 70, color: Colors.teal),
          SizedBox(height: 8),
          Text('TUNAI / COD', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16)),
        ],
      );
      infoTambahan = 'Status: Bayar Saat Kurir Datang';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Header Visual Sesuai Metode
                  headerVisual,
                  const SizedBox(height: 6),
                  Text('Tanggal: $tanggalKini', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const Divider(thickness: 1.5, height: 25),
                  
                  // 2. Body Struk: Rincian Item Belanja
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('RINCIAN ITEM:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 8),
                  
                  // Perbaikan RenderBox: Dibungkus menggunakan SizedBox tinggi tetap agar terhindar dari RenderIntrinsicWidth Crash
                  SizedBox(
                    height: listStruk.length * 35.0 > 140.0 ? 140.0 : listStruk.length * 35.0,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: listStruk.length,
                      itemBuilder: (context, index) {
                        final item = listStruk[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.namaProduk} (x${item.jumlah})', 
                                  style: const TextStyle(fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'Rp ${(item.hargaSatuan * item.jumlah).toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(thickness: 1, height: 20),
                  
                  // 3. Footer Struk: Total Harga & Info Tambahan Metode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Metode Pembayaran:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(metode, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                        'Rp ${totalStruk.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      infoTambahan,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext); // 1. Tutup dialog struk belanja dulu
                  
                  // 2. Kosongkan keranjang belanja lewat provider
                  final cartProvider = Provider.of<CartProvider>(context, listen: false);
                  await cartProvider.clearCart(); 

                  // 3. Kembali ke halaman dashboard utama
                  if (context.mounted && Navigator.canPop(context)) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Selesai & Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        );
      },
    );
  }

  // --- FUNGSI UTAMA EKSEKUSI TRANSAKSI ---
  void _eksekusiPembayaran(CartProvider cartProvider, String metode) async {
    // Ambil data salinan item sebelum dihapus/di-clear
    final listStrukSewa = [...cartProvider.items];
    final totalHargaSewa = cartProvider.totalHarga;

    if (metode == 'PanganPay') {
      setState(() => _isProcessing = true);
      bool sukses = await _dbHelper.bayarPakaiPanganPay(totalHargaSewa);
      setState(() => _isProcessing = false);

      if (sukses) {
        if (!mounted) return;
        _tampilkanStrukSpesifik(context, metode, listStrukSewa, totalHargaSewa);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi Gagal! Saldo PanganPay tidak mencukupi, silakan Top Up.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Untuk QRIS, Debit, atau Cash -> Langsung munculkan struk spesifik
      _tampilkanStrukSpesifik(context, metode, listStrukSewa, totalHargaSewa);
    }
  }

  // --- TAMPILKAN PILIHAN METODE PEMBAYARAN (BOTTOM SHEET) ---
  void _tampilkanPilihanPembayaran(BuildContext context, CartProvider cartProvider) {
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang Anda masih kosong!'), backgroundColor: Colors.orange),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                  title: const Text('PanganPay (Potong Saldo)'),
                  onTap: () async {
                    Navigator.pop(bc);
                    await Future.delayed(const Duration(milliseconds: 250));
                    if (!mounted) return;
                    _eksekusiPembayaran(cartProvider, 'PanganPay');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                  title: const Text('QRIS (Simulasi QR Code)'),
                  onTap: () async {
                    Navigator.pop(bc);
                    await Future.delayed(const Duration(milliseconds: 250));
                    if (!mounted) return;
                    _eksekusiPembayaran(cartProvider, 'QRIS');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.credit_card, color: Colors.orange),
                  title: const Text('Debit / Transfer Bank'),
                  onTap: () async {
                    Navigator.pop(bc);
                    await Future.delayed(const Duration(milliseconds: 250));
                    if (!mounted) return;
                    _eksekusiPembayaran(cartProvider, 'Debit');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.money, color: Colors.grey),
                  title: const Text('Tunai / Cash (COD)'),
                  onTap: () async {
                    Navigator.pop(bc);
                    await Future.delayed(const Duration(milliseconds: 250));
                    if (!mounted) return;
                    _eksekusiPembayaran(cartProvider, 'Cash');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final itemKeranjang = cartProvider.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Keranjang Belanja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        leading: Navigator.canPop(context) 
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => cartProvider.loadCart(),
          )
        ],
      ),
      body: cartProvider.isLoading || _isProcessing
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : itemKeranjang.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Keranjang belanja Anda kosong.',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: itemKeranjang.length,
                        itemBuilder: (context, index) {
                          final item = itemKeranjang[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade50,
                                child: Text(item.icon ?? '🛒', style: const TextStyle(fontSize: 20)),
                              ),
                              title: Text(item.namaProduk, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.red),
                                    onPressed: () {
                                      if (item.jumlah > 1) {
                                        cartProvider.updateJumlah(item.id!, item.jumlah - 1);
                                      } else {
                                        cartProvider.removeItem(item.id!);
                                      }
                                    },
                                  ),
                                  Text('${item.jumlah} pcs', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.green),
                                    onPressed: () {
                                      cartProvider.updateJumlah(item.id!, item.jumlah + 1);
                                    },
                                  ),
                                ],
                              ),
                              trailing: Text(
                                'Rp ${(item.hargaSatuan * item.jumlah).toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(
                                cartProvider.totalHargaFormatted,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _tampilkanPilihanPembayaran(context, cartProvider),
                              child: const Text(
                                'Pesan Sekarang',
                                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
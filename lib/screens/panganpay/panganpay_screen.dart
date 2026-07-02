// ============================================================
// FILE: lib/screens/panganpay/panganpay_screen.dart
// Deskripsi: Halaman detail PanganPay yang menampilkan Saldo,
//             Koin, status Member, serta Form Top Up terintegrasi
//             dengan pilihan metode pembayaran (QRIS, Debit, E-Wallet).
// ============================================================

import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class PanganPayScreen extends StatefulWidget {
  const PanganPayScreen({Key? key}) : super(key: key);

  @override
  State<PanganPayScreen> createState() => _PanganPayScreenState();
}

class _PanganPayScreenState extends State<PanganPayScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  double _saldo = 0.0;
  final int _koin = 1500; // Contoh data koin yang dipertahankan
  final String _statusMember = "Gold Member"; // Contoh status member yang dipertahankan
  
  final TextEditingController _topUpController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _muatSaldo();
  }

  Future<void> _muatSaldo() async {
    setState(() => _isLoading = true);
    double saldo = await _dbHelper.getSaldoPanganPay();
    setState(() {
      _saldo = saldo;
      _isLoading = false;
    });
  }

  // --- TAMPILKAN POP-UP VISUAL SIMULASI BERDASARKAN METODE TOP UP ---
  void _tampilkanSimulasiTopUp(String metode, double jumlah) {
    Widget kontenVisual;

    if (metode == 'QRIS') {
      kontenVisual = const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 140, color: Colors.blue),
          SizedBox(height: 10),
          Text('Silakan Scan QRIS Mitra PanganTech', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      );
    } else if (metode == 'Debit') {
      kontenVisual = const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.credit_card_rounded, size: 120, color: Colors.orange),
          SizedBox(height: 10),
          Text('Menghubungkan ke Gateway Bank...', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      );
    } else {
      // E-Wallet (GoPay, DANA, OVO)
      kontenVisual = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet_rounded, size: 120, color: Colors.deepPurple),
          const SizedBox(height: 10),
          Text('Membuka simulasi aplikasi $metode...', style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Simulasi $metode',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: kontenVisual,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext); // Tutup dialog simulasi
                  await _eksekusiTopUp(jumlah); // Jalankan penyimpanan saldo ke SQLite
                },
                child: const Text('Konfirmasi Pembayaran Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        );
      },
    );
  }

  // --- EKSEKUSI PENAMBAHAN SALDO KE SQLITE ---
  Future<void> _eksekusiTopUp(double jumlah) async {
    setState(() => _isLoading = true);
    await _dbHelper.topUpSaldo(jumlah);
    _topUpController.clear();
    
    // Ambil saldo terbaru setelah berhasil top up
    double saldoTerbaru = await _dbHelper.getSaldoPanganPay();
    
    setState(() {
      _saldo = saldoTerbaru;
      _isLoading = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Top up berhasil! Saldo bertambah Rp ${jumlah.toStringAsFixed(0)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- VALIDASI AWAL & TAMPILKAN LEMBAR PILIHAN METODE (BOTTOM SHEET) ---
  void _prosesPilihanMetode() {
    double? jumlah = double.tryParse(_topUpController.text);
    if (jumlah == null || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal top up yang valid terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
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
                  'Pilih Metode Pembayaran Top Up',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // 1. QRIS
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                  title: const Text('QRIS'),
                  onTap: () async {
                    Navigator.pop(bc);
                    await Future.delayed(const Duration(milliseconds: 250));
                    _tampilkanSimulasiTopUp('QRIS', jumlah);
                  },
                ),
                const Divider(),
                
                // 2. Debit Card
                ListTile(
                  leading: const Icon(Icons.credit_card, color: Colors.orange),
                  title: const Text('Debit / Transfer Virtual Account'),
                  onTap: () async {
                    Navigator.pop(bc);
                    await Future.delayed(const Duration(milliseconds: 250));
                    _tampilkanSimulasiTopUp('Debit', jumlah);
                  },
                ),
                const Divider(),
                
                // 3. E-Wallet Options
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.deepPurple),
                  title: const Text('E-Wallet (GoPay / DANA / OVO)'),
                  onTap: () async {
                    Navigator.pop(bc);
                    await Future.delayed(const Duration(milliseconds: 250));
                    _tampilkanSimulasiTopUp('E-Wallet', jumlah);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('PanganPay Wallet', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =========================================================
                  // KARTU UTAMA: SALDO, KOIN, & MEMBER (TIDAK DIHILANGKAN)
                  // =========================================================
                  Card(
                    color: Colors.green.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'PanganPay Wallet',
                                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade600,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _statusMember,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Total Saldo Anda',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${_saldo.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const Divider(color: Colors.white30, height: 25),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '$_koin Koin',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '(Bisa ditukar potongan belanja)',
                                style: TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // =========================================================
                  // FORM PENGISIAN / TOP UP SALDO
                  // =========================================================
                  const Text(
                    'Isi Ulang Saldo / Top Up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _topUpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      hintText: 'Masukkan nominal (Contoh: 50000)',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _prosesPilihanMetode, // Mengarah ke pemilihan metode terlebih dahulu
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Konfirmasi Top Up',
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
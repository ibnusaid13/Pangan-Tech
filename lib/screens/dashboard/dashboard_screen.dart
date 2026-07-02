// ============================================================
// FILE: lib/screens/dashboard/dashboard_screen.dart
// Deskripsi: Dashboard utama dengan filter kategori (bebas overflow),
//            ikon keranjang AppBar & tombol produk yang keduanya
//            langsung terhubung (ngelink) ke halaman CartScreen,
//            tombol chat terhubung ke ChatScreen, serta tambahan
//            BANNER PROMO SLIDE OTOMATIS menggunakan PageView & Timer.
// ============================================================

import 'dart:async'; // WAJIB UNTUK TIMER AUTOMATIC SLIDE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pangantech/services/app_provider.dart';
import '../../database/database_helper.dart';
import '../../models/sembako_model.dart';
import '../panganpay/panganpay_screen.dart';
import '../cart/cart_screen.dart'; 
import '../chat/chat_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<SembakoModel> _semuaProduk = [];
  List<SembakoModel> _produkDitampilkan = [];
  String _kategoriTerpilih = 'Semua';
  double _saldoPanganPay = 0.0;
  int _jumlahKeranjang = 0; 
  bool _isLoading = false;

  // ---- STATE UNTUK BANNER PROMO AUTOMATIC SLIDE ----
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _bannerTimer;

  // Data dummy konten banner promo (bisa Anda ganti teks/warnanya nanti)
  final List<Map<String, dynamic>> _promoBanners = [
    {
      'title': 'Diskon Gila Belanja Beras!',
      'subtitle': 'Potongan harga hingga 20% khusus pengguna PanganPay.',
      'color': Colors.red.shade400,
      'icon': Icons.local_fire_department,
    },
    {
      'title': 'Gratis Ongkir Akhir Pekan',
      'subtitle': 'Minimal belanja Rp 50.000 ke seluruh area jangkauan.',
      'color': Colors.blue.shade600,
      'icon': Icons.local_shipping,
    },
    {
      'title': 'Cashback Koin Melimpah',
      'subtitle': 'Top Up PanganPay minimal Rp 100.000 dapat bonus 5.000 Koin!',
      'color': Colors.amber.shade700,
      'icon': Icons.monetization_on,
    },
  ];

  @override
  void initState() {
    super.initState();
    _muatDataDashboard();
    _mulaiMekanismeSlideOtomatis(); // Aktifkan timer banner
  }

  @override
  void dispose() {
    _bannerTimer?.cancel(); // Batalkan timer saat screen dihancurkan agar tidak memory leak
    _pageController.dispose();
    super.dispose();
  }

  // Mengatur interval pergeseran halaman banner otomatis (setiap 3 detik)
  void _mulaiMekanismeSlideOtomatis() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _promoBanners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  // Memuat data produk, saldo, dan jumlah item di keranjang
  Future<void> _muatDataDashboard() async {
    setState(() => _isLoading = true);
    try {
      final data = await _dbHelper.getAllSembako();
      final saldo = await _dbHelper.getSaldoPanganPay();
      final hitungCart = await _dbHelper.getCartCount(); 
      setState(() {
        _semuaProduk = data;
        _produkDitampilkan = data;
        _saldoPanganPay = saldo;
        _jumlahKeranjang = hitungCart;
        _kategoriTerpilih = 'Semua';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _saringProdukDiTempat(String kategori) {
    setState(() {
      if (_kategoriTerpilih.toLowerCase() == kategori.toLowerCase()) {
        _kategoriTerpilih = 'Semua';
        _produkDitampilkan = _semuaProduk;
      } else {
        _kategoriTerpilih = kategori;
        if (kategori == 'Semua') {
          _produkDitampilkan = _semuaProduk;
        } else {
          _produkDitampilkan = _semuaProduk
              .where((p) => p.kategori.toLowerCase() == kategori.toLowerCase())
              .toList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('PanganTech Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          // 1. Ikon Chat
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                ),
              );
            },
          ),
          
          // 2. IKON KERANJANG POJOK ATAS (NGELINK KE TAMPILAN KERANJANG)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                  _muatDataDashboard(); 
                },
              ),
              if (_jumlahKeranjang > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '$_jumlahKeranjang',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: _muatDataDashboard,
              color: Colors.green,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KARTU SALDO PANGANPAY
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PanganPayScreen()),
                        );
                        _muatDataDashboard();
                      },
                      child: Card(
                        color: Colors.green.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet, color: Colors.white, size: 30),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('PanganPay Saldo', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp ${_saldoPanganPay.toStringAsFixed(0)}',
                                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add_circle_outline, color: Colors.green, size: 16),
                                    SizedBox(width: 4),
                                    Text('Top Up', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // =========================================================
                    // WIDGET BARU: BANNER PROMO SLIDE OTOMATIS
                    // =========================================================
                    SizedBox(
                      height: 120,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _promoBanners.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final banner = _promoBanners[index];
                          return Card(
                            color: banner['color'],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          banner['title'],
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          banner['subtitle'],
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(banner['icon'], size: 50, color: Colors.white38),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // INDIKATOR TITIK (DOT INDICATOR) UNTUK BANNER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_promoBanners.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: _currentPage == index ? 16 : 6,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? Colors.green : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // FILTER KATEGORI (Scrollable Horizontal)
                    const Text('Kategori Pangan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: ['Semua', 'Beras', 'Minyak', 'Telur', 'Bumbu', 'Susu', 'Mi Instan'].map((kat) {
                          final isSelected = _kategoriTerpilih.toLowerCase() == kat.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(kat),
                              selected: isSelected,
                              selectedColor: Colors.green,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) => _saringProdukDiTempat(kat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // LIST DAFTAR PRODUK SEMBAKO
                    const Text('Daftar Sembako', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _produkDitampilkan.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text('Tidak ada produk kategori ini.')),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _produkDitampilkan.length,
                            itemBuilder: (context, index) {
                              final produk = _produkDitampilkan[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green.shade50,
                                      radius: 24,
                                      child: Text(produk.icon ?? '🛒', style: const TextStyle(fontSize: 24)),
                                    ),
                                    title: Text(produk.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Stok: ${produk.stok} ${produk.satuan}',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Rp ${produk.harga.toStringAsFixed(0)}',
                                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(width: 8),
                                        
                                        // IKON KERANJANG PRODUK
                                        IconButton(
                                          icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                                          onPressed: () async {
                                            bool sukses = await Provider.of<CartProvider>(context, listen: false).addItem(produk);
                                            
                                            if (sukses) {
                                              _muatDataDashboard();
                                              
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${produk.nama} berhasil dimasukkan ke keranjang!'),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );

                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const CartScreen()),
                                              );
                                              
                                              _muatDataDashboard();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
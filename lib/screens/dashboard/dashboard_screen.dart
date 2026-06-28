// ============================================================
// FILE: lib/screens/dashboard/dashboard_screen.dart
// Deskripsi: Halaman Dashboard dengan Filter Promo & Klik Masuk Keranjang
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../database/database_helper.dart';
import '../../models/sembako_model.dart';
import '../../services/app_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<SembakoModel> _semuaProduk = [];
  bool _isLoading = true;

  // State untuk menyimpan filter yang sedang aktif
  String _kategoriTerpilih = 'Semua'; 
  String _promoTerpilih = ''; 

  // Data promo banner
  final List<Map<String, dynamic>> _bannerPromo = [
    {
      'id_promo': 'Beras', 
      'judul': 'Promo Hari Ini!', 
      'subjudul': 'Beras Premium diskon 15%', 
      'warna': AppColors.primary, 
      'icon': '🍚'
    },
    {
      'id_promo': 'Minyak', 
      'judul': 'Flash Sale!', 
      'subjudul': 'Minyak Goreng Harga Spesial', 
      'warna': AppColors.accent, 
      'icon': '🫙'
    },
    {
      'id_promo': 'Ongkir', 
      'judul': 'Belanja Hemat', 
      'subjudul': 'Gratis Ongkir Semua Produk Sembako!', 
      'warna': AppColors.info, 
      'icon': '🚚'
    },
  ];

  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startBannerAutoPlay();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _semuaProduk = await _dbHelper.getAllSembako();
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startBannerAutoPlay() {
    Future.delayed(const Duration(seconds: 4), () { 
      if (mounted && _promoTerpilih.isEmpty) { 
        setState(() {
          _bannerIndex = (_bannerIndex + 1) % _bannerPromo.length;
        });
        _startBannerAutoPlay();
      } else if (mounted) {
        _startBannerAutoPlay(); 
      }
    });
  }

  void _handleAksiPromo(Map<String, dynamic> promo) {
    setState(() {
      _kategoriTerpilih = 'Semua'; 
      if (_promoTerpilih == promo['id_promo']) {
        _promoTerpilih = '';
      } else {
        _promoTerpilih = promo['id_promo'] as String;
      }
    });
  }

  void _handleAksiKategori(String namaKategori) {
    setState(() {
      _promoTerpilih = ''; 
      if (_kategoriTerpilih == namaKategori) {
        _kategoriTerpilih = 'Semua';
      } else {
        _kategoriTerpilih = namaKategori;
      }
    });
  }

  // --- LOGIKA: Tambah ke Keranjang saat Produk Diklik ---
  void _tambahKeKeranjang(SembakoModel produk) {
    try {
      // Memanggil fungsi tambah keranjang dari Provider Anda
      // Catatan: Jika di kode Anda namanya 'AppProvider', ganti 'CartProvider' menjadi 'AppProvider'
      context.read<CartProvider>().addToCart(produk);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${produk.nama} berhasil dimasukkan ke keranjang! 🛒'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Fallback jika nama provider berbeda di project Anda
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan. Pastikan CartProvider/AppProvider dikonfigurasi.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String namaUser = context.watch<AuthProvider>().namaUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PanganTech', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _kategoriTerpilih = 'Semua';
                _promoTerpilih = '';
              });
              _loadData();
            },
            tooltip: 'Reset & Perbarui data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $namaUser 👋',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Temukan kebutuhan sembako Anda hari ini',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    _buildBannerPromo(),
                    const SizedBox(height: 20),

                    _buildStatistikSection(),
                    const SizedBox(height: 20),

                    _buildKategoriSection(),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _promoTerpilih.isNotEmpty 
                                ? 'Hasil Promo: $_promoTerpilih' 
                                : (_kategoriTerpilih == 'Semua' ? 'Produk Unggulan' : 'Kategori: $_kategoriTerpilih'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_kategoriTerpilih != 'Semua' || _promoTerpilih.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _kategoriTerpilih = 'Semua';
                                _promoTerpilih = '';
                              });
                            },
                            child: const Text('Reset Filter', style: TextStyle(fontSize: 12)),
                          )
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    _buildDaftarProduk(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBannerPromo() {
    final Map<String, dynamic> banner = _bannerPromo[_bannerIndex];
    final bool isSedangDipilih = _promoTerpilih == banner['id_promo'];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey<int>(_bannerIndex), 
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: banner['warna'] as Color,
          borderRadius: BorderRadius.circular(16),
          border: isSedangDipilih ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: (banner['warna'] as Color).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      banner['judul'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banner['subjudul'] as String,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _handleAksiPromo(banner),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSedangDipilih ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isSedangDipilih ? 'Melihat Promo X' : 'Lihat Promo',
                          style: TextStyle(
                            fontSize: 11, 
                            fontWeight: FontWeight.bold, 
                            color: isSedangDipilih ? Colors.white : Colors.black
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(banner['icon'] as String, style: const TextStyle(fontSize: 60)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistikSection() {
    final int totalProduk = _semuaProduk.length;
    final int stokRendah = _semuaProduk.where((p) => p.stok < 20).length;
    final int totalStok = _semuaProduk.fold(0, (sum, p) => sum + p.stok);

    return Row(
      children: [
        _buildStatCard('Total Produk', '$totalProduk', Icons.inventory_2, AppColors.primary),
        const SizedBox(width: 8),
        _buildStatCard('Total Stok', '$totalStok', Icons.warehouse, AppColors.info),
        const SizedBox(width: 8),
        _buildStatCard('Stok Rendah', '$stokRendah', Icons.warning_amber, AppColors.warning),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildKategoriSection() {
    final List<Map<String, dynamic>> kategori = [
      {'nama': 'Beras', 'icon': '🍚'},
      {'nama': 'Minyak', 'icon': '🫙'},
      {'nama': 'Gula', 'icon': '🧂'},
      {'nama': 'Telur', 'icon': '🥚'},
      {'nama': 'Tepung', 'icon': '🌾'},
      {'nama': 'Bumbu', 'icon': '🍶'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal, 
            itemCount: kategori.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final Map<String, dynamic> kat = kategori[index];
              final bool isSelected = _kategoriTerpilih == kat['nama'];
              
              return InkWell(
                onTap: () => _handleAksiKategori(kat['nama'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(kat['icon'] as String, style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kat['nama'] as String,
                        style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDaftarProduk() {
    List<SembakoModel> produkTerfilter = [];

    if (_promoTerpilih.isNotEmpty) {
      // Membersihkan teks jika ada sisa bawaan 'promo_beras' menjadi hanya 'beras'
      String kataKunciPromo = _promoTerpilih.replaceAll('promo_', '').toLowerCase();

      if (kataKunciPromo == 'ongkir') {
        produkTerfilter = _semuaProduk;
      } else {
        // Mencari produk yang mengandung kata kunci (misal nama produk mengandung 'beras' atau 'minyak')
        produkTerfilter = _semuaProduk
            .where((p) => p.nama.toLowerCase().contains(kataKunciPromo))
            .toList();
      }
    } else if (_kategoriTerpilih != 'Semua') {
      produkTerfilter = _semuaProduk
          .where((p) => p.nama.toLowerCase().contains(_kategoriTerpilih.toLowerCase()))
          .toList();
    } else {
      produkTerfilter = _semuaProduk;
    }

    if (produkTerfilter.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Tidak ada produk yang cocok dengan filter.', 
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Column(
      children: produkTerfilter.map((produk) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            onTap: () => _tambahKeKeranjang(produk), 
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(produk.icon, style: const TextStyle(fontSize: 26))),
            ),
            title: Text(produk.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Row(
              children: [
                Text('Stok: ${produk.stok} ${produk.satuan}'),
                if (_promoTerpilih.toLowerCase().contains('ongkir')) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Bebas Ongkir', 
                      style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  )
                ]
              ],
            ),
            trailing: const Icon(Icons.add_shopping_cart, color: AppColors.primary),
          ),
        );
      }).toList(),
    );
  }
}
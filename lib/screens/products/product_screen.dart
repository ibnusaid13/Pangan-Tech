// ============================================================
// FILE: lib/screens/products/product_screen.dart
// Deskripsi: Halaman Katalog Sembako PanganTech
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database_helper.dart';
import '../../models/sembako_model.dart';
import '../../services/app_provider.dart'; 
import 'product_detail_screen.dart'; // PERBAIKAN: Import file detail yang benar

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<SembakoModel> _listProduk = [];
  List<SembakoModel> _listProdukTersaring = [];
  bool _isLoading = true;
  String _kategoriTerpilih = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _kategoriMenu = ['Semua', 'Beras', 'Minyak', 'Telur', 'Gula', 'Bumbu', 'Susu', 'Tepung', 'Mi Instan'];

  @override
  void initState() {
    super.initState();
    _muatDataProduk();
  }

  // --- Deteksi jika tab navigasi berubah, langsung load data terbaru ---
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cartProvider = context.watch<CartProvider>();
    if (cartProvider.selectedIndex == 1) {
      _muatDataProdukSiluman(); 
    }
  }

  // Muat data standar dengan loading indicator
  Future<void> _muatDataProduk() async {
    setState(() => _isLoading = true);
    try {
      final data = await _dbHelper.getAllSembako();
      setState(() {
        _listProduk = data;
        _listProdukTersaring = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Ambil data diam-diam di latar belakang
  Future<void> _muatDataProdukSiluman() async {
    try {
      final data = await _dbHelper.getAllSembako();
      if (mounted) {
        setState(() {
          _listProduk = data;
          if (_kategoriTerpilih == 'Semua') {
            _listProdukTersaring = data;
          } else {
            _listProdukTersaring = data.where((p) => p.kategori.toLowerCase() == _kategoriTerpilih.toLowerCase()).toList();
          }
        });
      }
    } catch (_) {}
  }

  void _filterKategori(String kategori) {
    setState(() {
      _kategoriTerpilih = kategori;
      if (kategori == 'Semua') {
        _listProdukTersaring = _listProduk;
      } else {
        _listProdukTersaring = _listProduk.where((p) => p.kategori.toLowerCase() == kategori.toLowerCase()).toList();
      }
    });
  }

  void _pencarianProduk(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterKategori(_kategoriTerpilih);
      } else {
        _listProdukTersaring = _listProduk.where((p) {
          final matchesNama = p.nama.toLowerCase().contains(query.toLowerCase());
          final matchesKategori = p.kategori.toLowerCase().contains(query.toLowerCase());
          return matchesNama || matchesKategori;
        }).toList();
      }
    });
  }

  // --- SINKRONISASI TOMBOL BELI DENGAN CARTPROVIDER GLOBAL ---
  void _tambahKeKeranjang(SembakoModel produk) async {
    try {
      if (produk.stok <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stok produk habis!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // PERBAIKAN: Mengaktifkan pemanggilan addToCart ke Provider global
      await context.read<CartProvider>().addToCart(produk); 
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${produk.nama} berhasil masuk keranjang!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan ke keranjang: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog PanganTech', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await _dbHelper.resetDatabase();
              await _muatDataProduk();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _pencarianProduk,
              decoration: InputDecoration(
                hintText: 'Cari beras, minyak, cabai, bumbu...',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),

          // FILTER KATEGORI TAB
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _kategoriMenu.length,
              itemBuilder: (context, index) {
                final kat = _kategoriMenu[index];
                final isSelected = _kategoriTerpilih == kat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(kat),
                    selected: isSelected,
                    onSelected: (_) => _filterKategori(kat),
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    backgroundColor: Colors.grey[200],
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // LIST GRID KATALOG
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)))
                : _listProdukTersaring.isEmpty
                    ? const Center(child: Text('Produk tidak ditemukan', style: TextStyle(color: Colors.grey)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _listProdukTersaring.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(_listProdukTersaring[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(SembakoModel produk) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // PERBAIKAN: Aktifkan navigasi dan sesuaikan nama class ke ProductDetailScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(produk: produk),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Text(
                    produk.icon.isNotEmpty ? produk.icon : '🛒',
                    style: const TextStyle(fontSize: 54),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Per ${produk.satuan}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${produk.harga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stok: ${produk.stok} ${produk.satuan}',
                    style: TextStyle(
                      fontSize: 11, 
                      color: produk.stok > 5 ? Colors.grey[600] : Colors.red,
                      fontWeight: produk.stok > 5 ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () => _tambahKeKeranjang(produk),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 14),
                          SizedBox(width: 4),
                          Text('Keranjang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
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
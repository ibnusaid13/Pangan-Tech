// ============================================================
// FILE: lib/screens/products/products_screen.dart
// Deskripsi: Halaman Daftar Produk Sembako dengan Grid/List View
//            Fitur: Search, Filter Kategori, Gambar Dinamis (Ikon DB)
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../database/database_helper.dart';
import '../../models/sembako_model.dart';
import '../../services/app_provider.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchCtrl = TextEditingController();

  List<SembakoModel> _semuaProduk = [];
  List<SembakoModel> _produkFiltered = []; 
  bool _isLoading = true;
  bool _isGridView = true;    
  String _filterKategori = 'Semua'; 

  final List<String> _daftarKategori = ['Semua', 'Beras', 'Minyak', 'Gula', 'Telur', 'Tepung', 'Bumbu', 'Mie'];

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProduk() async {
    setState(() => _isLoading = true);
    try {
      _semuaProduk = await _dbHelper.getAllSembako();
      _applyFilter(); 
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    List<SembakoModel> hasil = List.from(_semuaProduk);

    if (_filterKategori != 'Semua') {
      hasil = hasil.where((p) => p.kategori == _filterKategori).toList();
    }

    final String keyword = _searchCtrl.text.trim().toLowerCase();
    if (keyword.isNotEmpty) {
      hasil = hasil.where((p) =>
          p.nama.toLowerCase().contains(keyword) ||
          p.kategori.toLowerCase().contains(keyword)).toList();
    }

    setState(() => _produkFiltered = hasil);
  }

  Future<void> _tambahKeKeranjang(SembakoModel produk) async {
    final bool berhasil = await context.read<CartProvider>().addToCart(produk);

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(produk.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(child: Text('${produk.nama} ditambahkan ke keranjang!')),
          ],
        ),
        backgroundColor: berhasil ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Sembako'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'Tampilan List' : 'Tampilan Grid',
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- Search Bar ----
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _applyFilter(), 
              decoration: InputDecoration(
                hintText: 'Cari sembako...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _applyFilter();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // ---- Filter Kategori ----
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _daftarKategori.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final String kat = _daftarKategori[index];
                final bool isActive = kat == _filterKategori;
                return GestureDetector(
                  onTap: () {
                    setState(() => _filterKategori = kat);
                    _applyFilter();
                  },
                  child: Chip(
                    label: Text(kat),
                    backgroundColor: isActive ? AppColors.primary : Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                );
              },
            ),
          ),

          // ---- Info Jumlah Produk ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${_produkFiltered.length} produk ditemukan',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),

          // ---- Konten Daftar Sembako ----
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _produkFiltered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 60, color: AppColors.textSecondary),
                            SizedBox(height: 10),
                            Text('Produk tidak ditemukan'),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProduk,
                        child: _isGridView ? _buildGridView() : _buildListView(),
                      ),
          ),
        ],
      ),
    );
  }

  // ---- Grid View Layout ----
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,      
        childAspectRatio: 0.76,  
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _produkFiltered.length,
      itemBuilder: (context, index) {
        return _buildGridCard(_produkFiltered[index]);
      },
    );
  }

  Widget _buildGridCard(SembakoModel produk) {
    return GestureDetector(
      onTap: () => _navigateToDetail(produk),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GANTI DISINI: Menggunakan Container + Icon Emoji Sembako Dinamis
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.primary.withOpacity(0.06),
                    child: Center(
                      child: Text(
                        produk.icon, 
                        style: const TextStyle(fontSize: 55),
                      ),
                    ),
                  ),
                  // Lencana Stok Rendah
                  if (produk.stok < 20)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Stok Rendah',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Deskripsi Singkat Card
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk.nama,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${produk.harga.toStringAsFixed(0)}/${produk.satuan}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => _tambahKeKeranjang(produk),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_shopping_cart, size: 14),
                          SizedBox(width: 4),
                          Text('Tambah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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

  // ---- List View Layout ----
  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _produkFiltered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _buildListCard(_produkFiltered[index]);
      },
    );
  }

  Widget _buildListCard(SembakoModel produk) {
    return Card(
      child: InkWell(
        onTap: () => _navigateToDetail(produk),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // GANTI DISINI: Menggunakan Ikon Emoji Sembako untuk List View
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    produk.icon, 
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(produk.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(produk.kategori,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${produk.harga.toStringAsFixed(0)}/${produk.satuan}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Stok: ${produk.stok} ${produk.satuan}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: AppColors.primary),
                onPressed: () => _tambahKeKeranjang(produk),
                tooltip: 'Tambah ke keranjang',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(SembakoModel produk) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(produk: produk),
      ),
    ).then((_) => _loadProduk()); 
  }
}
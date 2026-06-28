// ============================================================
// FILE: lib/screens/products/product_detail_screen.dart
// Deskripsi: Halaman Detail Produk Menggunakan Video & Audio Lokal
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../constants/app_colors.dart';
import '../../database/database_helper.dart';
import '../../models/sembako_model.dart';
import '../../services/app_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final SembakoModel produk;

  const ProductDetailScreen({super.key, required this.produk});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late SembakoModel _produk;
  int _jumlahBeli = 1;

  // ---- State / Controller Multimedia Lokal ----
  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isVideoInitialized = false;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _produk = widget.produk;
    _inisialisasiMultimediaLokal();
  }

  // ---- PROSES INISIALISASI VIDEO & AUDIO ASSETS ----
  void _inisialisasiMultimediaLokal() {
    // 1. Mengambil video dari assets/video/beras.mp4
    _videoController = VideoPlayerController.asset('assets/video/beras.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      }).catchError((error) {
        print("Gagal memuat video lokal beras.mp4: $error");
      });

    // 2. Monitoring status player audio (agar UI icon berubah dinamis)
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    // Membersihkan memory controller agar HP tidak lag/berat ketika keluar halaman
    _videoController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatHarga(double harga) {
    return 'Rp ${harga.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  Future<void> _tambahKeKeranjang() async {
    if (_produk.stok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maaf, stok produk ini sedang habis!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final bool berhasil = await context.read<CartProvider>().addToCart(_produk, jumlah: _jumlahBeli);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_produk.icon} ${_produk.nama} ditambahkan ke keranjang!'),
        backgroundColor: berhasil ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar Banner Gambar Atas (Dinamis jika ada gambarnya)
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary.withOpacity(0.1),
                child: Center(
                  child: Text(_produk.icon, style: const TextStyle(fontSize: 90)),
                ),
              ),
              title: Text(
                _produk.nama,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),

          // Area Konten Detail Produk
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sektor Harga & Info Stok
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatHarga(_produk.harga),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Stok: ${_produk.stok} ${_produk.satuan}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Chip(
                    label: Text(_produk.kategori),
                    avatar: Text(_produk.icon),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const Divider(height: 30),

                  // Sektor Deskripsi
                  const Text('Deskripsi Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _produk.deskripsi.isNotEmpty ? _produk.deskripsi : 'Produk sembako pilihan berkualitas tinggi untuk kebutuhan keluarga Anda.',
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                  ),
                  
                  const Divider(height: 40),

                  // ==========================================
                  // AREA MULTIMEDIA LOKAL (SUDAH AKTIF)
                  // ==========================================
                  Row(
                    children: [
                      Icon(Icons.video_collection_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Media & Edukasi Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        // --- INTEGRASI PEMUTAR VIDEO LOKAL ---
                        _isVideoInitialized
                            ? Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: AspectRatio(
                                      aspectRatio: _videoController!.value.aspectRatio,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          VideoPlayer(_videoController!),
                                          VideoProgressIndicator(_videoController!, allowScrubbing: true),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: IconButton(
                                      icon: Icon(
                                        _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: AppColors.primary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      SizedBox(height: 8),
                                      Text('Memuat video beras...', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(),
                        ),

                        // --- INTEGRASI PEMUTAR AUDIO LOKAL ---
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade50,
                            child: Icon(_isAudioPlaying ? Icons.music_video : Icons.music_note, color: Colors.orange),
                          ),
                          title: const Text('Jingle PanganTech', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text(_isAudioPlaying ? 'Sedang memutar audio...' : 'Ketuk play untuk mendengarkan jingle', style: const TextStyle(fontSize: 12)),
                          trailing: IconButton(
                            icon: Icon(_isAudioPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 36, color: Colors.orange),
                            onPressed: () async {
                              if (_isAudioPlaying) {
                                await _audioPlayer.pause();
                              } else {
                                // Memuat audio lokal dari assets. 'assets/' tidak perlu ditulis ulang di AssetSource
                                await _audioPlayer.play(AssetSource('audio/jingle.mp3'));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing bawah agar tidak tertutup bottom bar
                ],
              ),
            ),
          )
        ],
      ),
      
      // Bottom Navigation Bar - Pembelian & Stepper Jumlah
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: Row(
          children: [
            // Kontrol Jumlah Beli (Stepper)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline), 
                  onPressed: () => setState(() { if (_jumlahBeli > 1) _jumlahBeli--; })
                ),
                Text('$_jumlahBeli', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline), 
                  onPressed: () => setState(() { if (_jumlahBeli < _produk.stok) _jumlahBeli++; })
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Tombol Add To Cart
            Expanded(
              child: ElevatedButton(
                onPressed: _produk.stok > 0 ? _tambahKeKeranjang : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Tambah ke Keranjang • ${_formatHarga(_produk.harga * _jumlahBeli)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
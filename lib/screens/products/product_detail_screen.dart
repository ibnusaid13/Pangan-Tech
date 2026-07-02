// ============================================================
// FILE: lib/screens/products/product_detail_screen.dart
// Deskripsi: Layar detail produk sembako dengan video pemutar lokal 
//            & tombol kontrol backsound jingle.mp3 di bawah video
// ============================================================

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart'; // Import untuk backsound mp3
import 'package:pangantech/models/sembako_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final SembakoModel produk;
  const ProductDetailScreen({Key? key, required this.produk}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Controller Pemutar Video
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // Controller Pemutar Audio Backsound
  late AudioPlayer _audioPlayer;
  bool _isAudioPlaying = false; // Status audio (mulai dengan false agar tidak langsung nyala)

  @override
  void initState() {
    super.initState();
    _inisialisasiAudioJingle(); // Siapkan backsound mp3
    _inisialisasiMultimediaLokal(); // Jalankan video player
  }

  // --- INISIALISASI AUDIO JINGLE ---
  void _inisialisasiAudioJingle() async {
    _audioPlayer = AudioPlayer();
    // Mengatur musik agar berputar terus-menerus (looping) saat dimainkan
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Set sumber audio dari assets, tetapi jangan panggil .play() di sini
    // agar audio tidak otomatis menyala saat masuk halaman
    await _audioPlayer.setSource(AssetSource('audio/jingle.mp3'));
  }

  void _inisialisasiMultimediaLokal() {
    _loadDefaultVideo();
  }

  void _loadDefaultVideo() {
    if (_videoController != null) {
      _videoController!.dispose();
      _isVideoInitialized = false;
    }

    _videoController = VideoPlayerController.asset('assets/video/beras.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      }).catchError((e) {
        debugPrint("Video default pun gagal dimuat: $e");
      });
  }

  String _formatHarga(double harga) {
    return 'Rp ${harga.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  @override
  void dispose() {
    // Matikan dan hapus instansiasi audio player saat pindah halaman
    _audioPlayer.stop();
    _audioPlayer.dispose();

    if (_videoController != null) {
      _videoController!.pause();
      _videoController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produk.nama),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. BANNER VIDEO PLAYER ---
            Container(
              height: 200,
              color: Colors.grey[300],
              child: _isVideoInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(_videoController!),
                          VideoProgressIndicator(_videoController!, allowScrubbing: true),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: Icon(
                                  _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _videoController!.value.isPlaying
                                        ? _videoController!.pause()
                                        : _videoController!.play();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(child: Icon(Icons.video_library, size: 50, color: Colors.grey)),
            ),

            // --- 2. TOMBOL KONTROL BACKSOUND JINGLE (BERADA TEPAT DI BAWAH VIDEO) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.green.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.music_note, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      const Text(
                        "Backsound Jingle",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAudioPlaying ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(_isAudioPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isAudioPlaying ? "Pause Audio" : "Play Audio"),
                    onPressed: () async {
                      if (_isAudioPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.resume();
                      }
                      setState(() {
                        _isAudioPlaying = !_isAudioPlaying;
                      });
                    },
                  ),
                ],
              ),
            ),

            // --- 3. DETAIL KONTEN INFORMASI PRODUK ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.produk.icon} ${widget.produk.nama}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.produk.kategori,
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatHarga(widget.produk.harga),
                    style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Stok: ${widget.produk.stok} ${widget.produk.satuan}"),
                  const SizedBox(height: 16),
                  const Text(
                    "Deskripsi Produk",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.produk.deskripsi.isEmpty ? "Tidak ada deskripsi." : widget.produk.deskripsi,
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
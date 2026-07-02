// ============================================================
// FILE: lib/models/sembako_model.dart
// Deskripsi: Model data untuk produk sembako (MVC - Model Layer)
//            Merepresentasikan struktur data 1 produk sembako
// ============================================================

class SembakoModel {
  // --- Properti data produk ---
  final int? id;           // ID unik produk (nullable karena auto-increment SQLite)
  final String nama;       // Nama produk, contoh: "Beras Premium"
  final String kategori;   // Kategori: Beras, Minyak, Gula, dll.
  final double harga;      // Harga per satuan dalam Rupiah
  final int stok;          // Jumlah stok tersedia
  final String satuan;     // Satuan ukuran: kg, liter, butir, dll.
  final String deskripsi;  // Deskripsi lengkap produk
  final String imageUrl;   // URL gambar produk (dari network)
  final String icon;       // Emoji icon untuk representasi cepat

  // --- Constructor (PERBAIKAN: Menghapus required pada properti opsional & memberi nilai default) ---
  const SembakoModel({
    this.id,
    required this.nama,
    this.kategori = 'Umum',
    required this.harga,
    this.stok = 0,
    this.satuan = 'pcs',
    this.deskripsi = '',
    this.imageUrl = '',
    this.icon = '🛒',
  });

  // --- Konversi dari Map (PERBAIKAN: Ditambahkan null-safety/handling jika data DB kosong) ---
  factory SembakoModel.fromMap(Map<String, dynamic> map) {
    return SembakoModel(
      id: map['id'] as int?,
      nama: map['nama'] as String? ?? '',
      kategori: map['kategori'] as String? ?? 'Umum',
      harga: (map['harga'] as num?)?.toDouble() ?? 0.0,
      stok: map['stok'] as int? ?? 0,
      satuan: map['satuan'] as String? ?? 'pcs',
      deskripsi: map['deskripsi'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      icon: map['icon'] as String? ?? '🛒',
    );
  }

  // --- Konversi dari JSON API (respons REST API → Object Dart) ---
  factory SembakoModel.fromJson(Map<String, dynamic> json) {
    return SembakoModel(
      id: json['id'] as int?,
      nama: json['nama'] ?? json['title'] ?? '',
      kategori: json['kategori'] ?? 'Umum',
      harga: double.tryParse(json['harga']?.toString() ?? '0') ?? 0.0,
      stok: int.tryParse(json['stok']?.toString() ?? '0') ?? 0,
      satuan: json['satuan'] ?? 'pcs',
      deskripsi: json['deskripsi'] ?? json['body'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      icon: json['icon'] ?? '🛒',
    );
  }

  // --- Konversi Object Dart → Map (untuk INSERT/UPDATE ke SQLite) ---
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,  // Jangan sertakan id jika null (auto-increment)
      'nama': nama,
      'kategori': kategori,
      'harga': harga,
      'stok': stok,
      'satuan': satuan,
      'deskripsi': deskripsi,
      'imageUrl': imageUrl,
      'icon': icon,
    };
  }

  // --- copyWith: Membuat salinan objek dengan nilai yang diubah ---
  SembakoModel copyWith({
    int? id,
    String? nama,
    String? kategori,
    double? harga,
    int? stok,
    String? satuan,
    String? deskripsi,
    String? imageUrl,
    String? icon,
  }) {
    return SembakoModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      kategori: kategori ?? this.kategori,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      satuan: satuan ?? this.satuan,
      deskripsi: deskripsi ?? this.deskripsi,
      imageUrl: imageUrl ?? this.imageUrl,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() {
    return 'SembakoModel(id: $id, nama: $nama, harga: $harga, stok: $stok)';
  }
}


// ============================================================
// MODEL KERANJANG BELANJA (Cart Item)
// ============================================================
class CartItemModel {
  final int? id;             // ID item di tabel keranjang
  final int sembakoId;       // Referensi ke ID produk sembako
  final String namaProduk;   // Nama produk (disalin agar tidak null jika produk dihapus)
  final double hargaSatuan;  // Harga per satuan saat ditambahkan ke keranjang
  int jumlah;                // Jumlah yang dipesan (tidak final karena bisa diubah)
  final String icon;         // Icon produk

  CartItemModel({
    this.id,
    required this.sembakoId,
    required this.namaProduk,
    required this.hargaSatuan,
    required this.jumlah,
    this.icon = '🛒',        // Diubah menjadi opsional dengan nilai default
  });

  // --- Total harga untuk item ini ---
  double get totalHarga => hargaSatuan * jumlah;

  // --- Format harga dalam Rupiah ---
  String get hargaFormatted => 'Rp ${hargaSatuan.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  )}';

  String get totalHargaFormatted => 'Rp ${totalHarga.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  )}';

  // --- Konversi dari Map SQLite ---
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] as int?,
      sembakoId: map['sembakoId'] as int,
      namaProduk: map['namaProduk'] as String? ?? '',
      hargaSatuan: (map['hargaSatuan'] as num?)?.toDouble() ?? 0.0,
      jumlah: map['jumlah'] as int? ?? 1,
      icon: map['icon'] as String? ?? '🛒',
    );
  }

  // --- Konversi ke Map untuk SQLite ---
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sembakoId': sembakoId,
      'namaProduk': namaProduk,
      'hargaSatuan': hargaSatuan,
      'jumlah': jumlah,
      'icon': icon,
    };
  }
}
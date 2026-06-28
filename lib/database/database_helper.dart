// ============================================================
// FILE: lib/database/database_helper.dart
// Deskripsi: Database Helper menggunakan SQLite (sqflite)
//            Mengelola semua operasi CRUD untuk data lokal
// ============================================================

import 'package:sqflite/sqflite.dart'; // Package SQLite untuk Flutter
import 'package:path/path.dart';       // Helper untuk mendapatkan path file
import '../models/sembako_model.dart';

class DatabaseHelper {
  // --- Singleton Pattern ---
  // Memastikan hanya ada 1 instance DatabaseHelper di seluruh aplikasi
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // --- Variabel Database ---
  static Database? _database; // Nullable karena belum tentu sudah diinisialisasi

  // --- Getter database (lazy initialization) ---
  // Database baru dibuat/dibuka pertama kali saat diakses
  Future<Database> get database async {
    if (_database != null) return _database!; // Jika sudah ada, langsung return
    _database = await _initDatabase();         // Jika belum, inisialisasi dulu
    return _database!;
  }

  // --- Nama dan versi database ---
  static const String _dbName = 'pangantech.db';
  static const int _dbVersion = 1;

  // --- Nama tabel ---
  static const String tableSembako = 'sembako';
  static const String tableKeranjang = 'keranjang';

  // ========================
  // INISIALISASI DATABASE
  // ========================
  Future<Database> _initDatabase() async {
    // Mendapatkan path direktori penyimpanan database di device
    final String dbPath = await getDatabasesPath();

    // Menggabungkan path direktori dengan nama file database
    final String path = join(dbPath, _dbName);

    // Membuka atau membuat database baru
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,      // Dipanggil saat database pertama kali dibuat
      onUpgrade: _onUpgrade,    // Dipanggil saat versi database ditingkatkan
    );
  }

  // ========================
  // BUAT TABEL (CREATE TABLE)
  // Dipanggil sekali saat pertama kali install
  // ========================
  Future<void> _onCreate(Database db, int version) async {
    // --- Tabel Produk Sembako ---
    await db.execute('''
      CREATE TABLE $tableSembako (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        nama      TEXT    NOT NULL,
        kategori  TEXT    NOT NULL,
        harga     REAL    NOT NULL,
        stok      INTEGER NOT NULL DEFAULT 0,
        satuan    TEXT    NOT NULL DEFAULT 'pcs',
        deskripsi TEXT,
        imageUrl  TEXT,
        icon      TEXT    DEFAULT '🛒'
      )
    ''');

    // --- Tabel Keranjang Belanja ---
    await db.execute('''
      CREATE TABLE $tableKeranjang (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sembakoId   INTEGER NOT NULL,
        namaProduk  TEXT    NOT NULL,
        hargaSatuan REAL    NOT NULL,
        jumlah      INTEGER NOT NULL DEFAULT 1,
        icon        TEXT    DEFAULT '🛒',
        FOREIGN KEY (sembakoId) REFERENCES $tableSembako (id)
      )
    ''');

    // Isi data awal produk sembako (seed data)
    await _seedData(db);
  }

  // --- Upgrade database jika versi berubah ---
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Strategi sederhana: hapus tabel lama dan buat ulang
    await db.execute('DROP TABLE IF EXISTS $tableKeranjang');
    await db.execute('DROP TABLE IF EXISTS $tableSembako');
    await _onCreate(db, newVersion);
  }

  // ========================
  // DATA AWAL (SEED DATA)
  // Mengisi tabel sembako dengan produk default
  // ========================
  Future<void> _seedData(Database db) async {
    final List<Map<String, dynamic>> produkAwal = [
      {
        'nama': 'Beras Premium 5kg',
        'kategori': 'Beras',
        'harga': 75000.0,
        'stok': 50,
        'satuan': 'karung',
        'deskripsi': 'Beras putih kualitas premium, pulen dan harum. Cocok untuk konsumsi harian keluarga. Dipilih dari petani lokal terbaik.',
        'imageUrl': 'https://picsum.photos/seed/beras/300/300',
        'icon': '🍚',
      },
      {
        'nama': 'Minyak Goreng 2L',
        'kategori': 'Minyak',
        'harga': 38000.0,
        'stok': 30,
        'satuan': 'botol',
        'deskripsi': 'Minyak goreng sawit pilihan, jernih dan bebas kotoran. Aman untuk menggoreng dan menumis berbagai masakan.',
        'imageUrl': 'https://picsum.photos/seed/minyak/300/300',
        'icon': '🫙',
      },
      {
        'nama': 'Gula Pasir 1kg',
        'kategori': 'Gula',
        'harga': 18000.0,
        'stok': 100,
        'satuan': 'kg',
        'deskripsi': 'Gula pasir putih berkualitas, butiran halus dan bersih. Ideal untuk minuman, kue, dan masakan sehari-hari.',
        'imageUrl': 'https://picsum.photos/seed/gula/300/300',
        'icon': '🧂',
      },
      {
        'nama': 'Telur Ayam 1 Kg',
        'kategori': 'Telur',
        'harga': 28000.0,
        'stok': 200,
        'satuan': 'kg',
        'deskripsi': 'Telur ayam kampung segar pilihan. Kaya protein dan nutrisi, langsung dari peternak lokal terpercaya.',
        'imageUrl': 'https://picsum.photos/seed/telur/300/300',
        'icon': '🥚',
      },
      {
        'nama': 'Tepung Terigu 1kg',
        'kategori': 'Tepung',
        'harga': 14000.0,
        'stok': 75,
        'satuan': 'kg',
        'deskripsi': 'Tepung terigu serbaguna protein sedang. Cocok untuk membuat kue, roti, gorengan, dan berbagai olahan kuliner.',
        'imageUrl': 'https://picsum.photos/seed/tepung/300/300',
        'icon': '🌾',
      },
      {
        'nama': 'Garam Dapur 500g',
        'kategori': 'Bumbu',
        'harga': 5000.0,
        'stok': 150,
        'satuan': 'bungkus',
        'deskripsi': 'Garam dapur beryodium, telah memenuhi standar kesehatan nasional. Penting untuk kesehatan dan kebutuhan memasak.',
        'imageUrl': 'https://picsum.photos/seed/garam/300/300',
        'icon': '🧂',
      },
      {
        'nama': 'Kecap Manis 275ml',
        'kategori': 'Bumbu',
        'harga': 12000.0,
        'stok': 60,
        'satuan': 'botol',
        'deskripsi': 'Kecap manis pekat berkualitas tinggi. Aroma khas dan rasa autentik untuk memperkaya cita rasa masakan Indonesia.',
        'imageUrl': 'https://picsum.photos/seed/kecap/300/300',
        'icon': '🍶',
      },
      {
        'nama': 'Mie Instan',
        'kategori': 'Mie',
        'harga': 3500.0,
        'stok': 500,
        'satuan': 'bungkus',
        'deskripsi': 'Mie instan dengan berbagai pilihan rasa. Praktis, lezat, dan mudah disajikan. Pilihan makan cepat favorit keluarga.',
        'imageUrl': 'https://picsum.photos/seed/mie/300/300',
        'icon': '🍜',
      },
    ];

    // Insert semua produk awal ke database menggunakan batch untuk efisiensi
    final Batch batch = db.batch();
    for (final produk in produkAwal) {
      batch.insert(tableSembako, produk);
    }
    await batch.commit(noResult: true); // noResult: true agar tidak return list ID
  }

  // ========================================================
  //   CRUD OPERASI: TABEL SEMBAKO
  // ========================================================

  // --- CREATE: Tambah produk sembako baru ---
  Future<int> insertSembako(SembakoModel sembako) async {
    final Database db = await database;
    // insert() mengembalikan ID baris yang baru dimasukkan
    return await db.insert(
      tableSembako,
      sembako.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Ganti jika ID sudah ada
    );
  }

  // --- READ: Ambil semua produk sembako ---
  Future<List<SembakoModel>> getAllSembako() async {
    final Database db = await database;
    // query() mengembalikan List<Map<String, dynamic>>
    final List<Map<String, dynamic>> maps = await db.query(
      tableSembako,
      orderBy: 'nama ASC', // Urutkan berdasarkan nama A-Z
    );
    // Konversi setiap Map menjadi SembakoModel menggunakan factory constructor
    return maps.map((map) => SembakoModel.fromMap(map)).toList();
  }

  // --- READ: Ambil produk berdasarkan kategori ---
  Future<List<SembakoModel>> getSembakoByKategori(String kategori) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSembako,
      where: 'kategori = ?',       // Kondisi WHERE
      whereArgs: [kategori],        // Nilai yang aman dari SQL injection
    );
    return maps.map((map) => SembakoModel.fromMap(map)).toList();
  }

  // --- READ: Cari produk berdasarkan nama (LIKE query) ---
  Future<List<SembakoModel>> searchSembako(String keyword) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSembako,
      where: 'nama LIKE ? OR kategori LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'], // % adalah wildcard di SQL
    );
    return maps.map((map) => SembakoModel.fromMap(map)).toList();
  }

  // --- READ: Ambil 1 produk berdasarkan ID ---
  Future<SembakoModel?> getSembakoById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSembako,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1, // Hanya ambil 1 baris
    );
    if (maps.isEmpty) return null; // Return null jika tidak ditemukan
    return SembakoModel.fromMap(maps.first);
  }

  // --- UPDATE: Perbarui data produk sembako ---
  Future<int> updateSembako(SembakoModel sembako) async {
    final Database db = await database;
    // update() mengembalikan jumlah baris yang berhasil diperbarui
    return await db.update(
      tableSembako,
      sembako.toMap(),
      where: 'id = ?',
      whereArgs: [sembako.id],
    );
  }

  // --- UPDATE: Hanya perbarui stok produk ---
  Future<int> updateStok(int id, int stokBaru) async {
    final Database db = await database;
    return await db.update(
      tableSembako,
      {'stok': stokBaru},  // Hanya update kolom stok
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- DELETE: Hapus produk berdasarkan ID ---
  Future<int> deleteSembako(int id) async {
    final Database db = await database;
    // delete() mengembalikan jumlah baris yang dihapus
    return await db.delete(
      tableSembako,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========================================================
  //   CRUD OPERASI: TABEL KERANJANG BELANJA
  // ========================================================

  // --- CREATE: Tambah item ke keranjang ---
  Future<int> addToCart(CartItemModel item) async {
    final Database db = await database;

    // Cek apakah produk sudah ada di keranjang
    final List<Map<String, dynamic>> existing = await db.query(
      tableKeranjang,
      where: 'sembakoId = ?',
      whereArgs: [item.sembakoId],
    );

    if (existing.isNotEmpty) {
      // Jika sudah ada: tambahkan jumlahnya
      final int jumlahSekarang = existing.first['jumlah'] as int;
      return await db.update(
        tableKeranjang,
        {'jumlah': jumlahSekarang + item.jumlah},
        where: 'sembakoId = ?',
        whereArgs: [item.sembakoId],
      );
    } else {
      // Jika belum ada: insert baru
      return await db.insert(tableKeranjang, item.toMap());
    }
  }

  // --- READ: Ambil semua item di keranjang ---
  Future<List<CartItemModel>> getCartItems() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableKeranjang);
    return maps.map((map) => CartItemModel.fromMap(map)).toList();
  }

  // --- READ: Hitung total item di keranjang (untuk badge notifikasi) ---
  Future<int> getCartCount() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(jumlah) as total FROM $tableKeranjang',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  // --- READ: Hitung total harga keranjang ---
  Future<double> getCartTotal() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(hargaSatuan * jumlah) as total FROM $tableKeranjang',
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  // --- UPDATE: Ubah jumlah item di keranjang ---
  Future<int> updateCartItemJumlah(int id, int jumlahBaru) async {
    final Database db = await database;
    if (jumlahBaru <= 0) {
      // Jika jumlah 0 atau kurang, hapus item dari keranjang
      return await db.delete(tableKeranjang, where: 'id = ?', whereArgs: [id]);
    }
    return await db.update(
      tableKeranjang,
      {'jumlah': jumlahBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- DELETE: Hapus satu item dari keranjang ---
  Future<int> removeFromCart(int id) async {
    final Database db = await database;
    return await db.delete(
      tableKeranjang,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- DELETE: Kosongkan semua isi keranjang ---
  Future<int> clearCart() async {
    final Database db = await database;
    return await db.delete(tableKeranjang); // Tanpa WHERE = hapus semua baris
  }

  // ========================
  // UTILITAS
  // ========================

  // --- Tutup koneksi database ---
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // --- Reset database (untuk keperluan testing) ---
  Future<void> resetDatabase() async {
    final Database db = await database;
    await db.delete(tableKeranjang);
    await db.delete(tableSembako);
    await _seedData(db);
  }
}
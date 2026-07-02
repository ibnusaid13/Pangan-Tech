// ============================================================
// FILE: lib/database/database_helper.dart
// Deskripsi: Database Helper menggunakan SQLite (sqflite)
//            Mengelola data produk Sembako, Keranjang Belanja,
//            dan Dompet Digital PanganPay (Saldo & Transaksi).
// ============================================================

import 'package:sqflite/sqflite.dart'; // Package SQLite untuk Flutter
import 'package:path/path.dart';       // Helper untuk mendapatkan path file
import '../models/sembako_model.dart'; // Memuat SembakoModel dan CartItemModel

class DatabaseHelper {
  // --- Singleton Pattern ---
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // --- Variabel Database ---
  static Database? _database;

  // --- Getter database (lazy initialization) ---
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // --- Nama dan versi database ---
  static const String _dbName = 'pangantech.db';
  // PERBAIKAN: Naik ke versi 3 untuk mendukung fitur tabel Saldo PanganPay
  static const int _dbVersion = 3;

  // --- Nama tabel ---
  static const String tableSembako = 'sembako';
  static const String tableKeranjang = 'keranjang';
  static const String tablePanganPay = 'panganpay'; // Tabel Baru PanganPay

  // ========================
  // INISIALISASI DATABASE
  // ========================
  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ========================
  // BUAT TABEL (CREATE TABLE)
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

    // --- Tabel Dompet Digital PanganPay ---
    await db.execute('''
      CREATE TABLE $tablePanganPay (
        id    INTEGER PRIMARY KEY AUTOINCREMENT,
        saldo REAL    NOT NULL DEFAULT 0.0
      )
    ''');

    // Isi data awal produk sembako (seed data)
    await _seedData(db);

    // Isi saldo default awal Rp 0 saat database dibuat pertama kali
    await db.insert(tablePanganPay, {'id': 1, 'saldo': 0.0});
  }

  // ============================
  // UPGRADE SCHEMA & SINKRONISASI
  // ============================
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrasi jika pengguna datang dari versi lama di bawah versi 3
    if (oldVersion < 3) {
      // Pastikan tabel PanganPay terbuat secara aman
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tablePanganPay (
          id    INTEGER PRIMARY KEY AUTOINCREMENT,
          saldo REAL    NOT NULL DEFAULT 0.0
        )
      ''');
      
      // Validasi record row saldo ID 1 agar siap digunakan
      List<Map<String, dynamic>> res = await db.query(tablePanganPay, where: 'id = ?', whereArgs: [1]);
      if (res.isEmpty) {
        await db.insert(tablePanganPay, {'id': 1, 'saldo': 0.0});
      }
    }
  }

  // ========================
  // DATA AWAL (SEED DATA)
  // ========================
  Future<void> _seedData(Database db) async {
    final List<Map<String, dynamic>> produkAwal = [
      {
        'id': 1,
        'nama': 'Beras Premium Kaura 5kg',
        'harga': 72000.0,
        'icon': '🌾',
        'stok': 20,
        'kategori': 'Beras',
        'satuan': 'kg',
        'deskripsi': 'Beras putih pulen kualitas premium, bersih dan bebas pemutih.',
        'imageUrl': '',
      },
      {
        'id': 2,
        'nama': 'Minyak Goreng Sania 2L',
        'harga': 38500.0,
        'icon': '🧪',
        'stok': 15,
        'kategori': 'Minyak',
        'satuan': 'Pcs',
        'deskripsi': 'Minyak goreng kelapa sawit berkualitas, menghasilkan gorengan renyah.',
        'imageUrl': '',
      },
      {
        'id': 3,
        'nama': 'Telur Ayam Negeri 1kg',
        'harga': 28000.0,
        'icon': '🥚',
        'stok': 30,
        'kategori': 'Telur',
        'satuan': 'kg',
        'deskripsi': 'Telur ayam negeri segar pilihan langsung dari peternakan.',
        'imageUrl': '',
      },
      {
        'id': 4,
        'nama': 'Gula Pasir Gulaku 1kg',
        'harga': 18000.0,
        'icon': '🍬',
        'stok': 25,
        'kategori': 'Gula',
        'satuan': 'kg',
        'deskripsi': 'Gula pasir murni tebu pilihan, manis alami dan bersih.',
        'imageUrl': '',
      },
      {
        'id': 5,
        'nama': 'Mi Instan Indomie Soto',
        'harga': 3100.0,
        'icon': '🍜',
        'stok': 100,
        'kategori': 'Mi Instan',
        'satuan': 'Pcs',
        'deskripsi': 'Mi instan kuah rasa soto mie yang gurih dan lezat dengan bumbu rempah asli.',
        'imageUrl': '',
      },
      {
        'id': 6,
        'nama': 'Tepung Terigu Segitiga Biru',
        'harga': 14500.0,
        'icon': '🥡',
        'stok': 40,
        'kategori': 'Tepung',
        'satuan': 'kg',
        'deskripsi': 'Tepung terigu serbaguna protein sedang, cocok untuk aneka kue dan gorengan.',
        'imageUrl': '',
      },
      {
        'id': 7,
        'nama': 'Beras Merah Organik 1kg',
        'harga': 32000.0,
        'icon': '🌾',
        'stok': 12,
        'kategori': 'Beras',
        'satuan': 'kg',
        'deskripsi': 'Beras merah kaya serat, sangat baik untuk kesehatan dan diet seimbang.',
        'imageUrl': '',
      },
      {
        'id': 8,
        'nama': 'Minyak Goreng Filma 1L',
        'harga': 19800.0,
        'icon': '🧪',
        'stok': 22,
        'kategori': 'Minyak',
        'satuan': 'Pcs',
        'deskripsi': 'Minyak goreng non-kolesterol, jernih dan terbuat dari kelapa sawit pilihan.',
        'imageUrl': '',
      },
      {
        'id': 9,
        'nama': 'Bawang Merah Brebes 500g',
        'harga': 21000.0,
        'icon': '🧅',
        'stok': 18,
        'kategori': 'Bumbu',
        'satuan': 'Pack',
        'deskripsi': 'Bawang merah Brebes asli, aroma kuat, segar, dan kering sempurna.',
        'imageUrl': '',
      },
      {
        'id': 10,
        'nama': 'Cabai Merah Keriting 250g',
        'harga': 15000.0,
        'icon': '🌶️',
        'stok': 15,
        'kategori': 'Bumbu',
        'satuan': 'Pack',
        'deskripsi': 'Cabai merah keriting segar, dipetik langsung dari petani lokal.',
        'imageUrl': '',
      },
      {
        'id': 11,
        'nama': 'Kecap Manis Bango 520ml',
        'harga': 24000.0,
        'icon': '🍾',
        'stok': 35,
        'kategori': 'Bumbu',
        'satuan': 'Pcs',
        'deskripsi': 'Kecap manis legendaris dari kedelai hitam pilihan berkualitas tinggi.',
        'imageUrl': '',
      },
      {
        'id': 12,
        'nama': 'Susu UHT Full Cream 1L',
        'harga': 18500.0,
        'icon': '🥛',
        'stok': 40,
        'kategori': 'Susu',
        'satuan': 'Pcs',
        'deskripsi': 'Susu cair segar siap minum kaya kalsium dan vitamin.',
        'imageUrl': '',
      },
      {
        'id': 13,
        'nama': 'Garam Dapur Beriodium 250g',
        'harga': 3500.0,
        'icon': '🧂',
        'stok': 60,
        'kategori': 'Bumbu',
        'satuan': 'Pcs',
        'deskripsi': 'Garam halus gurih beriodium untuk melengkapi kebutuhan nutrisi harian.',
        'imageUrl': '',
      },
      
      // === TAMBAHAN PRODUK BARU ===
      {
        'id': 14,
        'nama': 'Beras Merah Organik 2kg',
        'harga': 38000.0,
        'icon': '🌾',
        'stok': 25,
        'kategori': 'Beras',
        'satuan': 'karung',
        'deskripsi': 'Beras merah organik pilihan, berserat tinggi, sangat baik untuk diet dan kesehatan.',
        'imageUrl': '',
      },
      {
        'id': 15,
        'nama': 'Minyak Kelapa Murni 1L',
        'harga': 42000.0,
        'icon': '🧪',
        'stok': 15,
        'kategori': 'Minyak',
        'satuan': 'botol',
        'deskripsi': 'Minyak kelapa murni tanpa proses kimia, sehat untuk menggoreng makanan keluarga.',
        'imageUrl': '',
      },
      {
        'id': 16,
        'nama': 'Gula Merah Aren 1kg',
        'harga': 22000.0,
        'icon': '🍬',
        'stok': 40,
        'kategori': 'Gula',
        'satuan': 'kg',
        'deskripsi': 'Gula aren asli premium cetak manis alami, cocok sebagai bahan pelengkap masakan.',
        'imageUrl': '',
      },
      {
        'id': 17,
        'nama': 'Telur Bebek Asin 1 Pack',
        'harga': 25000.0,
        'icon': '🥚',
        'stok': 20,
        'kategori': 'Telur',
        'satuan': 'pack',
        'deskripsi': 'Telur bebek asin premium isi 6 butir, rasa gurih bertekstur masir lezat.',
        'imageUrl': '',
      },
      {
        'id': 18,
        'nama': 'Cabai Rawit Merah 250g',
        'harga': 15000.0,
        'icon': '🌶️',
        'stok': 35,
        'kategori': 'Bumbu',
        'satuan': 'pack',
        'deskripsi': 'Cabai rawit merah segar pilihan petani lokal, dijamin super pedas alami.',
        'imageUrl': '',
      },
      {
        'id': 19,
        'nama': 'Susu Kental Manis Frisian Flag',
        'harga': 12500.0,
        'icon': '🥛',
        'stok': 50,
        'kategori': 'Susu',
        'satuan': 'Pcs',
        'deskripsi': 'Susu kental manis lezat, cocok untuk pelengkap minuman, roti, atau olahan takjil.',
        'imageUrl': '',
      }
    ];

    final Batch batch = db.batch();
    for (final produk in produkAwal) {
      batch.insert(tableSembako, produk);
    }
    await batch.commit(noResult: true);
  }

  // ========================================================
  //   CRUD OPERASI: TABEL SEMBAKO
  // ========================================================

  Future<int> insertSembako(SembakoModel sembako) async {
    final Database db = await database;
    return await db.insert(
      tableSembako,
      sembako.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SembakoModel>> getAllSembako() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSembako,
      orderBy: 'id ASC',
    );
    return maps.map((map) => SembakoModel.fromMap(map)).toList();
  }

  Future<List<SembakoModel>> getSembakoByKategori(String kategori) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSembako,
      where: 'kategori = ?',
      whereArgs: [kategori],
    );
    return maps.map((map) => SembakoModel.fromMap(map)).toList();
  }

  Future<List<SembakoModel>> searchSembako(String keyword) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSembako,
      where: 'nama LIKE ? OR kategori LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return maps.map((map) => SembakoModel.fromMap(map)).toList();
  }

  Future<SembakoModel?> getSembakoById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSembako,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return SembakoModel.fromMap(maps.first);
  }

  Future<int> updateSembako(SembakoModel sembako) async {
    final Database db = await database;
    return await db.update(
      tableSembako,
      sembako.toMap(),
      where: 'id = ?',
      whereArgs: [sembako.id],
    );
  }

  Future<int> updateStok(int id, int stokBaru) async {
    final Database db = await database;
    return await db.update(
      tableSembako,
      {'stok': stokBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSembako(int id) async {
    final Database db = await database;
    return await db.delete(
      tableSembako,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========================================================
  //   CRUD OPERASI: TABEL KERANJANG BELANJA
  // ========================================================

  Future<int> addToCart(CartItemModel item) async {
    final Database db = await database;

    final List<Map<String, dynamic>> existing = await db.query(
      tableKeranjang,
      where: 'sembakoId = ?',
      whereArgs: [item.sembakoId],
    );

    if (existing.isNotEmpty) {
      final int jumlahSekarang = existing.first['jumlah'] as int;
      return await db.update(
        tableKeranjang,
        {'jumlah': jumlahSekarang + item.jumlah},
        where: 'sembakoId = ?',
        whereArgs: [item.sembakoId],
      );
    } else {
      return await db.insert(tableKeranjang, item.toMap());
    }
  }

  Future<List<CartItemModel>> getCartItems() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableKeranjang);
    return maps.map((map) => CartItemModel.fromMap(map)).toList();
  }

  Future<int> getCartCount() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(jumlah) as total FROM $tableKeranjang',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<double> getCartTotal() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(hargaSatuan * jumlah) as total FROM $tableKeranjang',
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<int> updateCartItemJumlah(int id, int jumlahBaru) async {
    final Database db = await database;
    if (jumlahBaru <= 0) {
      return await db.delete(tableKeranjang, where: 'id = ?', whereArgs: [id]);
    }
    return await db.update(
      tableKeranjang,
      {'jumlah': jumlahBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> removeFromCart(int id) async {
    final Database db = await database;
    return await db.delete(
      tableKeranjang,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearCart() async {
    final Database db = await database;
    return await db.delete(tableKeranjang);
  }

  // ========================================================
  //   CRUD OPERASI: PANGANPAY (WALLET SYSTEM)
  // ========================================================

  // Mendapatkan jumlah saldo PanganPay saat ini
  Future<double> getSaldoPanganPay() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tablePanganPay, where: 'id = ?', whereArgs: [1], limit: 1);
    if (maps.isEmpty) {
      await db.insert(tablePanganPay, {'id': 1, 'saldo': 0.0});
      return 0.0;
    }
    return (maps.first['saldo'] as num).toDouble();
  }

  // Melakukan Top Up Saldo Dompet
  Future<int> topUpSaldo(double jumlah) async {
    final Database db = await database;
    double saldoSekarang = await getSaldoPanganPay();
    double saldoBaru = saldoSekarang + jumlah;
    
    return await db.update(
      tablePanganPay,
      {'saldo': saldoBaru},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // Mengurangi Saldo ketika Checkout/Pembayaran sukses
  Future<bool> bayarPakaiPanganPay(double totalBelanja) async {
    final Database db = await database;
    double saldoSekarang = await getSaldoPanganPay();

    if (saldoSekarang < totalBelanja) {
      return false; // Mengembalikan status gagal jika uang kurang
    }

    double saldoBaru = saldoSekarang - totalBelanja;
    await db.update(
      tablePanganPay,
      {'saldo': saldoBaru},
      where: 'id = ?',
      whereArgs: [1],
    );
    return true; // Pengurangan berhasil
  }

  // ========================
  // UTILITAS
  // ========================

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // --- RE-INSTANSIASI DATABASE SECARA FISIK ---
  Future<void> resetDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, _dbName);
    
    await closeDatabase(); // Tutup koneksi stream database aktif
    await deleteDatabase(path); // Hapus total file .db fisik dari emulator
    
    _database = await _initDatabase(); // Bangun ulang struktur tabel dari nol
  }
}
// ============================================================
// FILE: lib/services/app_provider.dart
// Deskripsi: State Management menggunakan Provider pattern
//            Mengelola state global: tema, keranjang + navigasi, user login
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pangantech/database/database_helper.dart';
import 'package:pangantech/models/sembako_model.dart';

// ========================================================
//   THEME PROVIDER: Mengelola mode gelap/terang
// ========================================================
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  // Getter untuk mendapatkan status mode gelap
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs(); // Load preferensi tema saat pertama kali dibuat
  }

  // --- Load tema dari SharedPreferences (persisten) ---
  Future<void> _loadThemeFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false; // Default: light mode
    notifyListeners(); // Beritahu widget yang mendengarkan untuk rebuild
  }

  // --- Toggle antara dark dan light mode ---
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Trigger rebuild semua widget yang listen

    // Simpan preferensi ke storage persisten
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}

// ========================================================
//   CART PROVIDER: Mengelola keranjang belanja & Navigasi
// ========================================================
class CartProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<CartItemModel> _items = [];  // Daftar item di keranjang
  bool _isLoading = false;          // Status loading
  
  // ---- Fitur Navigasi Global Antar Tab ----
  int _selectedIndex = 0; 

  // Getter
  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  int get selectedIndex => _selectedIndex; // Menyediakan index ke BottomNavigationBar

  // Hitung total jumlah produk (bukan jenis)
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.jumlah);

  // Hitung total harga semua item di keranjang
  double get totalHarga => _items.fold(0, (sum, item) => sum + item.totalHarga);

  // Format total harga ke Rupiah
  String get totalHargaFormatted => 'Rp ${totalHarga.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  )}';

  // ---- Fungsi Mengubah Index Tab Navigasi Aktif ----
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners(); // Memicu update tampilan pada MainNavigation / Dashboard Utama
  }

  // --- Muat data keranjang dari SQLite ---
  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _dbHelper.getCartItems();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Tambah item ke keranjang ---
  Future<bool> addToCart(SembakoModel sembako, {int jumlah = 1}) async {
    try {
      final CartItemModel cartItem = CartItemModel(
        sembakoId: sembako.id!,
        namaProduk: sembako.nama,
        hargaSatuan: sembako.harga,
        jumlah: jumlah,
        icon: sembako.icon,
      );

      await _dbHelper.addToCart(cartItem);
      await loadCart(); // Refresh data keranjang
      return true;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return false;
    }
  }

  // --- Perbarui jumlah item ---
  Future<void> updateJumlah(int id, int jumlahBaru) async {
    try {
      await _dbHelper.updateCartItemJumlah(id, jumlahBaru);
      await loadCart();
    } catch (e) {
      debugPrint('Error updating cart: $e');
    }
  }

  // --- Hapus item dari keranjang ---
  Future<void> removeItem(int id) async {
    try {
      await _dbHelper.removeFromCart(id);
      await loadCart();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  // --- Kosongkan seluruh keranjang ---
  Future<void> clearCart() async {
    try {
      await _dbHelper.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
}

// ========================================================
//   AUTH PROVIDER: Mengelola status login pengguna
// ========================================================
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;

  bool get isLoggedIn => _isLoggedIn;
  
  // FIX DI SINI: Getter userData yang sebelumnya error merah
  Map<String, dynamic>? get userData => _userData; 
  
  String get namaUser => _userData?['nama'] ?? 'Pengguna';
  String get usernameUser => _userData?['username'] ?? '';

  // --- Login berhasil: simpan data user ---
  void setLoggedIn(Map<String, dynamic> userData) {
    _isLoggedIn = true;
    _userData = userData;
    notifyListeners();
  }

  // --- Logout: bersihkan data user ---
  void logout() {
    _isLoggedIn = false;
    _userData = null;
    notifyListeners();
  }
}
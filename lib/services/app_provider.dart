// ============================================================
// FILE: lib/services/app_provider.dart
// Deskripsi: State Management menggunakan Provider pattern
//            Mengelola state global: tema, notifikasi, keranjang + navigasi, user login
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pangantech/database/database_helper.dart';
import 'package:pangantech/models/sembako_model.dart';

// ========================================================
//   THEME PROVIDER: Mengelola mode gelap/terang & Notifikasi
// ========================================================
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool _isPromoNotifActive = true;
  bool _isShippingNotifActive = true;

  bool get isDarkMode => _isDarkMode;
  bool get isPromoNotifActive => _isPromoNotifActive;
  bool get isShippingNotifActive => _isShippingNotifActive;

  ThemeProvider() {
    _loadSettingsFromPrefs();
  }

  Future<void> _loadSettingsFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isPromoNotifActive = prefs.getBool('isPromoNotifActive') ?? true;
    _isShippingNotifActive = prefs.getBool('isShippingNotifActive') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> togglePromoNotif() async {
    _isPromoNotifActive = !_isPromoNotifActive;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPromoNotifActive', _isPromoNotifActive);
  }

  Future<void> toggleShippingNotif() async {
    _isShippingNotifActive = !_isShippingNotifActive;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isShippingNotifActive', _isShippingNotifActive);
  }
}

// ========================================================
//   CART PROVIDER: Mengelola keranjang belanja & Navigasi
// ========================================================
class CartProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<CartItemModel> _items = [];  // Daftar item di keranjang
  bool _isLoading = false;          // Status loading
  int _selectedIndex = 0; 
  String _kategoriGlobal = 'Semua';

  // Getter
  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  int get selectedIndex => _selectedIndex; 
  String get kategoriGlobal => _kategoriGlobal; 

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.jumlah);
  double get totalHarga => _items.fold(0, (sum, item) => sum + item.totalHarga);

  String get totalHargaFormatted => 'Rp ${totalHarga.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  )}';

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners(); 
  }

  void setKategoriGlobal(String kategori) {
    _kategoriGlobal = kategori;
    notifyListeners(); 
  }

  // --- PERBAIKAN: Menambahkan fungsi alias 'addItem' agar sinkron dengan dashboard_screen.dart ---
  Future<bool> addItem(SembakoModel sembako, {int jumlah = 1}) async {
    return await addToCart(sembako, jumlah: jumlah);
  }

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
      await loadCart(); 
      return true;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return false;
    }
  }

  Future<void> updateJumlah(int id, int jumlahBaru) async {
    try {
      await _dbHelper.updateCartItemJumlah(id, jumlahBaru);
      await loadCart();
    } catch (e) {
      debugPrint('Error updating cart: $e');
    }
  }

  Future<void> removeItem(int id) async {
    try {
      await _dbHelper.removeFromCart(id);
      await loadCart();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

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
  Map<String, dynamic>? get userData => _userData; 
  
  String get namaUser => _userData?['nama'] ?? 'Pengguna';
  String get usernameUser => _userData?['username'] ?? '';

  void setLoggedIn(Map<String, dynamic> userData) {
    _isLoggedIn = true;
    _userData = userData;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userData = null;
    notifyListeners();
  }
}
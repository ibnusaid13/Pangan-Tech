// ============================================================
// FILE: lib/screens/main_navigation.dart
// Deskripsi: Navigasi utama dengan BottomNavigationBar
//            Mengelola 5 menu utama aplikasi PanganTech
//            Terintegrasi dengan State Navigasi CartProvider
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../constants/app_colors.dart';
import 'dashboard/dashboard_screen.dart';
import 'products/product_screen.dart'; // Memuat ProductScreen
import 'cart/cart_screen.dart';
import 'package:pangantech/profile/profile_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // --- Daftar halaman untuk setiap tab ---
  // Dibuat sebagai variabel final agar tidak di-rebuild setiap kali index berubah
  final List<Widget> _pages =  [
    DashboardScreen(),    // Tab 0: Dashboard
    ProductScreen(),      // FIX UTAMA: Diubah dari ProductsScreen() menjadi ProductScreen() agar sinkron dengan nama class file-nya
    CartScreen(key: UniqueKey()),         // Tab 2: Keranjang
    ProfileScreen(),      // Tab 3: Profil
    SettingsScreen(),     // Tab 4: Pengaturan
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Ambil jumlah item keranjang dari Provider untuk lencana badge
    final int cartCount = context.watch<CartProvider>().totalQuantity;

    // 2. MENDENGARKAN INDEX AKTIF DARI GLOBAL PROVIDER
    final int selectedIndexFromProvider = context.watch<CartProvider>().selectedIndex;

    return Scaffold(
      // --- Body: tampilkan halaman sesuai index aktif dari Provider ---
      body: IndexedStack(
        index: selectedIndexFromProvider,
        children: _pages,
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndexFromProvider, // Pakai index dari Provider
        onTap: (int index) {
          // UPDATE INDEX KE PROVIDER saat tab di bawah ditekan user secara manual
          context.read<CartProvider>().setSelectedIndex(index);
        },
        type: BottomNavigationBarType.fixed, // Tampilkan semua label
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: [
          // Tab 0: Dashboard
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),

          // Tab 1: Produk (Sembako)
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Sembako',
          ),

          // Tab 2: Keranjang (dengan badge jumlah item)
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cartCount > 0) 
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        cartCount > 99 ? '99+' : '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
                if (cartCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Keranjang',
          ),

          // Tab 3: Profil
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),

          // Tab 4: Pengaturan
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}
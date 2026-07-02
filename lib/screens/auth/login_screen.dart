// ============================================================
// FILE: lib/screens/auth/login_screen.dart
// Deskripsi: Halaman Login - Autentikasi pengguna via API
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/app_provider.dart';
import '../../constants/app_colors.dart';
import '../main_navigation.dart';
import 'register_screen.dart'; // Import halaman register baru

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameCtrl = TextEditingController(text: 'ibnu said');
  final TextEditingController _passwordCtrl = TextEditingController(text: 'ibnu1306');

  bool _isLoading = false;        
  bool _obscurePassword = true;   
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); 

    try {
      final Map<String, dynamic> result = await _apiService.login(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      if (!mounted) return; 

      if (result['success'] == true) {
        context.read<AuthProvider>().setLoggedIn(result['user']);
        await context.read<CartProvider>().loadCart();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false, 
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ---- Header / Logo Section ----
              // ---- Header / Logo Section ----
Container(
  height: 250,
  width: double.infinity,
  color: AppColors.primary,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Logo PanganTech berbentuk LINGKARAN
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle, // <-- MENGUBAH BENTUK MENJADI LINGKARAN
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval( // <-- MEMOTONG GAMBAR AGAR MENGIKUTI BENTUK LINGKARAN
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Sedikit ditambah padding agar logo tetap proporsional di dalam lingkaran
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text('🌾', style: TextStyle(fontSize: 45)),
                );
              },
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'PanganTech',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      const Text(
        'Toko Sembako Modern',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    ],
  ),
),

              // ---- Form Login Section ----
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Masuk ke Akun',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Silakan masukkan credential Anda',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      // --- Input Username ---
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          hintText: 'Masukkan username',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          if (value.length < 4) {
                            return 'Username minimal 4 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // --- Input Password ---
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          hintText: 'Masukkan password',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 4) {
                            return 'Password minimal 4 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // --- Tombol Login ---
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _doLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'MASUK',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- PERBAIKAN: Tombol Navigasi ke Register Screen ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                            child: const Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- Info hint untuk testing ---
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.info.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.info, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Demo: ibnu said & ibnu1306 minimal 4 karakter',
                                style: TextStyle(color: AppColors.info, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
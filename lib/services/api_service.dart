// ============================================================
// FILE: lib/services/api_service.dart
// Deskripsi: Service layer untuk integrasi REST API eksternal
//            Menggunakan package 'http' untuk HTTP requests
//            Mock API menggunakan JSONPlaceholder sebagai dummy
// ============================================================

import 'dart:convert';          // Untuk encode/decode JSON
import 'dart:io';               // Untuk SocketException (no internet)
import 'package:http/http.dart' as http; // Package HTTP client
import '../models/sembako_model.dart';

class ApiService {
  // --- Singleton Pattern ---
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // --- Base URL API ---
  // Menggunakan JSONPlaceholder sebagai mock API untuk simulasi
  // Pada proyek nyata, ganti dengan URL backend Anda
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // --- Timeout durasi request ---
  static const Duration _timeout = Duration(seconds: 10);

  // --- HTTP Headers standar ---
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ========================================================
  //   AUTENTIKASI (LOGIN & REGISTER)
  // ========================================================

  /// Fungsi Login ke API
  /// [username] dan [password] dikirim ke endpoint /posts (simulasi)
  /// Return [Map] berisi data user atau throw [ApiException]
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      // POST request ke endpoint login
      // Catatan: JSONPlaceholder /posts hanya simulasi, bukan autentikasi nyata
      final http.Response response = await http
          .post(
            Uri.parse('$_baseUrl/posts'),
            headers: _headers,
            body: jsonEncode({
              'username': username,
              'password': password,      // Jangan pernah kirim password plain text di produksi!
              'title': 'Login Request',
            }),
          )
          .timeout(_timeout); // Batalkan jika > 10 detik

      // Cek status code HTTP
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Decode JSON response
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Simulasi validasi: username dan password harus minimal 4 karakter
        if (username.length >= 4 && password.length >= 4) {
          // Return data user yang berhasil login (simulasi)
          return {
            'success': true,
            'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
            'user': {
              'id': data['id'],
              'username': username,
              'nama': 'Pengguna PanganTech',
              'role': 'pelanggan',
            },
            'message': 'Login berhasil!',
          };
        } else {
          throw ApiException('Username atau password salah', 401);
        }
      } else {
        throw ApiException('Server error: ${response.statusCode}', response.statusCode);
      }
    } on SocketException {
      // Error ketika tidak ada koneksi internet
      throw ApiException('Tidak ada koneksi internet. Periksa jaringan Anda.', 0);
    } on http.ClientException catch (e) {
      throw ApiException('Gagal terhubung ke server: ${e.message}', 0);
    } catch (e) {
      if (e is ApiException) rethrow; // Lempar ulang ApiException
      throw ApiException('Terjadi kesalahan: $e', 500);
    }
  }

  // ========================================================
  //   FETCH DATA KATALOG SEMBAKO (dari API)
  // ========================================================

  /// Mengambil daftar produk dari API
  /// Menggunakan endpoint /posts sebagai simulasi data katalog
  Future<List<SembakoModel>> fetchKatalogSembako() async {
    try {
      final http.Response response = await http
          .get(
            Uri.parse('$_baseUrl/posts?_limit=8'), // Ambil 8 data saja
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        // Decode array JSON
        final List<dynamic> jsonList = jsonDecode(response.body);

        // Daftar kategori sembako untuk dipetakan ke data mock
        final List<String> kategoriList = ['Beras', 'Minyak', 'Gula', 'Telur', 'Tepung', 'Bumbu', 'Mie', 'Minuman'];
        final List<String> ikonList = ['🍚', '🫙', '🧂', '🥚', '🌾', '🍶', '🍜', '🥤'];
        final List<double> hargaList = [75000, 38000, 18000, 28000, 14000, 12000, 3500, 8000];
        final List<String> satuanList = ['karung', 'botol', 'kg', 'kg', 'kg', 'botol', 'bungkus', 'botol'];

        // Mapping data API ke model SembakoModel
        return jsonList.asMap().entries.map((entry) {
          final int idx = entry.key % kategoriList.length;
          final Map<String, dynamic> json = entry.value;

          return SembakoModel(
            id: json['id'] as int?,
            nama: '${kategoriList[idx]} Premium', // Nama dari kategori
            kategori: kategoriList[idx],
            harga: hargaList[idx],
            stok: 50 + (json['userId'] as int? ?? 0) * 10,
            satuan: satuanList[idx],
            deskripsi: json['body'] as String? ?? 'Produk sembako berkualitas dari PanganTech.',
            imageUrl: 'https://picsum.photos/seed/${json['id']}/300/300',
            icon: ikonList[idx],
          );
        }).toList();
      } else {
        throw ApiException('Gagal mengambil data: ${response.statusCode}', response.statusCode);
      }
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error fetch katalog: $e', 500);
    }
  }

  /// Mengambil detail produk berdasarkan ID dari API
  Future<Map<String, dynamic>> fetchDetailProduk(int id) async {
    try {
      final http.Response response = await http
          .get(Uri.parse('$_baseUrl/posts/$id'), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Produk tidak ditemukan', 404);
      }
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error: $e', 500);
    }
  }
}

// ============================================================
// CUSTOM EXCEPTION untuk penanganan error API yang lebih jelas
// ============================================================
class ApiException implements Exception {
  final String message;   // Pesan error yang readable
  final int statusCode;   // HTTP status code

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
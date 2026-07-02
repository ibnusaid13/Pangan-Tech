// ============================================================
// FILE: lib/screens/chat/chat_screen.dart
// Deskripsi: Layar simulasi chat cerdas layanan pelanggan
// ============================================================

import 'package:flutter/material.dart';
import 'dart:async'; // <-- PERBAIKAN: Ditambahkan agar widget Timer tidak error

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Halo! Selamat datang di layanan simulasi cerdas PanganTech. Ada yang bisa kami bantu hari ini?',
      'isMe': false,
      'time': 'Now',
    }
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userText = _messageController.text.trim().toLowerCase();
    
    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': 'Now',
      });
    });

    _messageController.clear();

    // Jawaban otomatis simulasi cerdas
    Timer(const Duration(milliseconds: 800), () {
      String response = 'Terima kasih telah menghubungi kami. Pertanyaan Anda sedang diteruskan ke agen kami.';
      
      if (userText.contains('ongkir') || userText.contains('gratis')) {
        response = 'Promo gratis ongkir berlaku otomatis se-kota tanpa minimal belanja hingga akhir bulan ini ya kak! 🚚';
      } else if (userText.contains('beras') || userText.contains('diskon')) {
        response = 'Beras Premium hari ini sedang diskon 15%! Buruan checkout langsung lewat dashboard kak 🌾';
      } else if (userText.contains('stok')) {
        response = 'Seluruh stok sembako di aplikasi sinkron langsung dengan gudang utama kami secara real-time.';
      }

      if (mounted) {
        setState(() {
          _messages.add({
            'text': response,
            'isMe': false,
            'time': 'Now',
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulasi Cerdas PanganTech'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg['isMe'] ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg['text']),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
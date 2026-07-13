import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_drawer.dart';

/// Halaman Tentang Aplikasi: info nama aplikasi, anggota kelompok
/// (placeholder, mudah diganti), dan deskripsi singkat.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // TODO: Ganti daftar berikut dengan nama anggota kelompok kalian.
  static const List<Map<String, String>> anggotaKelompok = [
    {'nama': 'Bayu Alamsyah Pabarani', 'nim': 'NIM 60200124099'},
    {'nama': 'Maftuh Ainur Ridho', 'nim': 'NIM 60200124155'},
    {'nama': 'Rizaldy', 'nim': 'NIM 60200124140'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const CustomDrawer(currentRoute: 'about'),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Tentang Aplikasi', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.primary, size: 44),
                ),
                const SizedBox(height: 16),
                const Text('MoniQure',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Versi 1.0.0', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildSection(
            title: 'Deskripsi',
            child: Text(
              'Aplikasi ini merupakan aplikasi pencatatan keuangan sederhana yang dibuat '
              'menggunakan Flutter dan SQLite. Pengguna dapat mencatat pemasukan, pengeluaran, '
              'membuat kategori sendiri, melihat laporan keuangan, serta mengelola transaksi '
              'dengan mudah.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.5, fontSize: 13.5),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Anggota Kelompok',
            child: Column(
              children: anggotaKelompok
                  .map((anggota) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.surface,
                              child: Icon(Icons.person_outline_rounded,
                                  size: 18, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(anggota['nama']!,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                                Text(anggota['nim']!,
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

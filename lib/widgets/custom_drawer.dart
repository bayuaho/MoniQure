import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/kategori/kategori_screen.dart';
import '../screens/transaksi/form_transaksi_screen.dart';
import '../screens/laporan/laporan_screen.dart';
import '../screens/about/about_screen.dart';
import '../utils/app_colors.dart';

/// Drawer navigasi yang tersedia di seluruh halaman utama aplikasi.
/// `currentRoute` dipakai untuk highlight menu yang sedang aktif.
class CustomDrawer extends StatelessWidget {
  final String currentRoute;

  const CustomDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'MoniQure',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Catat keuanganmu dengan mudah',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context,
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              route: 'dashboard',
              page: const DashboardScreen(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.category_rounded,
              label: 'Kategori',
              route: 'kategori',
              page: const KategoriScreen(),
            ),
            // Tambah Transaksi adalah form/aksi, bukan halaman tab sejajar,
            // jadi pakai push biasa (bukan pushReplacement) supaya halaman
            // sebelumnya tetap ada di stack -> tombol back muncul & berfungsi.
            ListTile(
              leading: const Icon(Icons.add_circle_rounded, color: AppColors.textPrimary),
              title: const Text('Tambah Transaksi'),
              onTap: () {
                Navigator.pop(context); // tutup drawer dulu
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FormTransaksiScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.bar_chart_rounded,
              label: 'Laporan',
              route: 'laporan',
              page: const LaporanScreen(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.info_rounded,
              label: 'Tentang',
              route: 'about',
              page: const AboutScreen(),
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: const Text('Logout', style: TextStyle(color: AppColors.danger)),
              onTap: () => _handleLogout(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required Widget page,
  }) {
    final bool isActive = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.primary : AppColors.textPrimary),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.primary.withOpacity(0.08),
      onTap: () {
        Navigator.pop(context); // tutup drawer
        if (!isActive) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => page,
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 250),
            ),
          );
        }
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Tombol Back tidak bisa kembali ke Dashboard setelah logout,
    // karena stack navigasi dibersihkan total (pushAndRemoveUntil).
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
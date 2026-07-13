import 'package:flutter/material.dart';
import '../../models/transaksi_model.dart';
import '../../services/auth_service.dart';
import '../../services/transaksi_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/format_utils.dart';
import '../../utils/icon_helper.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/transaksi_card.dart';
import '../transaksi/form_transaksi_screen.dart';

/// Dashboard: halaman utama aplikasi. Menampilkan greeting, ringkasan
/// keuangan, indikator persentase kategori teratas (animated), dan
/// daftar transaksi terbaru.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _transaksiService = TransaksiService();
  final _authService = AuthService();

  String _username = '';
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  double _saldo = 0;
  int _jumlahTransaksi = 0;
  List<TransaksiModel> _transaksiList = [];
  Map<String, dynamic>? _kategoriTeratas; // kategori pengeluaran terbesar

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final username = await _authService.getLoggedInUsername();
    final userId = await _authService.getLoggedInUserId();
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final totalPemasukan = await _transaksiService.getTotalPemasukan(userId);
    final totalPengeluaran = await _transaksiService.getTotalPengeluaran(userId);
    final saldo = await _transaksiService.getSaldo(userId);
    final jumlah = await _transaksiService.getJumlahTransaksi(userId);
    final transaksiList = await _transaksiService.getAllTransaksi(userId);
    final persentaseKategori = await _transaksiService.getPersentasePengeluaranPerKategori(userId);

    if (!mounted) return;
    setState(() {
      _username = username ?? 'Pengguna';
      _totalPemasukan = totalPemasukan;
      _totalPengeluaran = totalPengeluaran;
      _saldo = saldo;
      _jumlahTransaksi = jumlah;
      _transaksiList = transaksiList;
      _kategoriTeratas = persentaseKategori.isNotEmpty ? persentaseKategori.first : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const CustomDrawer(currentRoute: 'dashboard'),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormTransaksiScreen()),
          );
          if (result == true) _loadData();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 90),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: Text(
                      'Halo, $_username 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildKategoriTeratasCard(),
                  const SizedBox(height: 16),
                  _buildRingkasanCards(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _transaksiList.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _transaksiList.length,
                          itemBuilder: (context, index) {
                            final transaksi = _transaksiList[index];
                            return TransaksiCard(
                              transaksi: transaksi,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormTransaksiScreen(
                                      transaksi: transaksi,
                                    ),
                                  ),
                                );
                                if (result == true) _loadData();
                              },
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildKategoriTeratasCard() {
    final persentase =
        (_kategoriTeratas?['persentase'] as num?)?.toDouble() ?? 0;
    final namaKategori =
        _kategoriTeratas?['nama'] as String? ?? 'Belum ada pengeluaran';
    final iconKategori = _kategoriTeratas?['icon'] as String? ?? 'lainnya';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: persentase / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: value,
                      strokeWidth: 7,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                    Icon(
                      IconHelper.getIcon(iconKategori),
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kategori Pengeluaran Terbesar',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  namaKategori,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: persentase),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '${value.toStringAsFixed(1)}% dari total pengeluaran',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
        children: [
          _miniStat(
            'Pemasukan',
            FormatUtils.rupiah(_totalPemasukan),
            Icons.arrow_downward_rounded,
            AppColors.success,
          ),
          _miniStat(
            'Pengeluaran',
            FormatUtils.rupiah(_totalPengeluaran),
            Icons.arrow_upward_rounded,
            AppColors.danger,
          ),
          _miniStat(
            'Saldo',
            FormatUtils.rupiah(_saldo),
            Icons.account_balance_wallet_rounded,
            AppColors.primary,
          ),
          _miniStat(
            'Transaksi',
            '$_jumlahTransaksi',
            Icons.receipt_long_rounded,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada transaksi',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

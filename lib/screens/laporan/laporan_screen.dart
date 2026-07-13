import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../services/transaksi_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/format_utils.dart';
import '../../utils/icon_helper.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/stat_card.dart';

/// Halaman Laporan: statistik total, rekap per kategori dengan
/// progress indicator berwarna, dan Pie Chart sederhana.
class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _transaksiService = TransaksiService();

  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  double _saldo = 0;
  int _jumlahTransaksi = 0;
  List<Map<String, dynamic>> _persentaseKategori = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final totalPemasukan = await _transaksiService.getTotalPemasukan();
    final totalPengeluaran = await _transaksiService.getTotalPengeluaran();
    final saldo = await _transaksiService.getSaldo();
    final jumlah = await _transaksiService.getJumlahTransaksi();
    final persentase = await _transaksiService.getPersentasePengeluaranPerKategori();

    if (!mounted) return;
    setState(() {
      _totalPemasukan = totalPemasukan;
      _totalPengeluaran = totalPengeluaran;
      _saldo = saldo;
      _jumlahTransaksi = jumlah;
      _persentaseKategori = persentase;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const CustomDrawer(currentRoute: 'laporan'),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Laporan', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      StatCard(
                        label: 'Total Pemasukan',
                        value: FormatUtils.rupiah(_totalPemasukan),
                        icon: Icons.arrow_downward_rounded,
                        color: AppColors.success,
                      ),
                      StatCard(
                        label: 'Total Pengeluaran',
                        value: FormatUtils.rupiah(_totalPengeluaran),
                        icon: Icons.arrow_upward_rounded,
                        color: AppColors.danger,
                      ),
                      StatCard(
                        label: 'Saldo',
                        value: FormatUtils.rupiah(_saldo),
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                      ),
                      StatCard(
                        label: 'Jumlah Transaksi',
                        value: '$_jumlahTransaksi',
                        icon: Icons.receipt_long_rounded,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_persentaseKategori.isNotEmpty) ...[
                    const Text('Distribusi Pengeluaran', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _buildPieChart(),
                    const SizedBox(height: 24),
                    const Text('Rekap per Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ..._persentaseKategori.map(_buildRekapItem),
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.pie_chart_outline_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('Belum ada data pengeluaran',
                                style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 40,
          sections: _persentaseKategori.map((row) {
            final color = ColorUtils.hexToColor(row['warna'] as String);
            final persentase = (row['persentase'] as num).toDouble();
            return PieChartSectionData(
              color: color,
              value: persentase,
              title: '${persentase.toStringAsFixed(0)}%',
              radius: 60,
              titleStyle: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRekapItem(Map<String, dynamic> row) {
    final color = ColorUtils.hexToColor(row['warna'] as String);
    final persentase = (row['persentase'] as num).toDouble();
    final total = (row['total'] as num).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(IconHelper.getIcon(row['icon'] as String), color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(row['nama'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(FormatUtils.rupiah(total),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: persentase / 100),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: color.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text('${persentase.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

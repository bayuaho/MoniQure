import 'package:flutter/material.dart';
import '../models/transaksi_model.dart';
import '../utils/app_colors.dart';
import '../utils/format_utils.dart';
import '../utils/icon_helper.dart';

/// Card modern untuk menampilkan satu transaksi pada ListView.
/// Menampilkan nama kategori, nominal, jenis, tanggal, icon & warna kategori.
class TransaksiCard extends StatelessWidget {
  final TransaksiModel transaksi;
  final VoidCallback onTap;

  const TransaksiCard({super.key, required this.transaksi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPemasukan = transaksi.jenis == JenisTransaksi.pemasukan;
    final kategoriColor = ColorUtils.hexToColor(transaksi.warnaKategori ?? '#6B7280');
    final sign = isPemasukan ? '+' : '-';
    final amountColor = isPemasukan ? AppColors.success : AppColors.danger;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: kategoriColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(IconHelper.getIcon(transaksi.iconKategori ?? 'lainnya'),
                    color: kategoriColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaksi.namaKategori ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      FormatUtils.tanggalPendek(transaksi.tanggal),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    if (transaksi.catatan != null && transaksi.catatan!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          transaksi.catatan!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '$sign${FormatUtils.rupiah(transaksi.nominal)}',
                style: TextStyle(fontWeight: FontWeight.w700, color: amountColor, fontSize: 13.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

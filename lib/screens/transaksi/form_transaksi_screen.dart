import 'package:flutter/material.dart';
import '../../models/kategori_model.dart';
import '../../models/transaksi_model.dart';
import '../../services/kategori_service.dart';
import '../../services/transaksi_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/icon_helper.dart';

/// Form Tambah/Edit Transaksi.
/// Jika `transaksi` null -> mode Tambah Transaksi.
/// Jika `transaksi` terisi -> mode Edit Transaksi (field otomatis terisi,
/// serta muncul tombol Hapus).
class FormTransaksiScreen extends StatefulWidget {
  final TransaksiModel? transaksi;

  const FormTransaksiScreen({super.key, this.transaksi});

  @override
  State<FormTransaksiScreen> createState() => _FormTransaksiScreenState();
}

class _FormTransaksiScreenState extends State<FormTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _catatanController = TextEditingController();
  final _kategoriService = KategoriService();
  final _transaksiService = TransaksiService();

  JenisTransaksi _jenis = JenisTransaksi.pengeluaran;
  int? _kategoriId;
  DateTime _tanggal = DateTime.now();
  List<KategoriModel> _kategoriList = [];

  bool _isLoading = false;
  bool _isLoadingKategori = true;

  bool get _isEdit => widget.transaksi != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = widget.transaksi!;
      _jenis = t.jenis;
      _kategoriId = t.kategoriId;
      _tanggal = DateTime.parse(t.tanggal);
      _nominalController.text = t.nominal.toStringAsFixed(0);
      _catatanController.text = t.catatan ?? '';
    }
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    final list = await _kategoriService.getAllKategori();
    if (!mounted) return;
    setState(() {
      _kategoriList = list;
      _kategoriId ??= list.isNotEmpty ? list.first.id : null;
      _isLoadingKategori = false;
    });
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_kategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final transaksi = TransaksiModel(
      id: widget.transaksi?.id,
      kategoriId: _kategoriId!,
      jenis: _jenis,
      nominal: double.parse(_nominalController.text.replaceAll(RegExp(r'[^0-9]'), '')),
      tanggal: _tanggal.toIso8601String().split('T').first,
      catatan: _catatanController.text.trim(),
    );

    if (_isEdit) {
      await _transaksiService.updateTransaksi(transaksi);
    } else {
      await _transaksiService.tambahTransaksi(transaksi);
    }

    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Transaksi berhasil diperbarui' : 'Transaksi berhasil disimpan'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, true);
  }

  Future<void> _handleHapus() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _transaksiService.hapusTransaksi(widget.transaksi!.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(_isEdit ? 'Edit Transaksi' : 'Tambah Transaksi',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: _handleHapus,
            ),
        ],
      ),
      body: _isLoadingKategori
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Jenis Transaksi
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        _buildJenisButton('Pemasukan', JenisTransaksi.pemasukan, AppColors.success),
                        _buildJenisButton('Pengeluaran', JenisTransaksi.pengeluaran, AppColors.danger),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nominalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nominal',
                      prefixText: 'Rp ',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Nominal wajib diisi';
                      final numeric = double.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                      if (numeric == null || numeric <= 0) return 'Nominal tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _kategoriId,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    items: _kategoriList.map((k) {
                      final color = ColorUtils.hexToColor(k.warna);
                      return DropdownMenuItem(
                        value: k.id,
                        child: Row(
                          children: [
                            Icon(IconHelper.getIcon(k.icon), color: color, size: 18),
                            const SizedBox(width: 8),
                            Text(k.nama),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _kategoriId = value),
                    validator: (value) => value == null ? 'Pilih kategori' : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pilihTanggal,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            '${_tanggal.day}/${_tanggal.month}/${_tanggal.year}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSimpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(_isEdit ? 'Update' : 'Simpan',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildJenisButton(String label, JenisTransaksi jenis, Color color) {
    final isSelected = _jenis == jenis;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _jenis = jenis),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/kategori_model.dart';
import '../../services/kategori_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/icon_helper.dart';

/// Form Tambah/Edit Kategori. Jika `kategori` null -> mode tambah,
/// jika tidak null -> mode edit (field terisi otomatis).
class FormKategoriScreen extends StatefulWidget {
  final KategoriModel? kategori;

  const FormKategoriScreen({super.key, this.kategori});

  @override
  State<FormKategoriScreen> createState() => _FormKategoriScreenState();
}

class _FormKategoriScreenState extends State<FormKategoriScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kategoriService = KategoriService();

  late String _selectedIcon;
  late Color _selectedColor;
  bool _isLoading = false;

  bool get _isEdit => widget.kategori != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _namaController.text = widget.kategori!.nama;
      _selectedIcon = widget.kategori!.icon;
      _selectedColor = ColorUtils.hexToColor(widget.kategori!.warna);
    } else {
      _selectedIcon = IconHelper.availableKeys.first;
      _selectedColor = AppColors.kategoriPalette.first;
    }
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final kategori = KategoriModel(
      id: widget.kategori?.id,
      nama: _namaController.text.trim(),
      warna: ColorUtils.colorToHex(_selectedColor),
      icon: _selectedIcon,
    );

    if (_isEdit) {
      await _kategoriService.updateKategori(kategori);
    } else {
      await _kategoriService.tambahKategori(kategori);
    }

    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Kategori berhasil diperbarui' : 'Kategori berhasil ditambahkan'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(_isEdit ? 'Edit Kategori' : 'Tambah Kategori',
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Preview
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _selectedColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(IconHelper.getIcon(_selectedIcon), color: _selectedColor, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _namaController.text.isEmpty ? 'Nama Kategori' : _namaController.text,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Nama kategori wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            const Text('Pilih Icon', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: IconHelper.availableKeys.map((key) {
                final isSelected = _selectedIcon == key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? _selectedColor : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? _selectedColor : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      IconHelper.getIcon(key),
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Pilih Warna', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: AppColors.kategoriPalette.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.textPrimary, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.4), blurRadius: isSelected ? 8 : 0),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
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
                  : Text(_isEdit ? 'Update Kategori' : 'Simpan Kategori',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

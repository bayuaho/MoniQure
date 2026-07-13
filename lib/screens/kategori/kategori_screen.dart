import 'package:flutter/material.dart';
import '../../models/kategori_model.dart';
import '../../services/kategori_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/icon_helper.dart';
import '../../widgets/custom_drawer.dart';
import 'form_kategori_screen.dart';

/// Halaman Manajemen Kategori: tambah, edit, hapus kategori pengguna.
class KategoriScreen extends StatefulWidget {
  const KategoriScreen({super.key});

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  final _kategoriService = KategoriService();
  List<KategoriModel> _kategoriList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    setState(() => _isLoading = true);
    final list = await _kategoriService.getAllKategori();
    if (!mounted) return;
    setState(() {
      _kategoriList = list;
      _isLoading = false;
    });
  }

  Future<void> _hapusKategori(KategoriModel kategori) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus kategori "${kategori.nama}"? '
            'Seluruh transaksi pada kategori ini juga akan terhapus.'),
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
      await _kategoriService.hapusKategori(kategori.id!);
      _loadKategori();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const CustomDrawer(currentRoute: 'kategori'),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormKategoriScreen()),
          );
          if (result == true) _loadKategori();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _kategoriList.isEmpty
              ? Center(
                  child: Text('Belum ada kategori', style: TextStyle(color: Colors.grey.shade500)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  itemCount: _kategoriList.length,
                  itemBuilder: (context, index) {
                    final kategori = _kategoriList[index];
                    final color = ColorUtils.hexToColor(kategori.warna);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(IconHelper.getIcon(kategori.icon), color: color),
                        ),
                        title: Text(kategori.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormKategoriScreen(kategori: kategori),
                                  ),
                                );
                                if (result == true) _loadKategori();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                              onPressed: () => _hapusKategori(kategori),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

import '../database/database_helper.dart';
import '../models/kategori_model.dart';

/// Menangani operasi CRUD untuk tabel `kategori`.
class KategoriService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> tambahKategori(KategoriModel kategori) async {
    final db = await _dbHelper.database;
    return await db.insert('kategori', kategori.toMap());
  }

  Future<List<KategoriModel>> getAllKategori() async {
    final db = await _dbHelper.database;
    final result = await db.query('kategori', orderBy: 'nama ASC');
    return result.map((map) => KategoriModel.fromMap(map)).toList();
  }

  Future<KategoriModel?> getKategoriById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query('kategori', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return KategoriModel.fromMap(result.first);
  }

  Future<int> updateKategori(KategoriModel kategori) async {
    final db = await _dbHelper.database;
    return await db.update(
      'kategori',
      kategori.toMap(),
      where: 'id = ?',
      whereArgs: [kategori.id],
    );
  }

  /// Menghapus kategori. Transaksi terkait ikut terhapus (ON DELETE CASCADE).
  Future<int> hapusKategori(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('kategori', where: 'id = ?', whereArgs: [id]);
  }
}

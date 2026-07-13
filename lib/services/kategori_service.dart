import '../database/database_helper.dart';
import '../models/kategori_model.dart';

/// Menangani operasi CRUD untuk tabel `kategori`, selalu di-scope
/// per userId supaya data antar akun tidak tercampur.
class KategoriService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> tambahKategori(KategoriModel kategori) async {
    final db = await _dbHelper.database;
    return await db.insert('kategori', kategori.toMap());
  }

  Future<List<KategoriModel>> getAllKategori(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'kategori',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'nama ASC',
    );
    return result.map((map) => KategoriModel.fromMap(map)).toList();
  }

  Future<KategoriModel?> getKategoriById(int id, int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'kategori',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    if (result.isEmpty) return null;
    return KategoriModel.fromMap(result.first);
  }

  Future<int> updateKategori(KategoriModel kategori) async {
    final db = await _dbHelper.database;
    return await db.update(
      'kategori',
      kategori.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [kategori.id, kategori.userId],
    );
  }

  Future<int> hapusKategori(int id, int userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'kategori',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  /// Dipanggil sekali saat user baru selesai registrasi (lihat AuthService),
  /// supaya setiap akun punya 10 kategori default miliknya sendiri.
  Future<void> seedDefaultKategori(int userId) async {
    final db = await _dbHelper.database;
    final defaults = [
      {'nama': 'Makanan', 'warna': '#22C55E', 'icon': 'makanan'},
      {'nama': 'Transportasi', 'warna': '#3B82F6', 'icon': 'transportasi'},
      {'nama': 'Tagihan', 'warna': '#8B5CF6', 'icon': 'tagihan'},
      {'nama': 'Belanja', 'warna': '#F97316', 'icon': 'belanja'},
      {'nama': 'Hiburan', 'warna': '#EC4899', 'icon': 'hiburan'},
      {'nama': 'Pendidikan', 'warna': '#1D4ED8', 'icon': 'pendidikan'},
      {'nama': 'Kesehatan', 'warna': '#EF4444', 'icon': 'kesehatan'},
      {'nama': 'Gaji', 'warna': '#15803D', 'icon': 'gaji'},
      {'nama': 'Investasi', 'warna': '#06B6D4', 'icon': 'investasi'},
      {'nama': 'Lainnya', 'warna': '#6B7280', 'icon': 'lainnya'},
    ];

    for (final kategori in defaults) {
      await db.insert('kategori', {...kategori, 'user_id': userId});
    }
  }
}
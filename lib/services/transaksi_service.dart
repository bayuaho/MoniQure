import '../database/database_helper.dart';
import '../models/transaksi_model.dart';

/// Menangani CRUD transaksi serta query agregat, selalu di-scope
/// per userId supaya data antar akun tidak tercampur.
class TransaksiService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> tambahTransaksi(TransaksiModel transaksi) async {
    final db = await _dbHelper.database;
    return await db.insert('transaksi', transaksi.toMap());
  }

  Future<int> updateTransaksi(TransaksiModel transaksi) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transaksi',
      transaksi.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [transaksi.id, transaksi.userId],
    );
  }

  Future<int> hapusTransaksi(int id, int userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'transaksi',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<List<TransaksiModel>> getAllTransaksi(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        t.id, t.user_id, t.kategori_id, t.jenis, t.nominal, t.tanggal, t.catatan,
        k.nama AS nama_kategori, k.warna AS warna_kategori, k.icon AS icon_kategori
      FROM transaksi t
      INNER JOIN kategori k ON t.kategori_id = k.id
      WHERE t.user_id = ?
      ORDER BY t.tanggal DESC, t.id DESC
    ''', [userId]);
    return result.map((map) => TransaksiModel.fromJoinMap(map)).toList();
  }

  Future<double> getTotalPemasukan(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(nominal), 0) AS total FROM transaksi WHERE jenis = 'pemasukan' AND user_id = ?",
      [userId],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getTotalPengeluaran(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(nominal), 0) AS total FROM transaksi WHERE jenis = 'pengeluaran' AND user_id = ?",
      [userId],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getSaldo(int userId) async {
    final pemasukan = await getTotalPemasukan(userId);
    final pengeluaran = await getTotalPengeluaran(userId);
    return pemasukan - pengeluaran;
  }

  Future<int> getJumlahTransaksi(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS jumlah FROM transaksi WHERE user_id = ?',
      [userId],
    );
    return (result.first['jumlah'] as int?) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getRekapPengeluaranPerKategori(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        k.id AS kategori_id, k.nama, k.warna, k.icon,
        COALESCE(SUM(t.nominal), 0) AS total
      FROM kategori k
      LEFT JOIN transaksi t ON t.kategori_id = k.id AND t.jenis = 'pengeluaran' AND t.user_id = ?
      WHERE k.user_id = ?
      GROUP BY k.id
      HAVING total > 0
      ORDER BY total DESC
    ''', [userId, userId]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getPersentasePengeluaranPerKategori(int userId) async {
    final rekap = await getRekapPengeluaranPerKategori(userId);
    final totalPengeluaran = await getTotalPengeluaran(userId);

    if (totalPengeluaran == 0) return [];

    return rekap.map((row) {
      final total = (row['total'] as num).toDouble();
      final persentase = (total / totalPengeluaran) * 100;
      return {...row, 'persentase': persentase};
    }).toList();
  }
}
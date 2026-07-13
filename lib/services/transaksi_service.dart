import '../database/database_helper.dart';
import '../models/transaksi_model.dart';

/// Menangani CRUD transaksi serta query agregat yang dipakai
/// oleh Dashboard dan halaman Laporan.
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
      where: 'id = ?',
      whereArgs: [transaksi.id],
    );
  }

  Future<int> hapusTransaksi(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('transaksi', where: 'id = ?', whereArgs: [id]);
  }

  /// Mengambil seluruh transaksi lengkap dengan info kategori (JOIN),
  /// diurutkan dari tanggal terbaru.
  Future<List<TransaksiModel>> getAllTransaksi() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        t.id, t.kategori_id, t.jenis, t.nominal, t.tanggal, t.catatan,
        k.nama AS nama_kategori, k.warna AS warna_kategori, k.icon AS icon_kategori
      FROM transaksi t
      INNER JOIN kategori k ON t.kategori_id = k.id
      ORDER BY t.tanggal DESC, t.id DESC
    ''');
    return result.map((map) => TransaksiModel.fromJoinMap(map)).toList();
  }

  Future<double> getTotalPemasukan() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(nominal), 0) AS total FROM transaksi WHERE jenis = 'pemasukan'",
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getTotalPengeluaran() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(nominal), 0) AS total FROM transaksi WHERE jenis = 'pengeluaran'",
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getSaldo() async {
    final pemasukan = await getTotalPemasukan();
    final pengeluaran = await getTotalPengeluaran();
    return pemasukan - pengeluaran;
  }

  Future<int> getJumlahTransaksi() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS jumlah FROM transaksi');
    return (result.first['jumlah'] as int?) ?? 0;
  }

  /// Rekap total pengeluaran per kategori, dipakai untuk Progress Indicator
  /// di Dashboard dan grafik di halaman Laporan.
  /// Return: List of {kategori_id, nama, warna, icon, total}
  Future<List<Map<String, dynamic>>> getRekapPengeluaranPerKategori() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT
        k.id AS kategori_id, k.nama, k.warna, k.icon,
        COALESCE(SUM(t.nominal), 0) AS total
      FROM kategori k
      LEFT JOIN transaksi t ON t.kategori_id = k.id AND t.jenis = 'pengeluaran'
      GROUP BY k.id
      HAVING total > 0
      ORDER BY total DESC
    ''');
    return result;
  }

  /// Menghitung persentase setiap kategori terhadap total pengeluaran.
  /// Dipakai untuk Circular Progress Indicator & Pie Chart.
  Future<List<Map<String, dynamic>>> getPersentasePengeluaranPerKategori() async {
    final rekap = await getRekapPengeluaranPerKategori();
    final totalPengeluaran = await getTotalPengeluaran();

    if (totalPengeluaran == 0) return [];

    return rekap.map((row) {
      final total = (row['total'] as num).toDouble();
      final persentase = (total / totalPengeluaran) * 100;
      return {
        ...row,
        'persentase': persentase,
      };
    }).toList();
  }
}

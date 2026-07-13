import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// DatabaseHelper menggunakan Singleton Pattern agar hanya ada
/// satu koneksi database aktif di seluruh aplikasi.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  /// Getter database, otomatis membuat/membuka database jika belum ada.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel User
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Tabel Kategori
    await db.execute('''
      CREATE TABLE kategori (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        warna TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    // Tabel Transaksi (relasi: 1 kategori punya banyak transaksi)
    await db.execute('''
      CREATE TABLE transaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kategori_id INTEGER NOT NULL,
        jenis TEXT NOT NULL,
        nominal REAL NOT NULL,
        tanggal TEXT NOT NULL,
        catatan TEXT,
        FOREIGN KEY (kategori_id) REFERENCES kategori (id) ON DELETE CASCADE
      )
    ''');

    await _seedKategoriDefault(db);
  }

  /// Mengisi kategori default sesuai contoh pada spesifikasi,
  /// supaya aplikasi langsung bisa dipakai tanpa setup manual.
  Future<void> _seedKategoriDefault(Database db) async {
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
      await db.insert('kategori', kategori);
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

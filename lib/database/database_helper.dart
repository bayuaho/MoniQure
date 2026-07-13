import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// DatabaseHelper menggunakan Singleton Pattern agar hanya ada
/// satu koneksi database aktif di seluruh aplikasi.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Kolom user_id memastikan setiap kategori hanya milik satu akun,
    // jadi tidak akan tercampur antar user (ini yang jadi penyebab bug).
    await db.execute('''
      CREATE TABLE kategori (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nama TEXT NOT NULL,
        warna TEXT NOT NULL,
        icon TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Transaksi juga diberi user_id langsung (bukan cuma lewat kategori)
    // supaya query filter per-user lebih jelas dan pasti benar.
    await db.execute('''
      CREATE TABLE transaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        kategori_id INTEGER NOT NULL,
        jenis TEXT NOT NULL,
        nominal REAL NOT NULL,
        tanggal TEXT NOT NULL,
        catatan TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (kategori_id) REFERENCES kategori (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Migrasi dari versi 1 (tanpa user_id) ke versi 2.
  /// Kalau app di HP sudah pernah dipakai sebelum fix ini, sebaiknya
  /// uninstall dulu aplikasinya supaya database dibuat ulang dari nol
  /// dengan skema baru yang benar.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE kategori ADD COLUMN user_id INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE transaksi ADD COLUMN user_id INTEGER NOT NULL DEFAULT 0');
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
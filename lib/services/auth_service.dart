import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';
import 'kategori_service.dart';

/// Menangani seluruh logika autentikasi:
/// registrasi, login, cek status login, dan logout.
class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final KategoriService _kategoriService = KategoriService();

  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUsername = 'loggedInUsername';
  static const String _keyUserId = 'loggedInUserId';

  Future<bool> isUsernameExists(String username) async {
    final db = await _dbHelper.database;
    final result = await db.query('users', where: 'username = ?', whereArgs: [username]);
    return result.isNotEmpty;
  }

  /// Registrasi user baru. Setiap akun baru otomatis dibuatkan
  /// kategori default miliknya sendiri (tidak berbagi dengan akun lain).
  Future<bool> register(String username, String password) async {
    final db = await _dbHelper.database;
    final user = UserModel(username: username, password: password);
    final newUserId = await db.insert('users', user.toMap());

    if (newUserId > 0) {
      await _kategoriService.seedDefaultKategori(newUserId);
      return true;
    }
    return false;
  }

  /// Verifikasi login. Mengembalikan true jika username & password cocok.
  Future<bool> login(String username, String password) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      final user = UserModel.fromMap(result.first);
      await _saveLoginStatus(user);
      return true;
    }
    return false;
  }

  Future<void> _saveLoginStatus(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, user.username);
    await prefs.setInt(_keyUserId, user.id!);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// Dipakai oleh KategoriService & TransaksiService untuk memastikan
  /// data yang diambil/disimpan hanya milik akun yang sedang login.
  Future<int?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyUserId);
  }
}
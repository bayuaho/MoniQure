import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

/// Menangani seluruh logika autentikasi:
/// registrasi, login, cek status login, dan logout.
class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUsername = 'loggedInUsername';

  /// Cek apakah username sudah dipakai (dipakai untuk validasi register).
  Future<bool> isUsernameExists(String username) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  /// Registrasi user baru. Mengembalikan true jika berhasil.
  Future<bool> register(String username, String password) async {
    final db = await _dbHelper.database;
    final user = UserModel(username: username, password: password);
    final id = await db.insert('users', user.toMap());
    return id > 0;
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
      await _saveLoginStatus(username);
      return true;
    }
    return false;
  }

  Future<void> _saveLoginStatus(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
  }

  /// Dipanggil dari Splash Screen untuk menentukan halaman awal.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// Hapus status login dari SharedPreferences saat logout.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
  }
}

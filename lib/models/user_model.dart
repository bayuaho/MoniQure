/// Model untuk tabel `users`.
/// Merepresentasikan satu akun pengguna aplikasi.
class UserModel {
  final int? id;
  final String username;
  final String password;

  UserModel({
    this.id,
    required this.username,
    required this.password,
  });

  /// Konversi object -> Map, dipakai saat insert/update ke SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }

  /// Konversi Map (hasil query SQLite) -> object UserModel.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }
}

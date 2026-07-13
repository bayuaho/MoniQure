/// Model untuk tabel `kategori`.
/// `userId` menandai kategori ini milik akun siapa.
/// `warna` disimpan dalam format HEX (contoh: "#4CAF50").
/// `icon` disimpan sebagai key string yang dipetakan ke IconData
/// melalui IconHelper (lihat lib/utils/icon_helper.dart).
class KategoriModel {
  final int? id;
  final int userId;
  final String nama;
  final String warna;
  final String icon;

  KategoriModel({
    this.id,
    required this.userId,
    required this.nama,
    required this.warna,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nama': nama,
      'warna': warna,
      'icon': icon,
    };
  }

  factory KategoriModel.fromMap(Map<String, dynamic> map) {
    return KategoriModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      nama: map['nama'] as String,
      warna: map['warna'] as String,
      icon: map['icon'] as String,
    );
  }

  KategoriModel copyWith({
    int? id,
    int? userId,
    String? nama,
    String? warna,
    String? icon,
  }) {
    return KategoriModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      warna: warna ?? this.warna,
      icon: icon ?? this.icon,
    );
  }
}
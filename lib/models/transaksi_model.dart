/// Enum jenis transaksi agar type-safe di seluruh aplikasi.
enum JenisTransaksi { pemasukan, pengeluaran }

extension JenisTransaksiExt on JenisTransaksi {
  String get value => this == JenisTransaksi.pemasukan ? 'pemasukan' : 'pengeluaran';

  static JenisTransaksi fromString(String value) {
    return value == 'pemasukan' ? JenisTransaksi.pemasukan : JenisTransaksi.pengeluaran;
  }
}

/// Model untuk tabel `transaksi`.
/// `tanggal` disimpan sebagai String format ISO8601 (yyyy-MM-dd).
class TransaksiModel {
  final int? id;
  final int kategoriId;
  final JenisTransaksi jenis;
  final double nominal;
  final String tanggal;
  final String? catatan;

  // Field tambahan (join) hanya dipakai untuk tampilan, tidak disimpan di tabel transaksi.
  final String? namaKategori;
  final String? warnaKategori;
  final String? iconKategori;

  TransaksiModel({
    this.id,
    required this.kategoriId,
    required this.jenis,
    required this.nominal,
    required this.tanggal,
    this.catatan,
    this.namaKategori,
    this.warnaKategori,
    this.iconKategori,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kategori_id': kategoriId,
      'jenis': jenis.value,
      'nominal': nominal,
      'tanggal': tanggal,
      'catatan': catatan,
    };
  }

  /// Dipakai untuk hasil query biasa (tanpa join).
  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      id: map['id'] as int?,
      kategoriId: map['kategori_id'] as int,
      jenis: JenisTransaksiExt.fromString(map['jenis'] as String),
      nominal: (map['nominal'] as num).toDouble(),
      tanggal: map['tanggal'] as String,
      catatan: map['catatan'] as String?,
    );
  }

  /// Dipakai untuk hasil query JOIN dengan tabel kategori
  /// (dashboard & laporan butuh nama/warna/icon kategori sekaligus).
  factory TransaksiModel.fromJoinMap(Map<String, dynamic> map) {
    return TransaksiModel(
      id: map['id'] as int?,
      kategoriId: map['kategori_id'] as int,
      jenis: JenisTransaksiExt.fromString(map['jenis'] as String),
      nominal: (map['nominal'] as num).toDouble(),
      tanggal: map['tanggal'] as String,
      catatan: map['catatan'] as String?,
      namaKategori: map['nama_kategori'] as String?,
      warnaKategori: map['warna_kategori'] as String?,
      iconKategori: map['icon_kategori'] as String?,
    );
  }
}

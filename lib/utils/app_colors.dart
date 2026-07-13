import 'package:flutter/material.dart';

/// Palet warna utama aplikasi (sesuai spesifikasi UI/UX).
class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);

  /// Daftar pilihan warna kategori (dipakai di Color Picker sederhana).
  static const List<Color> kategoriPalette = [
    Color(0xFF22C55E), // Hijau
    Color(0xFF3B82F6), // Biru
    Color(0xFF8B5CF6), // Ungu
    Color(0xFFF97316), // Oranye
    Color(0xFFEC4899), // Pink
    Color(0xFF1D4ED8), // Biru Tua
    Color(0xFFEF4444), // Merah
    Color(0xFF15803D), // Hijau Tua
    Color(0xFF06B6D4), // Cyan
    Color(0xFF6B7280), // Abu-abu
    Color(0xFFF59E0B), // Amber
    Color(0xFF9333EA), // Ungu Tua
  ];
}

/// Helper konversi warna HEX ("#RRGGBB") <-> Color, dipakai di seluruh
/// aplikasi karena warna kategori disimpan dalam format HEX di SQLite.
class ColorUtils {
  static Color hexToColor(String hex) {
    String cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
    return Color(int.parse(cleanHex, radix: 16));
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

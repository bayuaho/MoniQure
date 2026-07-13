import 'package:flutter/material.dart';

/// SQLite tidak bisa menyimpan IconData secara langsung, jadi setiap
/// kategori menyimpan `icon` sebagai key String (contoh: "makanan").
/// IconHelper memetakan key tersebut ke IconData yang sesuai.
class IconHelper {
  static const Map<String, IconData> _iconMap = {
    'makanan': Icons.restaurant_rounded,
    'transportasi': Icons.directions_car_rounded,
    'tagihan': Icons.receipt_long_rounded,
    'belanja': Icons.shopping_bag_rounded,
    'hiburan': Icons.movie_rounded,
    'pendidikan': Icons.school_rounded,
    'kesehatan': Icons.local_hospital_rounded,
    'gaji': Icons.payments_rounded,
    'investasi': Icons.trending_up_rounded,
    'lainnya': Icons.category_rounded,
    'rumah': Icons.home_rounded,
    'olahraga': Icons.fitness_center_rounded,
    'hadiah': Icons.card_giftcard_rounded,
    'travel': Icons.flight_takeoff_rounded,
    'pet': Icons.pets_rounded,
    'elektronik': Icons.devices_rounded,
  };

  /// Dipakai untuk menampilkan pilihan icon di form kategori.
  static List<String> get availableKeys => _iconMap.keys.toList();

  static IconData getIcon(String key) {
    return _iconMap[key] ?? Icons.category_rounded;
  }
}

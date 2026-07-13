import 'package:intl/intl.dart';

/// Kumpulan fungsi format yang dipakai berulang kali di seluruh aplikasi.
class FormatUtils {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String rupiah(double value) => _currencyFormat.format(value);

  static String tanggalIndonesia(String isoDate) {
    final date = DateTime.parse(isoDate);
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  static String tanggalPendek(String isoDate) {
    final date = DateTime.parse(isoDate);
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

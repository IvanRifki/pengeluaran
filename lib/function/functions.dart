import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

removedot(nominal) {
  return nominal.toString().replaceAll('.', '');
}

removerp(nominal) {
  return nominal.toString().replaceAll('Rp ', '');
}

removerpNospacing(nominal) {
  return nominal.toString().replaceAll('Rp', '');
}

NumberFormat currencyFormatterRp = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

bulanSekarang() {
  return DateFormat('MMMM').format(DateTime.now());
}

parsingDateFormat(String dateData) {
  //untuk ubah data string menjadi tipe datetime
  return DateFormat('EEEE dd MMMM yyyy').parse(dateData);
}

dtFormatMMMM(dateData) {
  return DateFormat('MMMM').format(dateData);
}

dtFormatMMMMyyyy(dateData) {
  return DateFormat('MMMM yyyy').format(dateData);
}

cekContainRp(nominal) {
  return nominal.toString().contains('Rp ') == true
      ? nominal.toString().replaceAll('Rp ', '')
      : nominal.toString().contains('Rp') == true
          ? nominal.toString().replaceAll('Rp', '')
          : nominal;
}

cardColorValue(value) {
  Color colorValue;
  if (int.parse(value) < 100000) {
    colorValue = const Color.fromRGBO(231, 70, 70, 1);
  } else {
    colorValue = const Color.fromRGBO(149, 1, 1, 1);
  }
  return colorValue;
}

imageCardPengeluaran(tipe) {
  if (tipe == 'Belanja Pribadi') {
    return 'assets/images/belanjapribadi.png';
  } else if (tipe == 'Hiburan') {
    return 'assets/images/hiburan.png';
  } else if (tipe == 'Kesehatan') {
    return 'assets/images/kesehatan.png';
  } else if (tipe == 'Lainnya') {
    return 'assets/images/lainnya.png';
  } else if (tipe == 'Makanan') {
    return 'assets/images/makanan.png';
  } else if (tipe == 'Transportasi') {
    return 'assets/images/transportasi.png';
  } else {
    return 'assets/images/irlogonobg.png';
  }
}

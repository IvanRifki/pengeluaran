import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pengeluaran/static/static.dart';

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

bulanTahunSekarang() {
  DateTime now = DateTime.now();
  return DateFormat('MMMM yyyy').format(DateTime.now());
}

parsingDateFormat(String dateData) {
  //untuk ubah data string menjadi tipe datetime
  return DateFormat('EEEE dd MMMM yyyy').parse(dateData);
}

parsingDateFormatMY(String dateData) {
  return DateFormat('MMMM yyyy').parse(dateData);
}

dtFormatMMMM(dateData) {
  return DateFormat('MMMM').format(dateData);
}

dtFormatMMMMyyyy(DateTime dateData) {
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

showMonthPickerCustom(context) {
  return showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      confirmWidget: const Text('Pilih', style: TextStyle(color: Colors.grey)),
      cancelWidget: const Text('Batal', style: TextStyle(color: Colors.grey)),
      roundedCornersRadius: defaultPadding,
      headerColor: Colors.grey[900],
      backgroundColor: Colors.grey[900],
      headerTextColor: Colors.amber,
      selectedMonthBackgroundColor: Colors.amber,
      selectedMonthTextColor: Colors.black,
      unselectedMonthTextColor: Colors.grey,
      headerTitle: Text(
        'Pilih Bulan Pengeluaran',
        style: TextStyle(color: Colors.grey),
      ),
      hideHeaderRow: true);
}

showDatePickerCustom(context) {
  showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2015, 8),
    lastDate: DateTime(2101),
    cancelText: 'Batal',
    confirmText: 'Pilih',
    helpText: 'Pilih tanggal pengeluaran.',
    fieldLabelText: 'Pilih Tanggal',
    fieldHintText: 'Pilih Tanggal',
    errorFormatText: 'Format Tanggal Tidak Sesuai.',
    errorInvalidText: 'Pilih Tanggal Yang Valid.',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.amber,
            onPrimary: Colors.black,
            onSurface: Colors.grey,
            surface: Colors.grey[900]!,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey, // button text color
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}

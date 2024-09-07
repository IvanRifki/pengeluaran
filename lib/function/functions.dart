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

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

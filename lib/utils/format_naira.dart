import 'package:intl/intl.dart';

String formatNaira(dynamic value) {
  // Handles both String and num inputs, defaults to 0 if invalid
  num amount;
  if (value is num) {
    amount = value;
  } else if (value is String) {
    amount = num.tryParse(value.replaceAll(',', '')) ?? 0;
  } else {
    amount = 0;
  }

  final formatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: 'N',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

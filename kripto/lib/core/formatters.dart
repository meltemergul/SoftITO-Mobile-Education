import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _usdCurrencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _tryCurrencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0.########', 'en_US');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  static String formatCurrency(Decimal value, String currency) {
    final doubleVal = value.toDouble();
    if (currency == 'TRY') {
      return _tryCurrencyFormat.format(doubleVal);
    }
    return _usdCurrencyFormat.format(doubleVal);
  }

  static String formatQuantity(Decimal value) {
    return _numberFormat.format(value.toDouble());
  }

  static String formatPercentage(Decimal value) {
    final doubleVal = value.toDouble();
    final sign = doubleVal > 0 ? '+' : '';
    return '$sign${doubleVal.toStringAsFixed(2)}%';
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime.toLocal());
  }

  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime.toLocal());
  }
}

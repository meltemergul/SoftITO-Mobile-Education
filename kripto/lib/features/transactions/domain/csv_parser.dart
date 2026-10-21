import 'package:csv/csv.dart';
import 'package:decimal/decimal.dart';

class CsvRowError {
  final int rowIndex;
  final String message;

  const CsvRowError(this.rowIndex, this.message);
}

class CsvParseResult {
  final List<Map<String, dynamic>> validRows;
  final List<CsvRowError> errors;

  const CsvParseResult({required this.validRows, required this.errors});

  bool get hasErrors => errors.isNotEmpty;
}

class CsvParser {
  CsvParseResult parse(String csvContent) {
    final rows = csv.decode(csvContent);
    final validRows = <Map<String, dynamic>>[];
    final errors = <CsvRowError>[];

    if (rows.isEmpty) {
      return CsvParseResult(
        validRows: [],
        errors: [const CsvRowError(0, 'CSV dosyası boş')],
      );
    }

    // Başlık satırı kontrolü: tarih,coin,islem_tipi,miktar,fiyat,para_birimi,komisyon
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
        continue;
      }
      if (row.length < 6) {
        errors.add(CsvRowError(i + 1, 'Eksik kolon sayısı (en az 6 kolon bekleniyor)'));
        continue;
      }

      try {
        final executedAt = DateTime.parse(row[0].toString().trim());
        final symbol = row[1].toString().trim().toUpperCase();
        final typeStr = row[2].toString().trim().toUpperCase();
        if (typeStr != 'BUY' && typeStr != 'SELL') {
          errors.add(CsvRowError(i + 1, 'Geçersiz işlem tipi ($typeStr). Sadece BUY veya SELL'));
          continue;
        }

        final quantity = Decimal.parse(row[3].toString().trim());
        final price = Decimal.parse(row[4].toString().trim());
        final currency = row[5].toString().trim().toUpperCase();
        if (currency != 'USD' && currency != 'TRY') {
          errors.add(CsvRowError(i + 1, 'Geçersiz para birimi ($currency). Sadece USD veya TRY'));
          continue;
        }

        final fee = row.length > 6 && row[6].toString().trim().isNotEmpty
            ? Decimal.parse(row[6].toString().trim())
            : Decimal.zero;

        validRows.add({
          'executed_at': executedAt,
          'symbol': symbol,
          'type': typeStr,
          'quantity': quantity,
          'price': price,
          'price_currency': currency,
          'fee': fee,
        });
      } catch (e) {
        errors.add(CsvRowError(i + 1, 'Veri biçimi hatası: $e'));
      }
    }

    return CsvParseResult(validRows: validRows, errors: errors);
  }
}

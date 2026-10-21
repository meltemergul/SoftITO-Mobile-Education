import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared/models/asset.dart';
import '../domain/transaction.dart';

class CsvService {
  Future<String?> pickAndReadCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.path != null) {
      return File(file.path!).readAsString();
    }
    return file.xFile.readAsString();
  }

  /// Gerçek .csv dosyasını diske kaydeder ve dosya nesnesini döner.
  Future<File> generateTransactionsCsvFile(
    List<AppTransaction> transactions,
    List<Asset> assets,
  ) async {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('tarih,coin,islem_tipi,miktar,fiyat,para_birimi,komisyon');

    for (final tx in transactions) {
      final asset = assets.firstWhere(
        (a) => a.id == tx.assetId,
        orElse: () => Asset(
          id: tx.assetId,
          symbol: tx.assetId.toUpperCase(),
          name: tx.assetId,
          coingeckoId: tx.assetId.toLowerCase(),
        ),
      );

      final dateStr = tx.executedAt.toLocal().toString().substring(0, 16);
      final typeStr = tx.type == TransactionType.buy ? 'BUY' : 'SELL';
      buffer.writeln(
        '$dateStr,${asset.symbol},$typeStr,${tx.quantity},${tx.price},${tx.priceCurrency},${tx.fee}',
      );
    }

    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final file = File('${dir.path}/chronomind_islemler_$timestamp.csv');
    await file.writeAsString(buffer.toString());
    return file;
  }

  /// Gerçek .csv dosyasını sistem paylaşım penceresiyle (Dosyalara Kaydet, AirDrop vb.) dışarı aktarır.
  /// iOS / iPadOS üzerinde çökme/hata olmaması için `sharePositionOrigin` güvenli varsayılanla iletilir.
  Future<void> exportTransactionsToCsvFile(
    List<AppTransaction> transactions,
    List<Asset> assets, {
    Rect? sharePositionOrigin,
  }) async {
    final file = await generateTransactionsCsvFile(transactions, assets);
    final origin = sharePositionOrigin ?? const Rect.fromLTWH(0, 0, 300, 300);

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'text/csv',
          name: file.uri.pathSegments.last,
        ),
      ],
      text: 'Chronomind Portföy İşlem Geçmişi (.csv)',
      subject: 'Chronomind İşlemler',
      sharePositionOrigin: origin,
    );
  }

  /// Örnek şablon .csv dosyasını diske yazıp dışarı aktarır.
  Future<void> exportSampleTemplateCsvFile({Rect? sharePositionOrigin}) async {
    const template = 'tarih,coin,islem_tipi,miktar,fiyat,para_birimi,komisyon\n'
        '2026-01-15 10:30,BTC,BUY,0.05,95000,USD,2.5\n'
        '2026-01-16 14:00,ETH,BUY,1.0,3400,USD,1.0\n'
        '2026-01-20 18:30,BTC,SELL,0.02,98000,USD,2.0\n';

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/chronomind_ornek_sablon.csv');
    await file.writeAsString(template);
    final origin = sharePositionOrigin ?? const Rect.fromLTWH(0, 0, 300, 300);

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'text/csv',
          name: 'chronomind_ornek_sablon.csv',
        ),
      ],
      text: 'Chronomind Örnek CSV Şablonu (.csv)',
      subject: 'Chronomind Örnek CSV',
      sharePositionOrigin: origin,
    );
  }
}

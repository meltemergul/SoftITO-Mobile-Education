import 'package:file_picker/file_picker.dart';

class CsvService {
  Future<String?> pickAndReadCsv() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result.isEmpty) return null;

    return result.first.xFile.readAsString();
  }
}

import '../../domain/entities/quote.dart';

class QuoteModel extends Quote {
  const QuoteModel({
    required super.id,
    required super.text,
    super.author,
    required super.source,
    super.isFavorite = false,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String?,
      source: (json['source'] as String?) ?? 'fallback',
      isFavorite: (json['isFavorite'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'source': source,
      'isFavorite': isFavorite,
    };
  }
}

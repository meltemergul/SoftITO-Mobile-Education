class Quote {
  const Quote({
    required this.id,
    required this.text,
    this.author,
    required this.source,
    this.isFavorite = false,
  });

  final String id;
  final String text;
  final String? author;
  final String source;
  final bool isFavorite;

  Quote copyWith({
    String? id,
    String? text,
    String? author,
    String? source,
    bool? isFavorite,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      source: source ?? this.source,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quote &&
        other.id == id &&
        other.text == text &&
        other.author == author &&
        other.source == source &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode => Object.hash(id, text, author, source, isFavorite);
}

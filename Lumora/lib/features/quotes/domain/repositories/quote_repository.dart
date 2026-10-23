import '../entities/quote.dart';

abstract class QuoteRepository {
  Future<Quote> getDailyQuote({String? date});
  Future<bool> addFavorite(String quoteId);
  Future<bool> removeFavorite(String quoteId);
}

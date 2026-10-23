import '../../domain/entities/quote.dart';
import '../../domain/repositories/quote_repository.dart';
import '../datasources/quote_remote_data_source.dart';

class QuoteRepositoryImpl implements QuoteRepository {
  QuoteRepositoryImpl(this._remoteDataSource);

  final QuoteRemoteDataSource _remoteDataSource;

  @override
  Future<Quote> getDailyQuote({String? date}) {
    return _remoteDataSource.getDailyQuote(date: date);
  }

  @override
  Future<bool> addFavorite(String quoteId) {
    return _remoteDataSource.addFavorite(quoteId);
  }

  @override
  Future<bool> removeFavorite(String quoteId) {
    return _remoteDataSource.removeFavorite(quoteId);
  }
}

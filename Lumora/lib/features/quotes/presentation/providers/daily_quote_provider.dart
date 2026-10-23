import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/quote_remote_data_source.dart';
import '../../data/repositories/quote_repository_impl.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quote_repository.dart';

final quoteRemoteDataSourceProvider = Provider<QuoteRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuoteRemoteDataSourceImpl(apiClient);
});

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  final remote = ref.watch(quoteRemoteDataSourceProvider);
  return QuoteRepositoryImpl(remote);
});

@immutable
class DailyQuoteState {
  const DailyQuoteState({
    this.quote,
    this.isLoading = false,
    this.errorMessage,
  });

  final Quote? quote;
  final bool isLoading;
  final String? errorMessage;

  DailyQuoteState copyWith({
    Quote? quote,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DailyQuoteState(
      quote: quote ?? this.quote,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class DailyQuoteNotifier extends Notifier<DailyQuoteState> {
  late final QuoteRepository _repository;

  @override
  DailyQuoteState build() {
    _repository = ref.watch(quoteRepositoryProvider);
    return const DailyQuoteState();
  }

  Future<void> loadDailyQuote({bool force = false}) async {
    if (!force && state.quote != null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final quote = await _repository.getDailyQuote();
      state = state.copyWith(
        quote: quote,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Günün sözü yüklenemedi.',
      );
    }
  }

  Future<void> toggleFavorite() async {
    final currentQuote = state.quote;
    if (currentQuote == null) return;

    final targetFavorite = !currentQuote.isFavorite;

    // Optimistic UI güncellemesi
    state = state.copyWith(
      quote: currentQuote.copyWith(isFavorite: targetFavorite),
    );

    try {
      if (targetFavorite) {
        await _repository.addFavorite(currentQuote.id);
      } else {
        await _repository.removeFavorite(currentQuote.id);
      }
    } catch (e) {
      // Hata durumunda önceki duruma geri al
      state = state.copyWith(
        quote: currentQuote,
        errorMessage: 'Favori durumu güncellenemedi.',
      );
    }
  }

  Future<void> shareQuote() async {
    final quote = state.quote;
    if (quote == null) return;

    final StringBuffer buffer = StringBuffer();
    buffer.write('"${quote.text}"');

    if (quote.author != null && quote.author!.trim().isNotEmpty) {
      buffer.write(' — ${quote.author!.trim()}');
    }

    buffer.write('\n\n#Lumora #ZinciriKırma');

    // ignore: deprecated_member_use
    await Share.share(
      buffer.toString(),
      subject: 'Günün İlhamı — Lumora',
    );
  }
}

final dailyQuoteNotifierProvider =
    NotifierProvider<DailyQuoteNotifier, DailyQuoteState>(DailyQuoteNotifier.new);

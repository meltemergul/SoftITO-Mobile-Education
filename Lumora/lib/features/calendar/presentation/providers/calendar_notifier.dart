import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/calendar_remote_data_source.dart';
import '../../data/repositories/calendar_repository_impl.dart';
import '../../domain/entities/calendar_day_detail_entity.dart';
import '../../domain/entities/calendar_month_entity.dart';
import '../../domain/repositories/calendar_repository.dart';

final calendarRemoteDataSourceProvider = Provider<CalendarRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CalendarRemoteDataSourceImpl(apiClient);
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final remote = ref.watch(calendarRemoteDataSourceProvider);
  return CalendarRepositoryImpl(remote);
});

final weekStartsOnProvider = Provider<int>((ref) => 1);

@immutable
class CalendarState {
  const CalendarState({
    required this.currentMonth,
    this.calendarData,
    this.isLoading = false,
    this.errorMessage,
    this.selectedDayDetail,
    this.isLoadingDayDetail = false,
  });

  final DateTime currentMonth;
  final CalendarMonthEntity? calendarData;
  final bool isLoading;
  final String? errorMessage;
  final CalendarDayDetailEntity? selectedDayDetail;
  final bool isLoadingDayDetail;

  String get monthString {
    final year = currentMonth.year;
    final m = currentMonth.month < 10 ? '0${currentMonth.month}' : '${currentMonth.month}';
    return '$year-$m';
  }

  CalendarState copyWith({
    DateTime? currentMonth,
    CalendarMonthEntity? calendarData,
    bool? isLoading,
    String? errorMessage,
    CalendarDayDetailEntity? selectedDayDetail,
    bool? isLoadingDayDetail,
    bool clearDayDetail = false,
  }) {
    return CalendarState(
      currentMonth: currentMonth ?? this.currentMonth,
      calendarData: calendarData ?? this.calendarData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedDayDetail: clearDayDetail ? null : (selectedDayDetail ?? this.selectedDayDetail),
      isLoadingDayDetail: isLoadingDayDetail ?? this.isLoadingDayDetail,
    );
  }
}

class CalendarNotifier extends Notifier<CalendarState> {
  late final CalendarRepository _repository;

  @override
  CalendarState build() {
    _repository = ref.watch(calendarRepositoryProvider);
    return CalendarState(currentMonth: DateTime.now());
  }

  Future<void> loadCalendar({DateTime? month, bool force = false}) async {
    final targetMonth = month ?? state.currentMonth;
    final monthStr = _formatMonthString(targetMonth);

    state = state.copyWith(
      currentMonth: targetMonth,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final data = await _repository.getMonthCalendar(month: monthStr);
      state = state.copyWith(
        calendarData: data,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Takvim verileri yüklenemedi.',
      );
    }
  }

  Future<void> previousMonth() async {
    final prev = DateTime(state.currentMonth.year, state.currentMonth.month - 1, 1);
    await loadCalendar(month: prev);
  }

  Future<void> nextMonth() async {
    final next = DateTime(state.currentMonth.year, state.currentMonth.month + 1, 1);
    await loadCalendar(month: next);
  }

  Future<CalendarDayDetailEntity?> loadDayDetail(String date) async {
    state = state.copyWith(isLoadingDayDetail: true, clearDayDetail: true);

    try {
      final detail = await _repository.getDayDetail(date);
      state = state.copyWith(
        selectedDayDetail: detail,
        isLoadingDayDetail: false,
      );
      return detail;
    } catch (e) {
      state = state.copyWith(
        isLoadingDayDetail: false,
        errorMessage: 'Gün detayları alınamadı.',
      );
      return null;
    }
  }

  String _formatMonthString(DateTime dt) {
    final year = dt.year;
    final m = dt.month < 10 ? '0${dt.month}' : '${dt.month}';
    return '$year-$m';
  }
}

final calendarNotifierProvider =
    NotifierProvider<CalendarNotifier, CalendarState>(CalendarNotifier.new);

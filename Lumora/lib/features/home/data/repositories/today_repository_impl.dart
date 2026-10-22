import '../../../../core/network/api_error.dart';
import '../../../../core/storage/today_cache_storage.dart';
import '../../domain/entities/today_entity.dart';
import '../../domain/repositories/today_repository.dart';
import '../datasources/today_remote_data_source.dart';
import '../models/today_model.dart';

class TodayRepositoryImpl implements TodayRepository {
  TodayRepositoryImpl({
    required TodayRemoteDataSource remoteDataSource,
    required TodayCacheStorage cacheStorage,
  })  : _remoteDataSource = remoteDataSource,
        _cacheStorage = cacheStorage;

  final TodayRemoteDataSource _remoteDataSource;
  final TodayCacheStorage _cacheStorage;

  @override
  Future<TodayEntity> getToday({bool forceRefresh = false}) async {
    // 1. Önce bekleyen çevrimdışı işlemleri senkronize etmeyi dene
    await syncPendingOps();

    // 2. Sunucudan güncel veriyi çek
    try {
      final remoteModel = await _remoteDataSource.getToday();
      // Başarılı yanıtı yerel önbelleğe kaydet (Offline-first)
      await _cacheStorage.saveTodayCache(remoteModel.toJson());
      return remoteModel.toEntity();
    } on ApiException catch (_) {
      // Ağ hatası veya zaman aşımı durumunda yerel önbelleğe dön
      final cachedJson = await _cacheStorage.getTodayCache();
      if (cachedJson != null) {
        final cachedModel = TodayModel.fromJson(cachedJson);
        return cachedModel.toEntity();
      }
      rethrow;
    } catch (_) {
      final cachedJson = await _cacheStorage.getTodayCache();
      if (cachedJson != null) {
        final cachedModel = TodayModel.fromJson(cachedJson);
        return cachedModel.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<void> updateLog(
    String habitId,
    String date, {
    double? amount,
    double? delta,
  }) async {
    try {
      await _remoteDataSource.updateLog(habitId, date, amount: amount, delta: delta);
    } on ApiException catch (e) {
      // Ağ hatası ise işlemi kuyruğa ekle (Offline-first)
      if (e.code == 'TIMEOUT' || e.code == 'NETWORK_ERROR') {
        await _cacheStorage.addPendingOp(
          PendingLogOp(
            habitId: habitId,
            date: date,
            amount: amount,
            delta: delta,
            timestamp: DateTime.now().toIso8601String(),
          ),
        );
      } else {
        rethrow;
      }
    } catch (_) {
      await _cacheStorage.addPendingOp(
        PendingLogOp(
          habitId: habitId,
          date: date,
          amount: amount,
          delta: delta,
          timestamp: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  @override
  Future<void> syncPendingOps() async {
    try {
      final pendingOps = await _cacheStorage.getPendingOps();
      if (pendingOps.isEmpty) return;

      for (final op in pendingOps) {
        try {
          await _remoteDataSource.updateLog(
            op.habitId,
            op.date,
            amount: op.amount,
            delta: op.delta,
          );
        } catch (_) {
          // Bağlantı hala yoksa döngüyü kes, kuyruk korunsun
          return;
        }
      }

      await _cacheStorage.clearPendingOps();
    } catch (_) {}
  }
}

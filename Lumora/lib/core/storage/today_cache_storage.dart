import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PendingLogOp {
  const PendingLogOp({
    required this.habitId,
    required this.date,
    this.amount,
    this.delta,
    required this.timestamp,
  });

  factory PendingLogOp.fromJson(Map<String, dynamic> json) {
    return PendingLogOp(
      habitId: json['habitId'] as String,
      date: json['date'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      delta: (json['delta'] as num?)?.toDouble(),
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  final String habitId;
  final String date;
  final double? amount;
  final double? delta;
  final String timestamp;

  Map<String, dynamic> toJson() => {
        'habitId': habitId,
        'date': date,
        'amount': amount,
        'delta': delta,
        'timestamp': timestamp,
      };
}

class TodayCacheStorage {
  TodayCacheStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              mOptions: MacOsOptions(
                usesDataProtectionKeychain: false,
              ),
            );

  final FlutterSecureStorage _storage;
  static const _cacheKey = 'lumora_today_cache';
  static const _pendingOpsKey = 'lumora_pending_ops';

  // In-memory fallback
  Map<String, dynamic>? _memoryCache;
  final List<PendingLogOp> _memoryPendingOps = [];

  Future<void> saveTodayCache(Map<String, dynamic> data) async {
    _memoryCache = data;
    try {
      await _storage.write(key: _cacheKey, value: jsonEncode(data));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getTodayCache() async {
    if (_memoryCache != null) return _memoryCache;
    try {
      final raw = await _storage.read(key: _cacheKey);
      if (raw != null) {
        _memoryCache = jsonDecode(raw) as Map<String, dynamic>;
        return _memoryCache;
      }
    } catch (_) {}
    return null;
  }

  Future<void> addPendingOp(PendingLogOp op) async {
    _memoryPendingOps.add(op);
    try {
      final current = await getPendingOps();
      current.add(op);
      await _storage.write(
        key: _pendingOpsKey,
        value: jsonEncode(current.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<List<PendingLogOp>> getPendingOps() async {
    try {
      final raw = await _storage.read(key: _pendingOpsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list
            .map((e) => PendingLogOp.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return List.from(_memoryPendingOps);
  }

  Future<void> clearPendingOps() async {
    _memoryPendingOps.clear();
    try {
      await _storage.delete(key: _pendingOpsKey);
    } catch (_) {}
  }
}

import 'package:flutter/foundation.dart';

/// 性能优化工具类
class PerformanceUtils {
  
  /// 调试模式下的性能监控
  static void logPerformance(String operation, Function() function) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      function();
      stopwatch.stop();
      debugPrint('Performance: $operation took ${stopwatch.elapsedMilliseconds}ms');
    } else {
      function();
    }
  }

  /// 异步操作的性能监控
  static Future<T> logAsyncPerformance<T>(
    String operation, 
    Future<T> Function() function,
  ) async {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      final result = await function();
      stopwatch.stop();
      debugPrint('Performance: $operation took ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } else {
      return await function();
    }
  }

  /// 内存使用情况监控
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      // 在实际应用中，这里可以添加更详细的内存监控
      debugPrint('Memory check: $context');
    }
  }

  /// 数据验证工具
  static bool validateSampleData(List<double> data) {
    if (data.isEmpty) return false;
    
    // 检查是否包含无效值
    for (double value in data) {
      if (value.isNaN || value.isInfinite) {
        return false;
      }
    }
    
    return true;
  }

  /// 数据清理工具
  static List<double> cleanSampleData(List<double> data) {
    return data.where((value) => !value.isNaN && !value.isInfinite).toList();
  }

  /// 计算缓存键
  static String generateCacheKey(Map<String, dynamic> parameters) {
    final sortedKeys = parameters.keys.toList()..sort();
    final keyParts = sortedKeys.map((key) => '$key:${parameters[key]}');
    return keyParts.join('|');
  }
}

/// 简单的结果缓存
class ResultCache {
  static final Map<String, dynamic> _cache = {};
  static const int maxCacheSize = 100;

  /// 获取缓存结果
  static T? get<T>(String key) {
    return _cache[key] as T?;
  }

  /// 设置缓存结果
  static void set(String key, dynamic value) {
    if (_cache.length >= maxCacheSize) {
      // 简单的LRU策略：删除第一个元素
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[key] = value;
  }

  /// 清除缓存
  static void clear() {
    _cache.clear();
  }

  /// 获取缓存大小
  static int get size => _cache.length;
}

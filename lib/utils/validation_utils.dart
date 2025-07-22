import 'dart:math' as math;

/// 数据验证工具类
class ValidationUtils {
  
  /// 验证样本数据
  static ValidationResult validateSampleData(String input) {
    if (input.trim().isEmpty) {
      return ValidationResult(false, '请输入样本数据');
    }

    try {
      List<double> data = parseNumbers(input);
      
      if (data.isEmpty) {
        return ValidationResult(false, '没有找到有效的数字');
      }

      if (data.length < 2) {
        return ValidationResult(false, '样本数据至少需要2个数值');
      }

      // 检查异常值
      if (data.any((value) => value.isNaN || value.isInfinite)) {
        return ValidationResult(false, '数据包含无效值（NaN或无穷大）');
      }

      // 检查数据范围
      double min = data.reduce((a, b) => a < b ? a : b);
      double max = data.reduce((a, b) => a > b ? a : b);
      
      if ((max - min).abs() > 1e10) {
        return ValidationResult(false, '数据范围过大，可能影响计算精度');
      }

      return ValidationResult(true, '数据验证通过', data: data);
    } catch (e) {
      return ValidationResult(false, '数据格式错误：${e.toString()}');
    }
  }

  /// 验证显著性水平
  static ValidationResult validateAlpha(String input) {
    if (input.trim().isEmpty) {
      return ValidationResult(false, '请输入显著性水平');
    }

    try {
      double alpha = double.parse(input);
      
      if (alpha <= 0 || alpha >= 1) {
        return ValidationResult(false, '显著性水平必须在0和1之间');
      }

      if (alpha < 0.001) {
        return ValidationResult(false, '显著性水平不应小于0.001');
      }

      if (alpha > 0.2) {
        return ValidationResult(false, '显著性水平通常不应大于0.2');
      }

      return ValidationResult(true, '显著性水平验证通过', data: alpha);
    } catch (e) {
      return ValidationResult(false, '显著性水平格式错误');
    }
  }

  /// 验证总体均值
  static ValidationResult validatePopulationMean(String input) {
    if (input.trim().isEmpty) {
      return ValidationResult(false, '请输入总体均值');
    }

    try {
      double mean = double.parse(input);
      
      if (mean.isNaN || mean.isInfinite) {
        return ValidationResult(false, '总体均值不能为NaN或无穷大');
      }

      return ValidationResult(true, '总体均值验证通过', data: mean);
    } catch (e) {
      return ValidationResult(false, '总体均值格式错误');
    }
  }

  /// 验证总体方差
  static ValidationResult validatePopulationVariance(String input) {
    if (input.trim().isEmpty) {
      return ValidationResult(false, '请输入总体方差');
    }

    try {
      double variance = double.parse(input);
      
      if (variance <= 0) {
        return ValidationResult(false, '总体方差必须大于0');
      }

      if (variance.isNaN || variance.isInfinite) {
        return ValidationResult(false, '总体方差不能为NaN或无穷大');
      }

      return ValidationResult(true, '总体方差验证通过', data: variance);
    } catch (e) {
      return ValidationResult(false, '总体方差格式错误');
    }
  }

  /// 验证配对样本
  static ValidationResult validatePairedSamples(String input1, String input2) {
    ValidationResult result1 = validateSampleData(input1);
    if (!result1.isValid) {
      return ValidationResult(false, '第一组数据：${result1.message}');
    }

    ValidationResult result2 = validateSampleData(input2);
    if (!result2.isValid) {
      return ValidationResult(false, '第二组数据：${result2.message}');
    }

    List<double> data1 = result1.data as List<double>;
    List<double> data2 = result2.data as List<double>;

    if (data1.length != data2.length) {
      return ValidationResult(false, '配对样本的数据长度必须相等');
    }

    return ValidationResult(true, '配对样本验证通过', 
        data: {'sample1': data1, 'sample2': data2});
  }

  /// 验证ANOVA数据
  static ValidationResult validateAnovaData(List<String> groupInputs) {
    if (groupInputs.length < 2) {
      return ValidationResult(false, 'ANOVA至少需要2组数据');
    }

    List<List<double>> groups = [];
    
    for (int i = 0; i < groupInputs.length; i++) {
      ValidationResult result = validateSampleData(groupInputs[i]);
      if (!result.isValid) {
        return ValidationResult(false, '第${i + 1}组数据：${result.message}');
      }
      groups.add(result.data as List<double>);
    }

    // 检查每组至少有2个数据点
    for (int i = 0; i < groups.length; i++) {
      if (groups[i].length < 2) {
        return ValidationResult(false, '第${i + 1}组数据至少需要2个数值');
      }
    }

    return ValidationResult(true, 'ANOVA数据验证通过', data: groups);
  }

  /// 验证卡方检验数据
  static ValidationResult validateChiSquareData(String observed, String expected) {
    ValidationResult obsResult = validateSampleData(observed);
    if (!obsResult.isValid) {
      return ValidationResult(false, '观察频数：${obsResult.message}');
    }

    ValidationResult expResult = validateSampleData(expected);
    if (!expResult.isValid) {
      return ValidationResult(false, '期望频数：${expResult.message}');
    }

    List<double> obsData = obsResult.data as List<double>;
    List<double> expData = expResult.data as List<double>;

    if (obsData.length != expData.length) {
      return ValidationResult(false, '观察频数和期望频数的长度必须相等');
    }

    // 检查频数是否为非负数
    if (obsData.any((value) => value < 0)) {
      return ValidationResult(false, '观察频数不能为负数');
    }

    if (expData.any((value) => value <= 0)) {
      return ValidationResult(false, '期望频数必须大于0');
    }

    return ValidationResult(true, '卡方检验数据验证通过', 
        data: {'observed': obsData, 'expected': expData});
  }

  /// 解析数字字符串
  static List<double> parseNumbers(String input) {
    return input
        .split(RegExp(r'[,，\s]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => double.parse(s))
        .toList();
  }

  /// 检查数据质量
  static DataQualityReport checkDataQuality(List<double> data) {
    if (data.isEmpty) {
      return DataQualityReport(
        hasIssues: true,
        issues: ['数据为空'],
        suggestions: ['请输入有效的数据'],
      );
    }

    List<String> issues = [];
    List<String> suggestions = [];

    // 检查样本量
    if (data.length < 5) {
      issues.add('样本量较小 (n=${data.length})');
      suggestions.add('考虑增加样本量以提高检验效能');
    }

    // 检查异常值
    double mean = data.reduce((a, b) => a + b) / data.length;
    double variance = data.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / (data.length - 1);
    double std = variance > 0 ? variance.sqrt() : 0;
    
    List<double> outliers = data.where((x) => (x - mean).abs() > 3 * std).toList();
    if (outliers.isNotEmpty) {
      issues.add('检测到${outliers.length}个可能的异常值');
      suggestions.add('检查异常值是否为数据录入错误');
    }

    // 检查数据分布
    data.sort();
    double median = data.length % 2 == 0 
        ? (data[data.length ~/ 2 - 1] + data[data.length ~/ 2]) / 2
        : data[data.length ~/ 2];
    
    if ((mean - median).abs() > std) {
      issues.add('数据可能存在偏态分布');
      suggestions.add('考虑使用非参数检验方法');
    }

    return DataQualityReport(
      hasIssues: issues.isNotEmpty,
      issues: issues,
      suggestions: suggestions,
      sampleSize: data.length,
      mean: mean,
      median: median,
      standardDeviation: std,
      outliers: outliers,
    );
  }
}

/// 验证结果类
class ValidationResult {
  final bool isValid;
  final String message;
  final dynamic data;

  ValidationResult(this.isValid, this.message, {this.data});
}

/// 数据质量报告类
class DataQualityReport {
  final bool hasIssues;
  final List<String> issues;
  final List<String> suggestions;
  final int sampleSize;
  final double mean;
  final double median;
  final double standardDeviation;
  final List<double> outliers;

  DataQualityReport({
    required this.hasIssues,
    required this.issues,
    required this.suggestions,
    this.sampleSize = 0,
    this.mean = 0.0,
    this.median = 0.0,
    this.standardDeviation = 0.0,
    this.outliers = const [],
  });
}

/// 扩展方法
extension DoubleExtension on double {
  double sqrt() {
    return this < 0 ? 0 : math.sqrt(abs());
  }
}

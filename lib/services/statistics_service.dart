import 'dart:math' as math;

/// 统计计算服务类
class StatisticsService {
  
  /// 计算样本均值
  static double mean(List<double> data) {
    if (data.isEmpty) return 0.0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  /// 计算样本标准差
  static double standardDeviation(List<double> data, {bool sample = true}) {
    if (data.length < 2) return 0.0;
    
    double avg = mean(data);
    double sumSquaredDiff = data.map((x) => math.pow(x - avg, 2).toDouble()).reduce((a, b) => a + b);
    
    int denominator = sample ? data.length - 1 : data.length;
    return math.sqrt(sumSquaredDiff / denominator);
  }

  /// 计算样本方差
  static double variance(List<double> data, {bool sample = true}) {
    double sd = standardDeviation(data, sample: sample);
    return sd * sd;
  }

  /// 标准正态分布累积分布函数 (CDF)
  static double normalCDF(double z) {
    // 使用近似公式计算标准正态分布的CDF
    return 0.5 * (1 + _erf(z / math.sqrt(2)));
  }

  /// 误差函数的近似计算
  static double _erf(double x) {
    // Abramowitz and Stegun approximation
    const double a1 = 0.254829592;
    const double a2 = -0.284496736;
    const double a3 = 1.421413741;
    const double a4 = -1.453152027;
    const double a5 = 1.061405429;
    const double p = 0.3275911;

    int sign = x < 0 ? -1 : 1;
    x = x.abs();

    double t = 1.0 / (1.0 + p * x);
    double y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-x * x);

    return sign * y;
  }

  /// t分布累积分布函数的近似计算
  static double tCDF(double t, int degreesOfFreedom) {
    if (degreesOfFreedom >= 30) {
      // 当自由度大于30时，t分布近似于标准正态分布
      return normalCDF(t);
    }
    
    // 对于小自由度的t分布，使用近似公式
    // 这里使用简化的近似，实际应用中可能需要更精确的算法
    double x = t / math.sqrt(degreesOfFreedom);
    return 0.5 + 0.5 * _erf(x / math.sqrt(2));
  }

  /// 卡方分布累积分布函数的近似计算
  static double chiSquareCDF(double x, int degreesOfFreedom) {
    if (x <= 0) return 0.0;
    if (degreesOfFreedom <= 0) return 0.0;
    
    // 使用Gamma函数的近似来计算卡方分布
    // 这是一个简化的实现，实际应用中可能需要更精确的算法
    return _incompleteGamma(degreesOfFreedom / 2.0, x / 2.0);
  }

  /// 不完全Gamma函数的近似计算
  static double _incompleteGamma(double a, double x) {
    if (x == 0) return 0.0;
    if (a == 0) return 1.0;
    
    // 使用级数展开的近似
    double sum = 1.0;
    double term = 1.0;
    
    for (int n = 1; n < 100; n++) {
      term *= x / (a + n - 1);
      sum += term;
      if (term.abs() < 1e-10) break;
    }
    
    return math.pow(x, a) * math.exp(-x) * sum / _gamma(a);
  }

  /// Gamma函数的近似计算
  static double _gamma(double z) {
    // Stirling's approximation for Gamma function
    if (z < 0.5) {
      return math.pi / (math.sin(math.pi * z) * _gamma(1 - z));
    }

    z -= 1;
    double x = 0.99999999999980993;
    List<double> p = [
      676.5203681218851, -1259.1392167224028, 771.32342877765313,
      -176.61502916214059, 12.507343278686905, -0.13857109526572012,
      9.9843695780195716e-6, 1.5056327351493116e-7
    ];

    for (int i = 0; i < p.length; i++) {
      x += p[i] / (z + i + 1);
    }

    double t = z + p.length - 0.5;
    return math.sqrt(2 * math.pi) * math.pow(t, z + 0.5) * math.exp(-t) * x;
  }

  /// 计算中位数
  static double median(List<double> data) {
    if (data.isEmpty) return 0.0;

    List<double> sorted = List.from(data)..sort();
    int n = sorted.length;

    if (n % 2 == 1) {
      return sorted[n ~/ 2];
    } else {
      return (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
    }
  }

  /// 计算四分位数
  static Map<String, double> quartiles(List<double> data) {
    if (data.isEmpty) return {'Q1': 0.0, 'Q2': 0.0, 'Q3': 0.0};

    List<double> sorted = List.from(data)..sort();
    int n = sorted.length;

    double q2 = median(sorted);

    List<double> lowerHalf = sorted.sublist(0, n ~/ 2);
    List<double> upperHalf = sorted.sublist((n + 1) ~/ 2);

    double q1 = median(lowerHalf);
    double q3 = median(upperHalf);

    return {'Q1': q1, 'Q2': q2, 'Q3': q3};
  }

  /// 计算秩次
  static List<double> ranks(List<double> data) {
    List<int> indices = List.generate(data.length, (i) => i);
    indices.sort((a, b) => data[a].compareTo(data[b]));

    List<double> ranks = List.filled(data.length, 0.0);

    for (int i = 0; i < indices.length; i++) {
      ranks[indices[i]] = i + 1.0;
    }

    // 处理相同值的平均秩次
    for (int i = 0; i < data.length; i++) {
      List<int> ties = [];
      for (int j = 0; j < data.length; j++) {
        if (data[j] == data[i]) {
          ties.add(j);
        }
      }

      if (ties.length > 1) {
        double avgRank = ties.map((idx) => ranks[idx]).reduce((a, b) => a + b) / ties.length;
        for (int idx in ties) {
          ranks[idx] = avgRank;
        }
      }
    }

    return ranks;
  }

  /// 计算符号检验的统计量
  static int signTestStatistic(List<double> data, double median0) {
    int positive = 0;
    for (double value in data) {
      if (value > median0) positive++;
    }
    return positive;
  }

  /// 二项分布概率质量函数
  static double binomialPMF(int k, int n, double p) {
    if (k < 0 || k > n) return 0.0;

    double logProb = _logCombination(n, k) + k * math.log(p) + (n - k) * math.log(1 - p);
    return math.exp(logProb);
  }

  /// 二项分布累积分布函数
  static double binomialCDF(int k, int n, double p) {
    double sum = 0.0;
    for (int i = 0; i <= k; i++) {
      sum += binomialPMF(i, n, p);
    }
    return sum;
  }

  /// 对数组合数计算
  static double _logCombination(int n, int k) {
    if (k > n - k) k = n - k;

    double result = 0.0;
    for (int i = 0; i < k; i++) {
      result += math.log(n - i) - math.log(i + 1);
    }
    return result;
  }
}

import 'dart:math' as math;
import '../models/test_input.dart';
import '../models/test_result.dart';
import 'statistics_service.dart';

/// 假设检验服务类
class HypothesisTestService {
  
  /// 执行假设检验
  static Future<TestResult> performTest(TestInput input) async {
    switch (input.testType) {
      case 'one_sample_t':
        return _oneSampleTTest(input);
      case 'two_sample_t':
        return _twoSampleTTest(input);
      case 'paired_t':
        return _pairedTTest(input);
      case 'one_sample_z':
        return _oneSampleZTest(input);
      case 'two_sample_z':
        return _twoSampleZTest(input);
      case 'anova':
        return _anovaTest(input);
      case 'chi_square':
        return _chiSquareTest(input);
      case 'sign_test':
        return _signTest(input);
      case 'wilcoxon':
        return _wilcoxonTest(input);
      default:
        throw ArgumentError('不支持的检验类型: ${input.testType}');
    }
  }

  /// 单样本t检验
  static TestResult _oneSampleTTest(TestInput input) {
    if (input.populationMean == null) {
      throw ArgumentError('单样本t检验需要总体均值');
    }

    double sampleMean = StatisticsService.mean(input.sample1);
    double sampleStd = StatisticsService.standardDeviation(input.sample1);
    int n = input.sample1.length;
    double mu0 = input.populationMean!;

    // 计算t统计量
    double t = (sampleMean - mu0) / (sampleStd / math.sqrt(n));
    
    // 自由度
    int df = n - 1;
    
    // 计算p值
    double pValue = _calculatePValue(t, df, input.alternativeHypothesis ?? 'two-sided', 't');
    
    // 判断是否拒绝原假设
    bool rejectNull = pValue < input.alpha;
    
    String conclusion = rejectNull 
        ? '拒绝原假设，样本均值与总体均值存在显著差异'
        : '不能拒绝原假设，样本均值与总体均值无显著差异';

    return TestResult(
      testType: '单样本t检验',
      testStatistic: t,
      pValue: pValue,
      alpha: input.alpha,
      rejectNull: rejectNull,
      conclusion: conclusion,
      additionalInfo: {
        'sample_mean': sampleMean,
        'sample_std': sampleStd,
        'sample_size': n,
        'degrees_of_freedom': df,
        'population_mean': mu0,
      },
    );
  }

  /// 双样本t检验
  static TestResult _twoSampleTTest(TestInput input) {
    if (input.sample2 == null) {
      throw ArgumentError('双样本t检验需要两个样本');
    }

    double mean1 = StatisticsService.mean(input.sample1);
    double mean2 = StatisticsService.mean(input.sample2!);
    double std1 = StatisticsService.standardDeviation(input.sample1);
    double std2 = StatisticsService.standardDeviation(input.sample2!);
    int n1 = input.sample1.length;
    int n2 = input.sample2!.length;

    // 计算合并标准差
    double pooledStd = math.sqrt(
      ((n1 - 1) * std1 * std1 + (n2 - 1) * std2 * std2) / (n1 + n2 - 2)
    );

    // 计算t统计量
    double t = (mean1 - mean2) / (pooledStd * math.sqrt(1/n1 + 1/n2));
    
    // 自由度
    int df = n1 + n2 - 2;
    
    // 计算p值
    double pValue = _calculatePValue(t, df, input.alternativeHypothesis ?? 'two-sided', 't');
    
    // 判断是否拒绝原假设
    bool rejectNull = pValue < input.alpha;
    
    String conclusion = rejectNull 
        ? '拒绝原假设，两样本均值存在显著差异'
        : '不能拒绝原假设，两样本均值无显著差异';

    return TestResult(
      testType: '双样本t检验',
      testStatistic: t,
      pValue: pValue,
      alpha: input.alpha,
      rejectNull: rejectNull,
      conclusion: conclusion,
      additionalInfo: {
        'sample1_mean': mean1,
        'sample2_mean': mean2,
        'sample1_std': std1,
        'sample2_std': std2,
        'sample1_size': n1,
        'sample2_size': n2,
        'pooled_std': pooledStd,
        'degrees_of_freedom': df,
      },
    );
  }

  /// 配对样本t检验
  static TestResult _pairedTTest(TestInput input) {
    if (input.sample2 == null) {
      throw ArgumentError('配对样本t检验需要两个样本');
    }
    
    if (input.sample1.length != input.sample2!.length) {
      throw ArgumentError('配对样本的长度必须相等');
    }

    // 计算差值
    List<double> differences = [];
    for (int i = 0; i < input.sample1.length; i++) {
      differences.add(input.sample1[i] - input.sample2![i]);
    }

    double meanDiff = StatisticsService.mean(differences);
    double stdDiff = StatisticsService.standardDeviation(differences);
    int n = differences.length;

    // 计算t统计量
    double t = meanDiff / (stdDiff / math.sqrt(n));
    
    // 自由度
    int df = n - 1;
    
    // 计算p值
    double pValue = _calculatePValue(t, df, input.alternativeHypothesis ?? 'two-sided', 't');
    
    // 判断是否拒绝原假设
    bool rejectNull = pValue < input.alpha;
    
    String conclusion = rejectNull 
        ? '拒绝原假设，配对样本存在显著差异'
        : '不能拒绝原假设，配对样本无显著差异';

    return TestResult(
      testType: '配对样本t检验',
      testStatistic: t,
      pValue: pValue,
      alpha: input.alpha,
      rejectNull: rejectNull,
      conclusion: conclusion,
      additionalInfo: {
        'mean_difference': meanDiff,
        'std_difference': stdDiff,
        'sample_size': n,
        'degrees_of_freedom': df,
      },
    );
  }

  /// 单样本Z检验
  static TestResult _oneSampleZTest(TestInput input) {
    if (input.populationMean == null || input.populationVariance == null) {
      throw ArgumentError('单样本Z检验需要总体均值和方差');
    }

    double sampleMean = StatisticsService.mean(input.sample1);
    int n = input.sample1.length;
    double mu0 = input.populationMean!;
    double sigma = math.sqrt(input.populationVariance!);

    // 计算Z统计量
    double z = (sampleMean - mu0) / (sigma / math.sqrt(n));
    
    // 计算p值
    double pValue = _calculatePValue(z, 0, input.alternativeHypothesis ?? 'two-sided', 'z');
    
    // 判断是否拒绝原假设
    bool rejectNull = pValue < input.alpha;
    
    String conclusion = rejectNull 
        ? '拒绝原假设，样本均值与总体均值存在显著差异'
        : '不能拒绝原假设，样本均值与总体均值无显著差异';

    return TestResult(
      testType: '单样本Z检验',
      testStatistic: z,
      pValue: pValue,
      alpha: input.alpha,
      rejectNull: rejectNull,
      conclusion: conclusion,
      additionalInfo: {
        'sample_mean': sampleMean,
        'sample_size': n,
        'population_mean': mu0,
        'population_std': sigma,
      },
    );
  }

  /// 单因素方差分析(ANOVA)
  static TestResult _anovaTest(TestInput input) {
    // 这里假设input.additionalInfo包含多个组的数据
    // 格式: {'groups': [group1, group2, group3, ...]}
    if (!input.additionalInfo.containsKey('groups')) {
      throw ArgumentError('ANOVA需要多个组的数据');
    }

    List<List<double>> groups = (input.additionalInfo['groups'] as List)
        .map((group) => List<double>.from(group))
        .toList();

    if (groups.length < 2) {
      throw ArgumentError('ANOVA至少需要两个组');
    }

    // 计算总体均值
    List<double> allData = [];
    for (var group in groups) {
      allData.addAll(group);
    }
    double grandMean = StatisticsService.mean(allData);
    int totalN = allData.length;

    // 计算组间平方和(SSB)
    double ssb = 0.0;
    for (var group in groups) {
      double groupMean = StatisticsService.mean(group);
      ssb += group.length * math.pow(groupMean - grandMean, 2);
    }

    // 计算组内平方和(SSW)
    double ssw = 0.0;
    for (var group in groups) {
      double groupMean = StatisticsService.mean(group);
      for (double value in group) {
        ssw += math.pow(value - groupMean, 2);
      }
    }

    // 计算自由度
    int dfBetween = groups.length - 1;
    int dfWithin = totalN - groups.length;

    // 计算均方
    double msb = ssb / dfBetween;
    double msw = ssw / dfWithin;

    // 计算F统计量
    double f = msb / msw;

    // 计算p值 (这里使用简化的F分布近似)
    double pValue = _calculateFPValue(f, dfBetween, dfWithin);

    // 判断是否拒绝原假设
    bool rejectNull = pValue < input.alpha;

    String conclusion = rejectNull
        ? '拒绝原假设，各组均值存在显著差异'
        : '不能拒绝原假设，各组均值无显著差异';

    return TestResult(
      testType: '单因素方差分析(ANOVA)',
      testStatistic: f,
      pValue: pValue,
      alpha: input.alpha,
      rejectNull: rejectNull,
      conclusion: conclusion,
      additionalInfo: {
        'sum_of_squares_between': ssb,
        'sum_of_squares_within': ssw,
        'degrees_of_freedom_between': dfBetween,
        'degrees_of_freedom_within': dfWithin,
        'mean_square_between': msb,
        'mean_square_within': msw,
        'grand_mean': grandMean,
        'group_count': groups.length,
        'total_sample_size': totalN,
      },
    );
  }

  /// 双样本Z检验
  static TestResult _twoSampleZTest(TestInput input) {
    if (input.sample2 == null || input.populationVariance == null) {
      throw ArgumentError('双样本Z检验需要两个样本和已知的总体方差');
    }

    double mean1 = StatisticsService.mean(input.sample1);
    double mean2 = StatisticsService.mean(input.sample2!);
    int n1 = input.sample1.length;
    int n2 = input.sample2!.length;
    double sigma = math.sqrt(input.populationVariance!);

    // 计算Z统计量
    double z = (mean1 - mean2) / (sigma * math.sqrt(1/n1 + 1/n2));

    // 计算p值
    double pValue = _calculatePValue(z, 0, input.alternativeHypothesis ?? 'two-sided', 'z');

    // 判断是否拒绝原假设
    bool rejectNull = pValue < input.alpha;

    String conclusion = rejectNull
        ? '拒绝原假设，两样本均值存在显著差异'
        : '不能拒绝原假设，两样本均值无显著差异';

    return TestResult(
      testType: '双样本Z检验',
      testStatistic: z,
      pValue: pValue,
      alpha: input.alpha,
      rejectNull: rejectNull,
      conclusion: conclusion,
      additionalInfo: {
        'sample1_mean': mean1,
        'sample2_mean': mean2,
        'sample1_size': n1,
        'sample2_size': n2,
        'population_std': sigma,
      },
    );
  }

  /// 卡方拟合优度检验
  static TestResult _chiSquareTest(TestInput input) {
    // 这里实现简单的卡方拟合优度检验
    // 假设input.sample1包含观察频数，input.sample2包含期望频数
    if (input.sample2 == null) {
      throw ArgumentError('卡方检验需要观察频数和期望频数');
    }

    if (input.sample1.length != input.sample2!.length) {
      throw ArgumentError('观察频数和期望频数的长度必须相等');
    }

    double chiSquare = 0.0;
    for (int i = 0; i < input.sample1.length; i++) {
      double observed = input.sample1[i];
      double expected = input.sample2![i];
      if (expected <= 0) {
        throw ArgumentError('期望频数必须大于0');
      }
      chiSquare += math.pow(observed - expected, 2) / expected;
    }

    // 自由度 = 类别数 - 1
    int df = input.sample1.length - 1;

    // 计算p值
    double pValue = 1 - StatisticsService.chiSquareCDF(chiSquare, df);

    // 判断是否拒绝原假设
    bool rejectNull = pValue < input.alpha;

    String conclusion = rejectNull
        ? '拒绝原假设，观察频数与期望频数存在显著差异'
        : '不能拒绝原假设，观察频数与期望频数无显著差异';

    return TestResult(
      testType: '卡方拟合优度检验',
      testStatistic: chiSquare,
      pValue: pValue,
      alpha: input.alpha,
      rejectNull: rejectNull,
      conclusion: conclusion,
      additionalInfo: {
        'degrees_of_freedom': df,
        'observed_frequencies': input.sample1,
        'expected_frequencies': input.sample2,
      },
    );
  }

  /// 符号检验
  static TestResult _signTest(TestInput input) {
    if (input.populationMean == null) {
      throw ArgumentError('符号检验需要假设的中位数');
    }

    double median0 = input.populationMean!;
    int n = input.sample1.length;

    // 计算正号的个数
    int positiveCount = StatisticsService.signTestStatistic(input.sample1, median0);

    // 在原假设下，正号个数服从二项分布B(n, 0.5)
    double pValue;
    if (input.alternativeHypothesis == 'two-sided') {
      // 双侧检验
      double p1 = StatisticsService.binomialCDF(positiveCount, n, 0.5);
      double p2 = 1 - StatisticsService.binomialCDF(positiveCount - 1, n, 0.5);
      pValue = 2 * math.min(p1, p2);
    } else if (input.alternativeHypothesis == 'greater') {
      // 右侧检验
      pValue = 1 - StatisticsService.binomialCDF(positiveCount - 1, n, 0.5);
    } else {
      // 左侧检验
      pValue = StatisticsService.binomialCDF(positiveCount, n, 0.5);
    }

    // 判断是否拒绝原假设
    bool rejectNull = pValue < input.alpha;

    String conclusion = rejectNull
        ? '拒绝原假设，样本中位数与假设中位数存在显著差异'
        : '不能拒绝原假设，样本中位数与假设中位数无显著差异';

    return TestResult(
      testType: '符号检验',
      testStatistic: positiveCount.toDouble(),
      pValue: pValue,
      alpha: input.alpha,
      rejectNull: rejectNull,
      conclusion: conclusion,
      additionalInfo: {
        'positive_count': positiveCount,
        'sample_size': n,
        'hypothesized_median': median0,
      },
    );
  }

  /// Wilcoxon符号秩检验
  static TestResult _wilcoxonTest(TestInput input) {
    if (input.populationMean == null) {
      throw ArgumentError('Wilcoxon检验需要假设的中位数');
    }

    double median0 = input.populationMean!;

    // 计算差值
    List<double> differences = input.sample1.map((x) => x - median0).toList();

    // 移除零值
    differences.removeWhere((d) => d == 0);

    if (differences.isEmpty) {
      throw ArgumentError('所有差值都为零，无法进行Wilcoxon检验');
    }

    // 计算绝对值
    List<double> absDifferences = differences.map((d) => d.abs()).toList();

    // 计算秩次
    List<double> ranks = StatisticsService.ranks(absDifferences);

    // 计算正秩和
    double positiveRankSum = 0.0;
    for (int i = 0; i < differences.length; i++) {
      if (differences[i] > 0) {
        positiveRankSum += ranks[i];
      }
    }

    int n = differences.length;

    // 在大样本情况下，使用正态近似
    double expectedW = n * (n + 1) / 4.0;
    double varianceW = n * (n + 1) * (2 * n + 1) / 24.0;
    double z = (positiveRankSum - expectedW) / math.sqrt(varianceW);

    // 计算p值
    double pValue = _calculatePValue(z, 0, input.alternativeHypothesis ?? 'two-sided', 'z');

    // 判断是否拒绝原假设
    bool rejectNull = pValue < input.alpha;

    String conclusion = rejectNull
        ? '拒绝原假设，样本中位数与假设中位数存在显著差异'
        : '不能拒绝原假设，样本中位数与假设中位数无显著差异';

    return TestResult(
      testType: 'Wilcoxon符号秩检验',
      testStatistic: positiveRankSum,
      pValue: pValue,
      alpha: input.alpha,
      rejectNull: rejectNull,
      conclusion: conclusion,
      additionalInfo: {
        'positive_rank_sum': positiveRankSum,
        'sample_size': n,
        'z_statistic': z,
        'hypothesized_median': median0,
      },
    );
  }

  /// 计算p值
  static double _calculatePValue(double statistic, int df, String alternative, String distribution) {
    double pValue;
    
    if (distribution == 'z') {
      // 标准正态分布
      if (alternative == 'two-sided') {
        pValue = 2 * (1 - StatisticsService.normalCDF(statistic.abs()));
      } else if (alternative == 'greater') {
        pValue = 1 - StatisticsService.normalCDF(statistic);
      } else { // 'less'
        pValue = StatisticsService.normalCDF(statistic);
      }
    } else { // 't'
      // t分布
      if (alternative == 'two-sided') {
        pValue = 2 * (1 - StatisticsService.tCDF(statistic.abs(), df));
      } else if (alternative == 'greater') {
        pValue = 1 - StatisticsService.tCDF(statistic, df);
      } else { // 'less'
        pValue = StatisticsService.tCDF(statistic, df);
      }
    }
    
    return pValue.clamp(0.0, 1.0);
  }

  /// 计算F分布的p值（简化实现）
  static double _calculateFPValue(double f, int df1, int df2) {
    // 这是一个简化的F分布p值计算
    // 实际应用中应该使用更精确的算法
    if (f <= 1.0) return 0.5;

    // 使用近似公式
    double x = df2 / (df2 + df1 * f);

    // 使用不完全Beta函数的近似
    double p = _incompleteBeta(df2 / 2.0, df1 / 2.0, x);

    return p.clamp(0.0, 1.0);
  }

  /// 不完全Beta函数的简化实现
  static double _incompleteBeta(double a, double b, double x) {
    if (x <= 0) return 0.0;
    if (x >= 1) return 1.0;

    // 使用连分数展开的近似
    double result = math.pow(x, a) * math.pow(1 - x, b) / a;

    // 简化的级数近似
    double sum = 1.0;
    double term = 1.0;

    for (int n = 1; n < 50; n++) {
      term *= (a + n - 1) * x / n;
      sum += term;
      if (term.abs() < 1e-10) break;
    }

    return (result * sum).clamp(0.0, 1.0);
  }
}

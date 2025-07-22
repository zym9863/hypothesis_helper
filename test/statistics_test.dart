import 'package:flutter_test/flutter_test.dart';
import 'package:hypothesis_helper/services/statistics_service.dart';
import 'package:hypothesis_helper/services/hypothesis_test_service.dart';
import 'package:hypothesis_helper/models/test_input.dart';

void main() {
  group('StatisticsService Tests', () {
    test('计算均值', () {
      List<double> data = [1.0, 2.0, 3.0, 4.0, 5.0];
      double result = StatisticsService.mean(data);
      expect(result, equals(3.0));
    });

    test('计算标准差', () {
      List<double> data = [1.0, 2.0, 3.0, 4.0, 5.0];
      double result = StatisticsService.standardDeviation(data);
      expect(result, closeTo(1.58, 0.01));
    });

    test('计算中位数', () {
      List<double> data1 = [1.0, 2.0, 3.0, 4.0, 5.0];
      double result1 = StatisticsService.median(data1);
      expect(result1, equals(3.0));

      List<double> data2 = [1.0, 2.0, 3.0, 4.0];
      double result2 = StatisticsService.median(data2);
      expect(result2, equals(2.5));
    });

    test('正态分布CDF', () {
      double result = StatisticsService.normalCDF(0.0);
      expect(result, closeTo(0.5, 0.01));
      
      double result2 = StatisticsService.normalCDF(1.96);
      expect(result2, closeTo(0.975, 0.01));
    });
  });

  group('HypothesisTestService Tests', () {
    test('单样本t检验', () async {
      TestInput input = TestInput(
        sample1: [1.0, 2.0, 3.0, 4.0, 5.0],
        alpha: 0.05,
        testType: 'one_sample_t',
        populationMean: 3.0,
      );

      var result = await HypothesisTestService.performTest(input);
      
      expect(result.testType, equals('单样本t检验'));
      expect(result.alpha, equals(0.05));
      expect(result.pValue, isA<double>());
      expect(result.testStatistic, isA<double>());
    });

    test('双样本t检验', () async {
      TestInput input = TestInput(
        sample1: [1.0, 2.0, 3.0, 4.0, 5.0],
        sample2: [2.0, 3.0, 4.0, 5.0, 6.0],
        alpha: 0.05,
        testType: 'two_sample_t',
      );

      var result = await HypothesisTestService.performTest(input);
      
      expect(result.testType, equals('双样本t检验'));
      expect(result.alpha, equals(0.05));
      expect(result.pValue, isA<double>());
      expect(result.testStatistic, isA<double>());
    });

    test('符号检验', () async {
      TestInput input = TestInput(
        sample1: [1.0, 2.0, 3.0, 4.0, 5.0],
        alpha: 0.05,
        testType: 'sign_test',
        populationMean: 2.5,
      );

      var result = await HypothesisTestService.performTest(input);
      
      expect(result.testType, equals('符号检验'));
      expect(result.alpha, equals(0.05));
      expect(result.pValue, isA<double>());
      expect(result.testStatistic, isA<double>());
    });

    test('ANOVA检验', () async {
      TestInput input = TestInput(
        sample1: [], // 不使用
        alpha: 0.05,
        testType: 'anova',
        additionalInfo: {
          'groups': [
            [1.0, 2.0, 3.0],
            [2.0, 3.0, 4.0],
            [3.0, 4.0, 5.0],
          ]
        },
      );

      var result = await HypothesisTestService.performTest(input);
      
      expect(result.testType, equals('单因素方差分析(ANOVA)'));
      expect(result.alpha, equals(0.05));
      expect(result.pValue, isA<double>());
      expect(result.testStatistic, isA<double>());
    });
  });
}

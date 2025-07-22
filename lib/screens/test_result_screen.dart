import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/test_provider.dart';
import '../models/test_result.dart';
import '../widgets/distribution_chart.dart';
import '../widgets/statistics_summary.dart';
import '../widgets/effect_size_chart.dart';

/// 测试结果显示屏幕
class TestResultScreen extends StatelessWidget {
  const TestResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('检验结果'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 实现结果分享功能
            },
          ),
        ],
      ),
      body: Consumer<TestProvider>(
        builder: (context, testProvider, child) {
          if (testProvider.isCalculating) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在计算...'),
                ],
              ),
            );
          }

          if (testProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '计算错误',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    testProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('返回'),
                  ),
                ],
              ),
            );
          }

          final result = testProvider.currentResult;
          if (result == null) {
            return const Center(
              child: Text('没有可显示的结果'),
            );
          }

          return _buildResultContent(context, result);
        },
      ),
    );
  }

  Widget _buildResultContent(BuildContext context, TestResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 结论卡片
          Card(
            color: result.rejectNull ? Colors.red.shade50 : Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    result.rejectNull ? Icons.close : Icons.check,
                    size: 48,
                    color: result.rejectNull ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.rejectNull ? '拒绝原假设' : '不能拒绝原假设',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: result.rejectNull ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.conclusion,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 统计摘要
          StatisticsSummary(result: result),
          const SizedBox(height: 20),

          // 分布图表（仅对t检验和Z检验显示）
          if (_shouldShowDistributionChart(result)) ...[
            DistributionChart(
              distributionType: _getDistributionType(result),
              testStatistic: result.testStatistic,
              pValue: result.pValue,
              alpha: result.alpha,
              degreesOfFreedom: _getDegreesOfFreedom(result),
              alternativeHypothesis: 'two-sided',
            ),
            const SizedBox(height: 20),
          ],

          // 效应大小分析
          if (_shouldShowEffectSize(result)) ...[
            EffectSizeChart(result: result),
            const SizedBox(height: 20),
          ],

          // 统计量信息
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '统计量信息',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildStatisticRow('检验类型', result.testType),
                  _buildStatisticRow(
                    '检验统计量',
                    result.testStatistic.toStringAsFixed(4),
                  ),
                  _buildStatisticRow(
                    'P值',
                    result.pValue.toStringAsFixed(6),
                  ),
                  _buildStatisticRow(
                    '显著性水平 (α)',
                    result.alpha.toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 详细信息
          if (result.additionalInfo.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '详细信息',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...result.additionalInfo.entries.map(
                      (entry) => _buildStatisticRow(
                        _formatKey(entry.key),
                        _formatValue(entry.value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 解释说明
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '结果解释',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getResultExplanation(result),
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('返回首页'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('重新计算'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    const Map<String, String> keyMap = {
      'sample_mean': '样本均值',
      'sample_std': '样本标准差',
      'sample_size': '样本大小',
      'degrees_of_freedom': '自由度',
      'population_mean': '总体均值',
      'population_std': '总体标准差',
      'sample1_mean': '样本1均值',
      'sample2_mean': '样本2均值',
      'sample1_std': '样本1标准差',
      'sample2_std': '样本2标准差',
      'sample1_size': '样本1大小',
      'sample2_size': '样本2大小',
      'pooled_std': '合并标准差',
      'mean_difference': '均值差',
      'std_difference': '差值标准差',
      'positive_count': '正号个数',
      'hypothesized_median': '假设中位数',
      'positive_rank_sum': '正秩和',
      'z_statistic': 'Z统计量',
      'sum_of_squares_between': '组间平方和',
      'sum_of_squares_within': '组内平方和',
      'degrees_of_freedom_between': '组间自由度',
      'degrees_of_freedom_within': '组内自由度',
      'mean_square_between': '组间均方',
      'mean_square_within': '组内均方',
      'grand_mean': '总均值',
      'group_count': '组数',
      'total_sample_size': '总样本量',
    };
    return keyMap[key] ?? key;
  }

  String _formatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(4);
    } else if (value is int) {
      return value.toString();
    } else if (value is List) {
      return value.map((v) => v.toString()).join(', ');
    }
    return value.toString();
  }

  String _getResultExplanation(TestResult result) {
    String explanation = '';
    
    if (result.rejectNull) {
      explanation += 'P值 (${result.pValue.toStringAsFixed(6)}) 小于显著性水平 α (${result.alpha})，';
      explanation += '因此拒绝原假设。这意味着在 ${(result.alpha * 100).toStringAsFixed(1)}% 的显著性水平下，';
      explanation += '有足够的证据支持备择假设。';
    } else {
      explanation += 'P值 (${result.pValue.toStringAsFixed(6)}) 大于或等于显著性水平 α (${result.alpha})，';
      explanation += '因此不能拒绝原假设。这意味着在 ${(result.alpha * 100).toStringAsFixed(1)}% 的显著性水平下，';
      explanation += '没有足够的证据支持备择假设。';
    }
    
    explanation += '\n\nP值表示在原假设为真的条件下，观察到当前或更极端结果的概率。';
    explanation += 'P值越小，表示观察到的结果越不可能是由随机变异引起的。';

    return explanation;
  }

  bool _shouldShowDistributionChart(TestResult result) {
    return ['单样本t检验', '双样本t检验', '配对样本t检验', '单样本Z检验', '双样本Z检验']
        .contains(result.testType);
  }

  String _getDistributionType(TestResult result) {
    if (result.testType.contains('Z检验')) {
      return 'z';
    }
    return 't';
  }

  int? _getDegreesOfFreedom(TestResult result) {
    if (result.additionalInfo.containsKey('degrees_of_freedom')) {
      return result.additionalInfo['degrees_of_freedom'] as int?;
    }
    return null;
  }

  bool _shouldShowEffectSize(TestResult result) {
    return ['单样本t检验', '双样本t检验', '配对样本t检验', '单样本Z检验', '双样本Z检验']
        .contains(result.testType);
  }
}

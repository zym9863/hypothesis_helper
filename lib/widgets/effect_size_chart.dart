import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/test_result.dart';

/// 效应大小可视化组件
class EffectSizeChart extends StatelessWidget {
  final TestResult result;

  const EffectSizeChart({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    double effectSize = _calculateEffectSize();
    String interpretation = _interpretEffectSize(effectSize);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '效应大小分析',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildEffectSizeBar(effectSize),
            const SizedBox(height: 16),
            _buildEffectSizeInfo(effectSize, interpretation),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectSizeBar(double effectSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('小', style: TextStyle(fontSize: 12)),
                const Text('中', style: TextStyle(fontSize: 12)),
                const Text('大', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Colors.green,
                    Colors.yellow,
                    Colors.orange,
                    Colors.red,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // 效应大小指示器
                  Positioned(
                    left: _getEffectSizePosition(effectSize) *
                          (constraints.maxWidth - 30),
                    top: 5,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          effectSize.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('0.2', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const Text('0.5', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const Text('0.8', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const Text('1.0+', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildEffectSizeInfo(double effectSize, String interpretation) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '效应大小: ${effectSize.toStringAsFixed(3)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '解释: $interpretation',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '效应大小衡量的是实际差异的大小，独立于样本量。'
            '即使统计显著，效应大小也可能很小，表示实际意义有限。',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  double _getEffectSizePosition(double effectSize) {
    // 将效应大小映射到0-1的位置
    double clampedEffect = effectSize.clamp(0.0, 1.2);
    return clampedEffect / 1.2;
  }

  double _calculateEffectSize() {
    // 根据检验类型计算效应大小
    switch (result.testType) {
      case '单样本t检验':
      case '双样本t检验':
      case '配对样本t检验':
        return _calculateCohensD();
      case '单样本Z检验':
      case '双样本Z检验':
        return _calculateCohensD();
      default:
        return result.testStatistic.abs() / 10; // 简化处理
    }
  }

  double _calculateCohensD() {
    // Cohen's d 计算
    if (result.additionalInfo.containsKey('sample_std')) {
      double std = result.additionalInfo['sample_std'];
      if (std > 0) {
        return result.testStatistic.abs() / math.sqrt(result.additionalInfo['sample_size'] ?? 1);
      }
    }
    
    if (result.additionalInfo.containsKey('pooled_std')) {
      double pooledStd = result.additionalInfo['pooled_std'];
      if (pooledStd > 0) {
        double mean1 = result.additionalInfo['sample1_mean'] ?? 0;
        double mean2 = result.additionalInfo['sample2_mean'] ?? 0;
        return (mean1 - mean2).abs() / pooledStd;
      }
    }
    
    // 简化计算
    return result.testStatistic.abs() * 0.3;
  }

  String _interpretEffectSize(double effectSize) {
    if (effectSize < 0.2) {
      return '可忽略的效应 - 差异很小，实际意义有限';
    } else if (effectSize < 0.5) {
      return '小效应 - 差异较小，但可能有一定实际意义';
    } else if (effectSize < 0.8) {
      return '中等效应 - 差异明显，具有实际意义';
    } else {
      return '大效应 - 差异很大，具有重要的实际意义';
    }
  }
}



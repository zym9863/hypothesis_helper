import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

/// 分布图表组件
class DistributionChart extends StatelessWidget {
  final String distributionType;
  final double testStatistic;
  final double pValue;
  final double alpha;
  final int? degreesOfFreedom;
  final String alternativeHypothesis;

  const DistributionChart({
    super.key,
    required this.distributionType,
    required this.testStatistic,
    required this.pValue,
    required this.alpha,
    this.degreesOfFreedom,
    this.alternativeHypothesis = 'two-sided',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getChartTitle(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(_buildChart()),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChart() {
    List<FlSpot> distributionSpots = [];
    List<FlSpot> rejectionSpots = [];
    List<FlSpot> pValueSpots = [];
    
    double minX = -4.0;
    double maxX = 4.0;
    double maxY = 0.0;

    // 生成分布曲线数据点
    for (double x = minX; x <= maxX; x += 0.1) {
      double y = _getPDF(x);
      distributionSpots.add(FlSpot(x, y));
      if (y > maxY) maxY = y;
      
      // 拒绝域
      if (_isInRejectionRegion(x)) {
        rejectionSpots.add(FlSpot(x, y));
      }
      
      // P值区域
      if (_isInPValueRegion(x)) {
        pValueSpots.add(FlSpot(x, y));
      }
    }

    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value == testStatistic) {
                return Text(
                  'T=${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                );
              }
              return Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        // 分布曲线
        LineChartBarData(
          spots: distributionSpots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withValues(alpha: 0.1),
          ),
        ),
        // 拒绝域
        if (rejectionSpots.isNotEmpty)
          LineChartBarData(
            spots: rejectionSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 0,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withValues(alpha: 0.3),
            ),
          ),
        // P值区域
        if (pValueSpots.isNotEmpty)
          LineChartBarData(
            spots: pValueSpots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 0,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withValues(alpha: 0.4),
            ),
          ),
      ],
      extraLinesData: ExtraLinesData(
        verticalLines: [
          // 检验统计量线
          VerticalLine(
            x: testStatistic,
            color: Colors.red,
            strokeWidth: 2,
            dashArray: [5, 5],
          ),
        ],
      ),
      minX: minX,
      maxX: maxX,
      minY: 0,
      maxY: maxY * 1.1,
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('分布曲线', Colors.blue),
        _buildLegendItem('拒绝域 (α=${alpha.toStringAsFixed(2)})', Colors.red),
        _buildLegendItem('P值区域 (P=${pValue.toStringAsFixed(4)})', Colors.orange),
        _buildLegendItem('检验统计量', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  String _getChartTitle() {
    String distName = distributionType == 'z' ? '标准正态分布' : 't分布';
    if (distributionType == 't' && degreesOfFreedom != null) {
      distName += ' (df=$degreesOfFreedom)';
    }
    return '$distName - 假设检验可视化';
  }

  double _getPDF(double x) {
    if (distributionType == 'z') {
      return _normalPDF(x);
    } else {
      return _tPDF(x, degreesOfFreedom ?? 10);
    }
  }

  bool _isInRejectionRegion(double x) {
    double criticalValue = _getCriticalValue();
    
    switch (alternativeHypothesis) {
      case 'two-sided':
        return x.abs() >= criticalValue;
      case 'greater':
        return x >= criticalValue;
      case 'less':
        return x <= -criticalValue;
      default:
        return false;
    }
  }

  bool _isInPValueRegion(double x) {
    switch (alternativeHypothesis) {
      case 'two-sided':
        return x.abs() >= testStatistic.abs();
      case 'greater':
        return x >= testStatistic;
      case 'less':
        return x <= testStatistic;
      default:
        return false;
    }
  }

  double _getCriticalValue() {
    // 简化的临界值计算
    if (distributionType == 'z') {
      switch (alternativeHypothesis) {
        case 'two-sided':
          return alpha == 0.05 ? 1.96 : (alpha == 0.01 ? 2.58 : 1.96);
        default:
          return alpha == 0.05 ? 1.645 : (alpha == 0.01 ? 2.33 : 1.645);
      }
    } else {
      // t分布的临界值（简化）
      int df = degreesOfFreedom ?? 10;
      if (df >= 30) {
        return _getCriticalValue(); // 使用z分布近似
      }
      // 这里应该使用t分布表，简化处理
      return alpha == 0.05 ? 2.0 : 2.5;
    }
  }

  double _normalPDF(double x) {
    return (1 / math.sqrt(2 * math.pi)) * math.exp(-0.5 * x * x);
  }

  double _tPDF(double x, int df) {
    double gamma1 = _gamma((df + 1) / 2);
    double gamma2 = _gamma(df / 2);
    double coefficient = gamma1 / (math.sqrt(df * math.pi) * gamma2);
    return coefficient * math.pow(1 + (x * x) / df, -(df + 1) / 2);
  }

  double _gamma(double z) {
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
}

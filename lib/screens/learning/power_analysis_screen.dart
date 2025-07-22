import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../services/statistics_service.dart';

/// 检验效能分析屏幕
class PowerAnalysisScreen extends StatefulWidget {
  const PowerAnalysisScreen({super.key});

  @override
  State<PowerAnalysisScreen> createState() => _PowerAnalysisScreenState();
}

class _PowerAnalysisScreenState extends State<PowerAnalysisScreen> {
  double _alpha = 0.05; // 显著性水平
  double _effectSize = 0.5; // 效应大小 (Cohen's d)
  int _sampleSize = 30; // 样本量
  double _power = 0.0; // 检验效能
  bool _isTwoTailed = true; // 是否双侧检验

  @override
  void initState() {
    super.initState();
    _calculatePower();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('检验效能分析'),
        backgroundColor: Colors.orange.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 介绍卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '检验效能 (Power) 分析',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '检验效能是指当备择假设为真时，正确拒绝原假设的概率。'
                      '它等于 1 - β（β为第二类错误的概率）。',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '当前检验效能: ${(_power * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _power >= 0.8 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 参数控制面板
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '参数设置',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 显著性水平
                    _buildSlider(
                      '显著性水平 (α)',
                      _alpha,
                      0.01,
                      0.10,
                      (value) => setState(() {
                        _alpha = value;
                        _calculatePower();
                      }),
                      '${(_alpha * 100).toStringAsFixed(1)}%',
                    ),

                    // 效应大小
                    _buildSlider(
                      '效应大小 (Cohen\'s d)',
                      _effectSize,
                      0.1,
                      2.0,
                      (value) => setState(() {
                        _effectSize = value;
                        _calculatePower();
                      }),
                      _effectSize.toStringAsFixed(2),
                    ),

                    // 样本量
                    _buildSlider(
                      '样本量 (n)',
                      _sampleSize.toDouble(),
                      10,
                      200,
                      (value) => setState(() {
                        _sampleSize = value.round();
                        _calculatePower();
                      }),
                      _sampleSize.toString(),
                    ),

                    // 检验类型
                    Row(
                      children: [
                        const Text('检验类型: '),
                        Radio<bool>(
                          value: true,
                          groupValue: _isTwoTailed,
                          onChanged: (value) => setState(() {
                            _isTwoTailed = true;
                            _calculatePower();
                          }),
                        ),
                        const Text('双侧检验'),
                        Radio<bool>(
                          value: false,
                          groupValue: _isTwoTailed,
                          onChanged: (value) => setState(() {
                            _isTwoTailed = false;
                            _calculatePower();
                          }),
                        ),
                        const Text('单侧检验'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 效能曲线图
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '检验效能曲线',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: LineChart(_buildPowerCurveChart()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 样本量分析图
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '样本量与检验效能关系',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: LineChart(_buildSampleSizePowerChart()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 效应大小说明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cohen\'s d 效应大小解释',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildEffectSizeInfo('小效应', '0.2', Colors.blue),
                    _buildEffectSizeInfo('中等效应', '0.5', Colors.orange),
                    _buildEffectSizeInfo('大效应', '0.8', Colors.red),
                    const SizedBox(height: 8),
                    const Text(
                      '一般认为检验效能≥80%为合适的水平',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String displayValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              displayValue,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: Colors.orange,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEffectSizeInfo(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 8),
          Text('$label: d = $value'),
        ],
      ),
    );
  }

  LineChartData _buildPowerCurveChart() {
    List<FlSpot> spots = [];
    for (double d = 0.1; d <= 2.0; d += 0.1) {
      double power = _calculatePowerForEffectSize(d);
      spots.add(FlSpot(d, power));
    }

    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('${(value * 100).toInt()}%');
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text(value.toStringAsFixed(1));
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.orange,
          barWidth: 3,
          dotData: FlDotData(show: false),
        ),
        // 当前效应大小的点
        LineChartBarData(
          spots: [FlSpot(_effectSize, _power)],
          isCurved: false,
          color: Colors.red,
          barWidth: 0,
          dotData: FlDotData(show: true),
        ),
      ],
      minX: 0.1,
      maxX: 2.0,
      minY: 0,
      maxY: 1,
    );
  }

  LineChartData _buildSampleSizePowerChart() {
    List<FlSpot> spots = [];
    for (int n = 10; n <= 200; n += 5) {
      double power = _calculatePowerForSampleSize(n);
      spots.add(FlSpot(n.toDouble(), power));
    }

    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('${(value * 100).toInt()}%');
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString());
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          dotData: FlDotData(show: false),
        ),
        // 当前样本量的点
        LineChartBarData(
          spots: [FlSpot(_sampleSize.toDouble(), _power)],
          isCurved: false,
          color: Colors.red,
          barWidth: 0,
          dotData: FlDotData(show: true),
        ),
        // 80%效能线
        LineChartBarData(
          spots: [FlSpot(10, 0.8), FlSpot(200, 0.8)],
          isCurved: false,
          color: Colors.green,
          barWidth: 2,
          dashArray: [5, 5],
          dotData: FlDotData(show: false),
        ),
      ],
      minX: 10,
      maxX: 200,
      minY: 0,
      maxY: 1,
    );
  }

  void _calculatePower() {
    _power = _calculatePowerForEffectSize(_effectSize);
  }

  double _calculatePowerForEffectSize(double effectSize) {
    return _calculatePowerForSampleSize(_sampleSize, effectSize: effectSize);
  }

  double _calculatePowerForSampleSize(int n, {double? effectSize}) {
    double d = effectSize ?? _effectSize;
    
    // 计算非中心性参数
    double ncp = d * math.sqrt(n / 2);
    
    // 计算临界值
    double criticalValue;
    if (_isTwoTailed) {
      criticalValue = _getZCritical(_alpha / 2);
    } else {
      criticalValue = _getZCritical(_alpha);
    }
    
    // 计算检验效能
    double power;
    if (_isTwoTailed) {
      // 双侧检验
      power = 1 - StatisticsService.normalCDF(criticalValue - ncp) + 
              StatisticsService.normalCDF(-criticalValue - ncp);
    } else {
      // 单侧检验
      power = 1 - StatisticsService.normalCDF(criticalValue - ncp);
    }
    
    return math.max(0, math.min(1, power));
  }

  double _getZCritical(double alpha) {
    // 使用二分法近似求解标准正态分布的临界值
    double low = -5.0;
    double high = 5.0;
    double tolerance = 1e-6;
    
    while (high - low > tolerance) {
      double mid = (low + high) / 2;
      if (StatisticsService.normalCDF(mid) < 1 - alpha) {
        low = mid;
      } else {
        high = mid;
      }
    }
    
    return (low + high) / 2;
  }
}

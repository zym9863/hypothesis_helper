import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

/// P值可视化学习屏幕
class PValueVisualizationScreen extends StatefulWidget {
  const PValueVisualizationScreen({super.key});

  @override
  State<PValueVisualizationScreen> createState() => _PValueVisualizationScreenState();
}

class _PValueVisualizationScreenState extends State<PValueVisualizationScreen> {
  double _testStatistic = 1.96;
  double _alpha = 0.05;
  String _testType = 'z';
  int _degreesOfFreedom = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P值可视化'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 说明卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'P值可视化',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'P值是在原假设为真的条件下，观察到当前或更极端结果的概率。'
                      '图中阴影区域表示P值的大小。',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 控制面板
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('分布类型: '),
                        DropdownButton<String>(
                          value: _testType,
                          items: const [
                            DropdownMenuItem(value: 'z', child: Text('标准正态分布')),
                            DropdownMenuItem(value: 't', child: Text('t分布')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _testType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_testType == 't') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('自由度: '),
                          Expanded(
                            child: Slider(
                              value: _degreesOfFreedom.toDouble(),
                              min: 1,
                              max: 30,
                              divisions: 29,
                              label: _degreesOfFreedom.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _degreesOfFreedom = value.round();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('检验统计量: '),
                        Expanded(
                          child: Slider(
                            value: _testStatistic,
                            min: -4.0,
                            max: 4.0,
                            divisions: 80,
                            label: _testStatistic.toStringAsFixed(2),
                            onChanged: (value) {
                              setState(() {
                                _testStatistic = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('显著性水平 (α): '),
                        Expanded(
                          child: Slider(
                            value: _alpha,
                            min: 0.01,
                            max: 0.10,
                            divisions: 9,
                            label: _alpha.toStringAsFixed(2),
                            onChanged: (value) {
                              setState(() {
                                _alpha = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 图表
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '${_testType == 'z' ? '标准正态' : 't'}分布图',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LineChart(_buildChart()),
                      ),
                      const SizedBox(height: 16),
                      _buildStatistics(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChart() {
    List<FlSpot> distributionSpots = [];
    List<FlSpot> pValueSpots = [];
    
    // 生成分布曲线数据点
    for (double x = -4.0; x <= 4.0; x += 0.1) {
      double y = _testType == 'z' 
          ? _normalPDF(x) 
          : _tPDF(x, _degreesOfFreedom);
      distributionSpots.add(FlSpot(x, y));
      
      // P值区域（双侧检验）
      if (x.abs() >= _testStatistic.abs()) {
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
        // P值区域
        LineChartBarData(
          spots: pValueSpots,
          isCurved: true,
          color: Colors.red,
          barWidth: 0,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.red.withValues(alpha: 0.3),
          ),
        ),
      ],
      minX: -4.0,
      maxX: 4.0,
      minY: 0,
      maxY: 0.5,
    );
  }

  Widget _buildStatistics() {
    double pValue = _calculatePValue();
    bool rejectNull = pValue < _alpha;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('检验统计量'),
                Text(
                  _testStatistic.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text('P值'),
                Text(
                  pValue.toStringAsFixed(4),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: rejectNull ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text('结论'),
                Text(
                  rejectNull ? '拒绝H₀' : '不拒绝H₀',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: rejectNull ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          rejectNull 
              ? 'P值 (${pValue.toStringAsFixed(4)}) < α (${_alpha.toStringAsFixed(2)})，拒绝原假设'
              : 'P值 (${pValue.toStringAsFixed(4)}) ≥ α (${_alpha.toStringAsFixed(2)})，不能拒绝原假设',
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  double _normalPDF(double x) {
    return (1 / math.sqrt(2 * math.pi)) * math.exp(-0.5 * x * x);
  }

  double _tPDF(double x, int df) {
    // 简化的t分布概率密度函数
    double gamma1 = _gamma((df + 1) / 2);
    double gamma2 = _gamma(df / 2);
    double coefficient = gamma1 / (math.sqrt(df * math.pi) * gamma2);
    return coefficient * math.pow(1 + (x * x) / df, -(df + 1) / 2);
  }

  double _gamma(double z) {
    // 简化的Gamma函数实现
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

  double _calculatePValue() {
    // 双侧检验的P值计算
    if (_testType == 'z') {
      return 2 * (1 - _normalCDF(_testStatistic.abs()));
    } else {
      return 2 * (1 - _tCDF(_testStatistic.abs(), _degreesOfFreedom));
    }
  }

  double _normalCDF(double z) {
    return 0.5 * (1 + _erf(z / math.sqrt(2)));
  }

  double _erf(double x) {
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

  double _tCDF(double t, int df) {
    if (df >= 30) {
      return _normalCDF(t);
    }
    
    // 简化的t分布CDF
    double x = t / math.sqrt(df);
    return 0.5 + 0.5 * _erf(x / math.sqrt(2));
  }
}

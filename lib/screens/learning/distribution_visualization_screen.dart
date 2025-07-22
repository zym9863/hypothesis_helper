import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

/// 概率分布可视化屏幕
class DistributionVisualizationScreen extends StatefulWidget {
  const DistributionVisualizationScreen({super.key});

  @override
  State<DistributionVisualizationScreen> createState() => _DistributionVisualizationScreenState();
}

class _DistributionVisualizationScreenState extends State<DistributionVisualizationScreen> {
  String _distributionType = 'normal';
  double _parameter1 = 0.0; // 均值或自由度
  double _parameter2 = 1.0; // 标准差或第二个参数

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('概率分布可视化'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                          value: _distributionType,
                          items: const [
                            DropdownMenuItem(value: 'normal', child: Text('正态分布')),
                            DropdownMenuItem(value: 't', child: Text('t分布')),
                            DropdownMenuItem(value: 'chi_square', child: Text('卡方分布')),
                            DropdownMenuItem(value: 'f', child: Text('F分布')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _distributionType = value!;
                              _resetParameters();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildParameterControls(),
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
                        _getDistributionTitle(),
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
                      _buildDistributionInfo(),
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

  Widget _buildParameterControls() {
    switch (_distributionType) {
      case 'normal':
        return Column(
          children: [
            Row(
              children: [
                const Text('均值 (μ): '),
                Expanded(
                  child: Slider(
                    value: _parameter1,
                    min: -3.0,
                    max: 3.0,
                    divisions: 60,
                    label: _parameter1.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _parameter1 = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('标准差 (σ): '),
                Expanded(
                  child: Slider(
                    value: _parameter2,
                    min: 0.5,
                    max: 3.0,
                    divisions: 25,
                    label: _parameter2.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _parameter2 = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      case 't':
        return Row(
          children: [
            const Text('自由度 (df): '),
            Expanded(
              child: Slider(
                value: _parameter1,
                min: 1,
                max: 30,
                divisions: 29,
                label: _parameter1.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _parameter1 = value;
                  });
                },
              ),
            ),
          ],
        );
      case 'chi_square':
        return Row(
          children: [
            const Text('自由度 (df): '),
            Expanded(
              child: Slider(
                value: _parameter1,
                min: 1,
                max: 20,
                divisions: 19,
                label: _parameter1.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _parameter1 = value;
                  });
                },
              ),
            ),
          ],
        );
      case 'f':
        return Column(
          children: [
            Row(
              children: [
                const Text('分子自由度 (df1): '),
                Expanded(
                  child: Slider(
                    value: _parameter1,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: _parameter1.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _parameter1 = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('分母自由度 (df2): '),
                Expanded(
                  child: Slider(
                    value: _parameter2,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: _parameter2.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _parameter2 = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  LineChartData _buildChart() {
    List<FlSpot> spots = [];
    double minX = -4.0, maxX = 4.0, maxY = 0;

    switch (_distributionType) {
      case 'normal':
        minX = _parameter1 - 4 * _parameter2;
        maxX = _parameter1 + 4 * _parameter2;
        for (double x = minX; x <= maxX; x += (maxX - minX) / 200) {
          double y = _normalPDF(x, _parameter1, _parameter2);
          spots.add(FlSpot(x, y));
          if (y > maxY) maxY = y;
        }
        break;
      case 't':
        minX = -4.0;
        maxX = 4.0;
        for (double x = minX; x <= maxX; x += 0.1) {
          double y = _tPDF(x, _parameter1.round());
          spots.add(FlSpot(x, y));
          if (y > maxY) maxY = y;
        }
        break;
      case 'chi_square':
        minX = 0.0;
        maxX = _parameter1 * 3;
        for (double x = 0.1; x <= maxX; x += maxX / 200) {
          double y = _chiSquarePDF(x, _parameter1.round());
          spots.add(FlSpot(x, y));
          if (y > maxY) maxY = y;
        }
        break;
      case 'f':
        minX = 0.0;
        maxX = 5.0;
        for (double x = 0.1; x <= maxX; x += 0.05) {
          double y = _fPDF(x, _parameter1.round(), _parameter2.round());
          spots.add(FlSpot(x, y));
          if (y > maxY) maxY = y;
        }
        break;
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
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withValues(alpha: 0.1),
          ),
        ),
      ],
      minX: minX,
      maxX: maxX,
      minY: 0,
      maxY: maxY * 1.1,
    );
  }

  Widget _buildDistributionInfo() {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getDistributionDescription(),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              _getDistributionProperties(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _resetParameters() {
    switch (_distributionType) {
      case 'normal':
        _parameter1 = 0.0;
        _parameter2 = 1.0;
        break;
      case 't':
        _parameter1 = 10.0;
        _parameter2 = 1.0;
        break;
      case 'chi_square':
        _parameter1 = 5.0;
        _parameter2 = 1.0;
        break;
      case 'f':
        _parameter1 = 5.0;
        _parameter2 = 10.0;
        break;
    }
  }

  String _getDistributionTitle() {
    switch (_distributionType) {
      case 'normal':
        return '正态分布 N(${_parameter1.toStringAsFixed(1)}, ${_parameter2.toStringAsFixed(1)}²)';
      case 't':
        return 't分布 (df = ${_parameter1.round()})';
      case 'chi_square':
        return '卡方分布 χ²(${_parameter1.round()})';
      case 'f':
        return 'F分布 F(${_parameter1.round()}, ${_parameter2.round()})';
      default:
        return '';
    }
  }

  String _getDistributionDescription() {
    switch (_distributionType) {
      case 'normal':
        return '正态分布是最重要的连续概率分布，具有钟形曲线的特征。许多自然现象都近似服从正态分布。';
      case 't':
        return 't分布用于小样本的均值检验。当样本量较小且总体标准差未知时使用。随着自由度增加，t分布趋近于标准正态分布。';
      case 'chi_square':
        return '卡方分布常用于拟合优度检验和独立性检验。它是右偏分布，取值范围为非负数。';
      case 'f':
        return 'F分布用于方差分析(ANOVA)和方差齐性检验。它是两个卡方分布的比值分布。';
      default:
        return '';
    }
  }

  String _getDistributionProperties() {
    switch (_distributionType) {
      case 'normal':
        return '均值: ${_parameter1.toStringAsFixed(1)}, 标准差: ${_parameter2.toStringAsFixed(1)}, 方差: ${(_parameter2 * _parameter2).toStringAsFixed(1)}';
      case 't':
        int df = _parameter1.round();
        return '自由度: $df, 均值: 0 (df > 1), 方差: ${df > 2 ? (df / (df - 2)).toStringAsFixed(2) : '未定义'}';
      case 'chi_square':
        int df = _parameter1.round();
        return '自由度: $df, 均值: $df, 方差: ${2 * df}';
      case 'f':
        int df1 = _parameter1.round();
        int df2 = _parameter2.round();
        return '自由度: ($df1, $df2), 均值: ${df2 > 2 ? (df2 / (df2 - 2)).toStringAsFixed(2) : '未定义'}';
      default:
        return '';
    }
  }

  double _normalPDF(double x, double mu, double sigma) {
    return (1 / (sigma * math.sqrt(2 * math.pi))) * 
           math.exp(-0.5 * math.pow((x - mu) / sigma, 2));
  }

  double _tPDF(double x, int df) {
    double gamma1 = _gamma((df + 1) / 2);
    double gamma2 = _gamma(df / 2);
    double coefficient = gamma1 / (math.sqrt(df * math.pi) * gamma2);
    return coefficient * math.pow(1 + (x * x) / df, -(df + 1) / 2);
  }

  double _chiSquarePDF(double x, int df) {
    if (x <= 0) return 0;
    double coefficient = 1 / (math.pow(2, df / 2) * _gamma(df / 2));
    return coefficient * math.pow(x, df / 2 - 1) * math.exp(-x / 2);
  }

  double _fPDF(double x, int df1, int df2) {
    if (x <= 0) return 0;
    double gamma1 = _gamma((df1 + df2) / 2);
    double gamma2 = _gamma(df1 / 2);
    double gamma3 = _gamma(df2 / 2);
    double coefficient = (gamma1 / (gamma2 * gamma3)) * 
                        math.pow(df1 / df2, df1 / 2);
    return coefficient * math.pow(x, df1 / 2 - 1) * 
           math.pow(1 + (df1 * x) / df2, -(df1 + df2) / 2);
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

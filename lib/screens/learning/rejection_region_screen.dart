import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../services/statistics_service.dart';

/// 拒绝域可视化屏幕
class RejectionRegionScreen extends StatefulWidget {
  const RejectionRegionScreen({super.key});

  @override
  State<RejectionRegionScreen> createState() => _RejectionRegionScreenState();
}

class _RejectionRegionScreenState extends State<RejectionRegionScreen> {
  double _alpha = 0.05; // 显著性水平
  bool _isTwoTailed = true; // 是否双侧检验
  String _distributionType = 'normal'; // normal, t, chi-square
  int _degreesOfFreedom = 10; // 自由度（用于t分布和卡方分布）
  double _testStatistic = 1.5; // 检验统计量
  bool _showTestStatistic = true; // 是否显示检验统计量

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('拒绝域可视化'),
        backgroundColor: Colors.teal.shade100,
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
                      '拒绝域可视化',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '拒绝域是指当检验统计量落在该区域内时，我们拒绝原假设的区域。'
                      '拒绝域的大小由显著性水平（α）决定。',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '当前设置：α = ${(_alpha * 100).toStringAsFixed(1)}%，'
                      '${_isTwoTailed ? '双侧' : '单侧'}检验',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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

                    // 分布类型选择
                    const Text('选择分布类型：'),
                    DropdownButton<String>(
                      value: _distributionType,
                      onChanged: (value) => setState(() {
                        _distributionType = value!;
                      }),
                      items: const [
                        DropdownMenuItem(value: 'normal', child: Text('标准正态分布')),
                        DropdownMenuItem(value: 't', child: Text('t分布')),
                        DropdownMenuItem(value: 'chi-square', child: Text('卡方分布')),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 自由度设置（仅对t分布和卡方分布）
                    if (_distributionType != 'normal') ...[
                      Text('自由度: $_degreesOfFreedom'),
                      Slider(
                        value: _degreesOfFreedom.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        onChanged: (value) => setState(() {
                          _degreesOfFreedom = value.round();
                        }),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 显著性水平
                    Text('显著性水平: ${(_alpha * 100).toStringAsFixed(1)}%'),
                    Slider(
                      value: _alpha,
                      min: 0.01,
                      max: 0.10,
                      onChanged: (value) => setState(() {
                        _alpha = value;
                      }),
                    ),

                    // 常用显著性水平快速选择
                    const Text('常用水平：'),
                    Wrap(
                      spacing: 8,
                      children: [0.01, 0.05, 0.10].map((alpha) {
                        return ChoiceChip(
                          label: Text('${(alpha * 100).toInt()}%'),
                          selected: _alpha == alpha,
                          onSelected: (selected) => setState(() {
                            if (selected) _alpha = alpha;
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 检验类型
                    const Text('检验类型：'),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _isTwoTailed,
                          onChanged: (value) => setState(() {
                            _isTwoTailed = true;
                          }),
                        ),
                        const Text('双侧检验'),
                        Radio<bool>(
                          value: false,
                          groupValue: _isTwoTailed,
                          onChanged: (value) => setState(() {
                            _isTwoTailed = false;
                          }),
                        ),
                        const Text('单侧检验'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 检验统计量
                    if (_distributionType != 'chi-square') ...[
                      Text('检验统计量: ${_testStatistic.toStringAsFixed(2)}'),
                      Slider(
                        value: _testStatistic,
                        min: -4.0,
                        max: 4.0,
                        onChanged: (value) => setState(() {
                          _testStatistic = value;
                        }),
                      ),
                    ] else ...[
                      Text('检验统计量: ${_testStatistic.toStringAsFixed(2)}'),
                      Slider(
                        value: _testStatistic,
                        min: 0.0,
                        max: 20.0,
                        onChanged: (value) => setState(() {
                          _testStatistic = value;
                        }),
                      ),
                    ],

                    // 是否显示检验统计量
                    CheckboxListTile(
                      title: const Text('显示检验统计量位置'),
                      value: _showTestStatistic,
                      onChanged: (value) => setState(() {
                        _showTestStatistic = value!;
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 拒绝域可视化图表
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '拒绝域可视化',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400,
                      child: LineChart(_buildRejectionRegionChart()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 临界值和拒绝域信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '拒绝域信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRejectionInfo(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 决策结果
            if (_showTestStatistic) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '统计决策',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDecisionInfo(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 不同分布的比较
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '分布比较',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: LineChart(_buildDistributionComparisonChart()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 交互式示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '交互式示例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '调整上面的参数，观察拒绝域如何变化：',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _buildInteractiveExamples(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionInfo() {
    List<double> criticalValues = _getCriticalValues();
    bool inRejectionRegion = _isInRejectionRegion();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inRejectionRegion ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: inRejectionRegion ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('分布类型：${_getDistributionName()}'),
          if (_distributionType != 'normal')
            Text('自由度：$_degreesOfFreedom'),
          Text('显著性水平：α = ${(_alpha * 100).toStringAsFixed(1)}%'),
          Text('检验类型：${_isTwoTailed ? '双侧检验' : '单侧检验'}'),
          const SizedBox(height: 8),
          
          if (_distributionType == 'chi-square') ...[
            Text('临界值：${criticalValues[0].toStringAsFixed(4)}'),
            Text('拒绝域：X² > ${criticalValues[0].toStringAsFixed(4)}'),
          ] else if (_isTwoTailed) ...[
            Text('临界值：±${criticalValues[0].toStringAsFixed(4)}'),
            Text('拒绝域：X < ${(-criticalValues[0]).toStringAsFixed(4)} 或 X > ${criticalValues[0].toStringAsFixed(4)}'),
          ] else ...[
            Text('临界值：${criticalValues[0].toStringAsFixed(4)}'),
            Text('拒绝域：X > ${criticalValues[0].toStringAsFixed(4)}'),
          ],
          
          const SizedBox(height: 8),
          Text(
            '拒绝域面积：${(_alpha * 100).toStringAsFixed(1)}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionInfo() {
    bool inRejectionRegion = _isInRejectionRegion();
    double pValue = _calculatePValue();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inRejectionRegion ? Colors.red.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: inRejectionRegion ? Colors.red.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '检验统计量：${_testStatistic.toStringAsFixed(4)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'P值：${pValue.toStringAsFixed(4)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            inRejectionRegion ? '拒绝原假设 H₀' : '不拒绝原假设 H₀',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: inRejectionRegion ? Colors.red : Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            inRejectionRegion 
              ? '检验统计量落在拒绝域内'
              : '检验统计量落在接受域内',
          ),
          Text(
            'P值 ${pValue < _alpha ? '<' : '≥'} α (${_alpha.toStringAsFixed(3)})',
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• 增大α → 拒绝域变大 → 更容易拒绝H₀',
          style: TextStyle(fontSize: 14),
        ),
        const Text(
          '• 双侧检验 → 拒绝域分布在两侧',
          style: TextStyle(fontSize: 14),
        ),
        const Text(
          '• 单侧检验 → 拒绝域集中在一侧',
          style: TextStyle(fontSize: 14),
        ),
        const Text(
          '• t分布 → 自由度越小，尾部越厚',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          '试试改变不同参数，观察拒绝域的变化！',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  LineChartData _buildRejectionRegionChart() {
    List<FlSpot> distributionSpots = [];
    List<FlSpot> rejectionSpots = [];
    
    double min = _distributionType == 'chi-square' ? 0 : -4.0;
    double max = _distributionType == 'chi-square' ? 20 : 4.0;
    double step = (max - min) / 400;
    
    List<double> criticalValues = _getCriticalValues();
    
    for (double x = min; x <= max; x += step) {
      double y = _getDistributionPDF(x);
      distributionSpots.add(FlSpot(x, y));
      
      // 判断是否在拒绝域内
      bool inRejection = false;
      if (_distributionType == 'chi-square') {
        inRejection = x >= criticalValues[0];
      } else if (_isTwoTailed) {
        inRejection = x <= -criticalValues[0] || x >= criticalValues[0];
      } else {
        inRejection = x >= criticalValues[0];
      }
      
      if (inRejection) {
        rejectionSpots.add(FlSpot(x, y));
      }
    }

    List<LineChartBarData> lineBarsData = [
      // 分布曲线
      LineChartBarData(
        spots: distributionSpots,
        isCurved: true,
        color: Colors.blue,
        barWidth: 2,
        dotData: FlDotData(show: false),
      ),
      // 拒绝域填充
      if (rejectionSpots.isNotEmpty)
        LineChartBarData(
          spots: rejectionSpots,
          isCurved: true,
          color: Colors.red.withOpacity(0.7),
          barWidth: 0,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.red.withOpacity(0.3),
          ),
        ),
    ];

    // 添加临界值线
    for (double criticalValue in criticalValues) {
      lineBarsData.add(
        LineChartBarData(
          spots: [
            FlSpot(criticalValue, 0),
            FlSpot(criticalValue, _getDistributionPDF(criticalValue)),
          ],
          isCurved: false,
          color: Colors.orange,
          barWidth: 2,
          dotData: FlDotData(show: false),
          dashArray: [5, 5],
        ),
      );
      
      if (_isTwoTailed && _distributionType != 'chi-square') {
        lineBarsData.add(
          LineChartBarData(
            spots: [
              FlSpot(-criticalValue, 0),
              FlSpot(-criticalValue, _getDistributionPDF(-criticalValue)),
            ],
            isCurved: false,
            color: Colors.orange,
            barWidth: 2,
            dotData: FlDotData(show: false),
            dashArray: [5, 5],
          ),
        );
      }
    }

    // 添加检验统计量线
    if (_showTestStatistic) {
      lineBarsData.add(
        LineChartBarData(
          spots: [
            FlSpot(_testStatistic, 0),
            FlSpot(_testStatistic, _getDistributionPDF(_testStatistic)),
          ],
          isCurved: false,
          color: _isInRejectionRegion() ? Colors.red : Colors.green,
          barWidth: 3,
          dotData: FlDotData(show: false),
        ),
      );
    }

    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: lineBarsData,
      minX: min,
      maxX: max,
      minY: 0,
    );
  }

  LineChartData _buildDistributionComparisonChart() {
    List<FlSpot> normalSpots = [];
    List<FlSpot> tSpots = [];
    List<FlSpot> currentSpots = [];
    
    double min = -4.0;
    double max = 4.0;
    double step = 0.1;
    
    for (double x = min; x <= max; x += step) {
      // 标准正态分布
      double normalY = (1 / math.sqrt(2 * math.pi)) * math.exp(-0.5 * x * x);
      normalSpots.add(FlSpot(x, normalY));
      
      // t分布
      double tY = _getTDistributionPDF(x, 5);
      tSpots.add(FlSpot(x, tY));
      
      // 当前选择的分布
      if (_distributionType != 'chi-square') {
        double currentY = _getDistributionPDF(x);
        currentSpots.add(FlSpot(x, currentY));
      }
    }

    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
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
        // 标准正态分布
        LineChartBarData(
          spots: normalSpots,
          isCurved: true,
          color: Colors.blue.withOpacity(0.7),
          barWidth: 2,
          dotData: FlDotData(show: false),
        ),
        // t分布
        LineChartBarData(
          spots: tSpots,
          isCurved: true,
          color: Colors.green.withOpacity(0.7),
          barWidth: 2,
          dotData: FlDotData(show: false),
          dashArray: [5, 5],
        ),
        // 当前分布（如果不是卡方分布）
        if (_distributionType != 'chi-square')
          LineChartBarData(
            spots: currentSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
      ],
      minX: min,
      maxX: max,
      minY: 0,
    );
  }

  String _getDistributionName() {
    switch (_distributionType) {
      case 'normal':
        return '标准正态分布';
      case 't':
        return 't分布';
      case 'chi-square':
        return '卡方分布';
      default:
        return '未知分布';
    }
  }

  List<double> _getCriticalValues() {
    switch (_distributionType) {
      case 'normal':
        return [_getZCritical(_isTwoTailed ? _alpha / 2 : _alpha)];
      case 't':
        return [_getTCritical(_isTwoTailed ? _alpha / 2 : _alpha, _degreesOfFreedom)];
      case 'chi-square':
        return [_getChiSquareCritical(_alpha, _degreesOfFreedom)];
      default:
        return [1.96];
    }
  }

  double _getDistributionPDF(double x) {
    switch (_distributionType) {
      case 'normal':
        return (1 / math.sqrt(2 * math.pi)) * math.exp(-0.5 * x * x);
      case 't':
        return _getTDistributionPDF(x, _degreesOfFreedom);
      case 'chi-square':
        return _getChiSquarePDF(x, _degreesOfFreedom);
      default:
        return 0;
    }
  }

  double _getTDistributionPDF(double x, int df) {
    double gamma1 = _approximateGamma((df + 1) / 2);
    double gamma2 = _approximateGamma(df / 2);
    double coeff = gamma1 / (math.sqrt(df * math.pi) * gamma2);
    return coeff * math.pow(1 + (x * x) / df, -(df + 1) / 2);
  }

  double _getChiSquarePDF(double x, int df) {
    if (x <= 0) return 0;
    double coeff = 1 / (math.pow(2, df / 2) * _approximateGamma(df / 2));
    return coeff * math.pow(x, df / 2 - 1) * math.exp(-x / 2);
  }

  double _approximateGamma(double z) {
    if (z < 1) return _approximateGamma(z + 1) / z;
    return math.sqrt(2 * math.pi / z) * math.pow(z / math.e, z);
  }

  double _getZCritical(double alpha) {
    if (alpha <= 0.005) return 2.576;
    if (alpha <= 0.01) return 2.326;
    if (alpha <= 0.025) return 1.960;
    if (alpha <= 0.05) return 1.645;
    if (alpha <= 0.10) return 1.282;
    return 1.0;
  }

  double _getTCritical(double alpha, int df) {
    double z = _getZCritical(alpha);
    if (df >= 30) return z;
    
    // 简化的t分布临界值近似
    double adjustment = 1 + (4 / (4 * df + 1));
    return z * adjustment;
  }

  double _getChiSquareCritical(double alpha, int df) {
    // 简化的卡方分布临界值近似
    // 这里使用威尔逊-希尔菲尔蒂变换的近似
    double h = 2.0 / (9.0 * df);
    double z = _getZCritical(alpha);
    return (df * math.pow(1 - h + z * math.sqrt(h), 3)).toDouble();
  }

  bool _isInRejectionRegion() {
    List<double> criticalValues = _getCriticalValues();
    
    if (_distributionType == 'chi-square') {
      return _testStatistic >= criticalValues[0];
    } else if (_isTwoTailed) {
      return _testStatistic <= -criticalValues[0] || _testStatistic >= criticalValues[0];
    } else {
      return _testStatistic >= criticalValues[0];
    }
  }

  double _calculatePValue() {
    switch (_distributionType) {
      case 'normal':
        if (_isTwoTailed) {
          return 2 * (1 - StatisticsService.normalCDF(_testStatistic.abs()));
        } else {
          return 1 - StatisticsService.normalCDF(_testStatistic);
        }
      case 't':
        if (_isTwoTailed) {
          return 2 * (1 - StatisticsService.tCDF(_testStatistic.abs(), _degreesOfFreedom));
        } else {
          return 1 - StatisticsService.tCDF(_testStatistic, _degreesOfFreedom);
        }
      case 'chi-square':
        return 1 - StatisticsService.chiSquareCDF(_testStatistic, _degreesOfFreedom);
      default:
        return 0.5;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../services/statistics_service.dart';

/// 假设检验步骤学习屏幕
class HypothesisStepsScreen extends StatefulWidget {
  const HypothesisStepsScreen({super.key});

  @override
  State<HypothesisStepsScreen> createState() => _HypothesisStepsScreenState();
}

class _HypothesisStepsScreenState extends State<HypothesisStepsScreen> {
  int _currentStep = 0;
  double _alpha = 0.05;
  double _sampleMean = 0.0;
  double _populationMean = 0.0;
  double _sampleStd = 1.0;
  int _sampleSize = 30;
  double _testStatistic = 0.0;
  double _pValue = 0.5;
  bool _isTwoTailed = true;
  String _testType = 'z-test'; // z-test, t-test
  String _hypothesisType = 'mean'; // mean, proportion

  final List<String> _steps = [
    '第1步：建立假设',
    '第2步：选择显著性水平',
    '第3步：选择检验方法',
    '第4步：计算检验统计量',
    '第5步：确定拒绝域',
    '第6步：做出统计决策',
    '第7步：得出结论',
  ];

  @override
  void initState() {
    super.initState();
    _calculateTestStatistic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('假设检验步骤'),
        backgroundColor: Colors.green.shade100,
      ),
      body: Column(
        children: [
          // 步骤进度指示器
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_steps.length, (index) {
                return _buildStepIndicator(index);
              }),
            ),
          ),
          
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildStepContent(),
            ),
          ),
          
          // 导航按钮
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentStep > 0 ? _previousStep : null,
                  child: const Text('上一步'),
                ),
                Text(
                  '第 ${_currentStep + 1} 步 / ${_steps.length} 步',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _currentStep < _steps.length - 1 ? _nextStep : null,
                  child: const Text('下一步'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int index) {
    bool isActive = index <= _currentStep;
    bool isCurrent = index == _currentStep;
    
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green : Colors.grey.shade300,
        border: Border.all(
          color: isCurrent ? Colors.green.shade700 : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1(); // 建立假设
      case 1:
        return _buildStep2(); // 选择显著性水平
      case 2:
        return _buildStep3(); // 选择检验方法
      case 3:
        return _buildStep4(); // 计算检验统计量
      case 4:
        return _buildStep5(); // 确定拒绝域
      case 5:
        return _buildStep6(); // 做出统计决策
      case 6:
        return _buildStep7(); // 得出结论
      default:
        return Container();
    }
  }

  Widget _buildStep1() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '第1步：建立假设',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '假设检验需要建立原假设（H₀）和备择假设（H₁）：',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // 假设类型选择
            const Text('选择检验类型：'),
            RadioListTile<String>(
              title: const Text('均值检验'),
              value: 'mean',
              groupValue: _hypothesisType,
              onChanged: (value) => setState(() {
                _hypothesisType = value!;
              }),
            ),
            RadioListTile<String>(
              title: const Text('比例检验'),
              value: 'proportion',
              groupValue: _hypothesisType,
              onChanged: (value) => setState(() {
                _hypothesisType = value!;
              }),
            ),
            
            const SizedBox(height: 16),
            
            // 假设方向选择
            const Text('选择假设方向：'),
            RadioListTile<bool>(
              title: const Text('双侧检验 (μ ≠ μ₀)'),
              value: true,
              groupValue: _isTwoTailed,
              onChanged: (value) => setState(() {
                _isTwoTailed = value!;
                _calculateTestStatistic();
              }),
            ),
            RadioListTile<bool>(
              title: const Text('单侧检验 (μ > μ₀ 或 μ < μ₀)'),
              value: false,
              groupValue: _isTwoTailed,
              onChanged: (value) => setState(() {
                _isTwoTailed = value!;
                _calculateTestStatistic();
              }),
            ),
            
            const SizedBox(height: 16),
            
            // 假设表述
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '当前假设设定：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_hypothesisType == 'mean') ...[
                    Text('H₀: μ = μ₀ (原假设：总体均值等于某个特定值)'),
                    if (_isTwoTailed)
                      Text('H₁: μ ≠ μ₀ (备择假设：总体均值不等于该值)')
                    else
                      Text('H₁: μ > μ₀ 或 μ < μ₀ (备择假设：总体均值大于或小于该值)'),
                  ] else ...[
                    Text('H₀: p = p₀ (原假设：总体比例等于某个特定值)'),
                    if (_isTwoTailed)
                      Text('H₁: p ≠ p₀ (备择假设：总体比例不等于该值)')
                    else
                      Text('H₁: p > p₀ 或 p < p₀ (备择假设：总体比例大于或小于该值)'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '第2步：选择显著性水平',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '显著性水平（α）是我们愿意承受的第一类错误的概率，即在原假设为真时错误拒绝它的概率。',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            const Text('选择显著性水平：'),
            Row(
              children: [
                Text('α = ${(_alpha * 100).toStringAsFixed(1)}%'),
                Expanded(
                  child: Slider(
                    value: _alpha,
                    min: 0.01,
                    max: 0.10,
                    divisions: 90,
                    onChanged: (value) => setState(() {
                      _alpha = value;
                      _calculateTestStatistic();
                    }),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 常用显著性水平
            const Text('常用显著性水平：'),
            Wrap(
              spacing: 8,
              children: [0.01, 0.05, 0.10].map((alpha) {
                return ChoiceChip(
                  label: Text('${(alpha * 100).toInt()}%'),
                  selected: _alpha == alpha,
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _alpha = alpha;
                      _calculateTestStatistic();
                    }
                  }),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '显著性水平的含义：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('• α = ${(_alpha * 100).toStringAsFixed(1)}% 表示我们愿意承受 ${(_alpha * 100).toStringAsFixed(1)}% 的概率犯第一类错误'),
                  const Text('• 更小的α意味着更严格的检验标准'),
                  const Text('• 但同时也会增加第二类错误的概率'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '第3步：选择检验方法',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '根据样本情况和总体参数的已知情况选择合适的检验方法：',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            RadioListTile<String>(
              title: const Text('Z检验'),
              subtitle: const Text('已知总体标准差或大样本'),
              value: 'z-test',
              groupValue: _testType,
              onChanged: (value) => setState(() {
                _testType = value!;
                _calculateTestStatistic();
              }),
            ),
            RadioListTile<String>(
              title: const Text('t检验'),
              subtitle: const Text('未知总体标准差且小样本'),
              value: 't-test',
              groupValue: _testType,
              onChanged: (value) => setState(() {
                _testType = value!;
                _calculateTestStatistic();
              }),
            ),
            
            const SizedBox(height: 16),
            
            // 样本参数输入
            const Text('输入样本参数：'),
            const SizedBox(height: 8),
            
            _buildParameterInput('样本均值', _sampleMean, (value) {
              _sampleMean = value;
              _calculateTestStatistic();
            }),
            _buildParameterInput('假设均值 (μ₀)', _populationMean, (value) {
              _populationMean = value;
              _calculateTestStatistic();
            }),
            _buildParameterInput('样本标准差', _sampleStd, (value) {
              _sampleStd = value;
              _calculateTestStatistic();
            }),
            _buildParameterInput('样本量', _sampleSize.toDouble(), (value) {
              _sampleSize = value.round();
              _calculateTestStatistic();
            }, isInteger: true),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择的检验方法：$_testType',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_testType == 'z-test')
                    const Text('使用标准正态分布作为参考分布')
                  else
                    Text('使用自由度为 ${_sampleSize - 1} 的t分布作为参考分布'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '第4步：计算检验统计量',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '计算公式：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_testType == 'z-test')
                    const Text('Z = (x̄ - μ₀) / (σ / √n)')
                  else
                    const Text('t = (x̄ - μ₀) / (s / √n)'),
                  const SizedBox(height: 16),
                  const Text('其中：'),
                  Text('x̄ = ${_sampleMean.toStringAsFixed(2)} (样本均值)'),
                  Text('μ₀ = ${_populationMean.toStringAsFixed(2)} (假设均值)'),
                  Text('s = ${_sampleStd.toStringAsFixed(2)} (样本标准差)'),
                  Text('n = $_sampleSize (样本量)'),
                  const SizedBox(height: 16),
                  Text(
                    '计算结果：${_testType == 'z-test' ? 'Z' : 't'} = ${_testStatistic.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 检验统计量可视化
            SizedBox(
              height: 300,
              child: LineChart(_buildTestStatisticChart()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '第5步：确定拒绝域',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '拒绝域是指当检验统计量落在该区域内时，我们拒绝原假设的区域。',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // 临界值信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '拒绝域信息：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('显著性水平：α = ${(_alpha * 100).toStringAsFixed(1)}%'),
                  if (_isTwoTailed) ...[
                    Text('双侧检验：α/2 = ${((_alpha / 2) * 100).toStringAsFixed(2)}% (每侧)'),
                    Text('临界值：±${_getCriticalValue().toStringAsFixed(4)}'),
                    Text('拒绝域：${_testType == 'z-test' ? 'Z' : 't'} < ${(-_getCriticalValue()).toStringAsFixed(4)} 或 ${_testType == 'z-test' ? 'Z' : 't'} > ${_getCriticalValue().toStringAsFixed(4)}'),
                  ] else ...[
                    Text('单侧检验：α = ${(_alpha * 100).toStringAsFixed(1)}%'),
                    Text('临界值：${_getCriticalValue().toStringAsFixed(4)}'),
                    Text('拒绝域：${_testType == 'z-test' ? 'Z' : 't'} > ${_getCriticalValue().toStringAsFixed(4)}'),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 拒绝域可视化
            const Text(
              '拒绝域可视化：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: LineChart(_buildRejectionRegionChart()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep6() {
    bool rejectH0 = _shouldRejectH0();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '第6步：做出统计决策',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 决策标准
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '决策标准：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('检验统计量：${_testStatistic.toStringAsFixed(4)}'),
                  Text('P值：${_pValue.toStringAsFixed(4)}'),
                  Text('显著性水平：${(_alpha * 100).toStringAsFixed(1)}%'),
                  const SizedBox(height: 8),
                  const Text('决策规则：'),
                  const Text('• 如果 P值 < α，则拒绝原假设'),
                  const Text('• 如果 P值 ≥ α，则不拒绝原假设'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 决策结果
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rejectH0 ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: rejectH0 ? Colors.red.shade200 : Colors.green.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '统计决策：',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: rejectH0 ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rejectH0 ? '拒绝原假设 H₀' : '不拒绝原假设 H₀',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: rejectH0 ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rejectH0 
                      ? 'P值 (${_pValue.toStringAsFixed(4)}) < α (${_alpha.toStringAsFixed(3)})'
                      : 'P值 (${_pValue.toStringAsFixed(4)}) ≥ α (${_alpha.toStringAsFixed(3)})',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep7() {
    bool rejectH0 = _shouldRejectH0();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '第7步：得出结论',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '结论解释：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (rejectH0) ...[
                    Text(
                      '在 ${(_alpha * 100).toStringAsFixed(1)}% 的显著性水平下，我们有足够的证据拒绝原假设。',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_hypothesisType == 'mean')
                      Text(
                        '这意味着样本数据支持总体均值${_isTwoTailed ? '不等于' : (_sampleMean > _populationMean ? '大于' : '小于')} ${_populationMean.toStringAsFixed(2)} 的结论。',
                        style: const TextStyle(fontSize: 16),
                      )
                    else
                      Text(
                        '这意味着样本数据支持总体比例${_isTwoTailed ? '不等于' : '大于或小于'} 假设比例的结论。',
                        style: const TextStyle(fontSize: 16),
                      ),
                  ] else ...[
                    Text(
                      '在 ${(_alpha * 100).toStringAsFixed(1)}% 的显著性水平下，我们没有足够的证据拒绝原假设。',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_hypothesisType == 'mean')
                      Text(
                        '这意味着样本数据不足以支持总体均值${_isTwoTailed ? '不等于' : (_sampleMean > _populationMean ? '大于' : '小于')} ${_populationMean.toStringAsFixed(2)} 的结论。',
                        style: const TextStyle(fontSize: 16),
                      )
                    else
                      Text(
                        '这意味着样本数据不足以支持总体比例${_isTwoTailed ? '不等于' : '大于或小于'} 假设比例的结论。',
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 重要提醒
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow.shade300),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '重要提醒：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('• "不拒绝原假设"不等于"接受原假设"'),
                  Text('• 统计显著不一定意味着实际意义'),
                  Text('• 结论的强度取决于P值的大小'),
                  Text('• 需要考虑样本量和效应大小'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 重新开始按钮
            Center(
              child: ElevatedButton.icon(
                onPressed: () => setState(() {
                  _currentStep = 0;
                }),
                icon: const Icon(Icons.refresh),
                label: const Text('重新开始'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterInput(
    String label, 
    double value, 
    ValueChanged<double> onChanged,
    {bool isInteger = false}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label),
          ),
          Expanded(
            child: TextFormField(
              initialValue: isInteger ? value.round().toString() : value.toStringAsFixed(2),
              keyboardType: TextInputType.number,
              onChanged: (text) {
                double? newValue = double.tryParse(text);
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildTestStatisticChart() {
    List<FlSpot> spots = [];
    double min = -4.0;
    double max = 4.0;
    
    for (double x = min; x <= max; x += 0.1) {
      double y = _getDistributionPDF(x);
      spots.add(FlSpot(x, y));
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
        // 分布曲线
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          dotData: FlDotData(show: false),
        ),
        // 检验统计量位置
        LineChartBarData(
          spots: [
            FlSpot(_testStatistic, 0),
            FlSpot(_testStatistic, _getDistributionPDF(_testStatistic)),
          ],
          isCurved: false,
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

  LineChartData _buildRejectionRegionChart() {
    List<FlSpot> spots = [];
    List<FlSpot> rejectionSpots = [];
    double min = -4.0;
    double max = 4.0;
    double criticalValue = _getCriticalValue();
    
    for (double x = min; x <= max; x += 0.1) {
      double y = _getDistributionPDF(x);
      spots.add(FlSpot(x, y));
      
      // 拒绝域部分
      if (_isTwoTailed) {
        if (x <= -criticalValue || x >= criticalValue) {
          rejectionSpots.add(FlSpot(x, y));
        }
      } else {
        if (x >= criticalValue) {
          rejectionSpots.add(FlSpot(x, y));
        }
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
        // 分布曲线
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          dotData: FlDotData(show: false),
        ),
        // 拒绝域
        if (rejectionSpots.isNotEmpty)
          LineChartBarData(
            spots: rejectionSpots,
            isCurved: true,
            color: Colors.red.withOpacity(0.3),
            barWidth: 0,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.3),
            ),
          ),
        // 检验统计量位置
        LineChartBarData(
          spots: [
            FlSpot(_testStatistic, 0),
            FlSpot(_testStatistic, _getDistributionPDF(_testStatistic)),
          ],
          isCurved: false,
          color: Colors.green,
          barWidth: 3,
          dotData: FlDotData(show: false),
        ),
      ],
      minX: min,
      maxX: max,
      minY: 0,
    );
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _calculateTestStatistic() {
    double standardError = _sampleStd / math.sqrt(_sampleSize);
    _testStatistic = (_sampleMean - _populationMean) / standardError;
    _pValue = _calculatePValue();
    setState(() {});
  }

  double _calculatePValue() {
    if (_testType == 'z-test') {
      if (_isTwoTailed) {
        return 2 * (1 - StatisticsService.normalCDF(_testStatistic.abs()));
      } else {
        return 1 - StatisticsService.normalCDF(_testStatistic);
      }
    } else {
      // t-test
      if (_isTwoTailed) {
        return 2 * (1 - StatisticsService.tCDF(_testStatistic.abs(), _sampleSize - 1));
      } else {
        return 1 - StatisticsService.tCDF(_testStatistic, _sampleSize - 1);
      }
    }
  }

  bool _shouldRejectH0() {
    return _pValue < _alpha;
  }

  double _getCriticalValue() {
    if (_testType == 'z-test') {
      return _getZCritical(_isTwoTailed ? _alpha / 2 : _alpha);
    } else {
      return _getTCritical(_isTwoTailed ? _alpha / 2 : _alpha, _sampleSize - 1);
    }
  }

  double _getZCritical(double alpha) {
    // 近似计算标准正态分布的临界值
    if (alpha <= 0.005) return 2.576;
    if (alpha <= 0.01) return 2.326;
    if (alpha <= 0.025) return 1.960;
    if (alpha <= 0.05) return 1.645;
    if (alpha <= 0.10) return 1.282;
    return 1.0;
  }

  double _getTCritical(double alpha, int df) {
    // 简化的t分布临界值计算
    double z = _getZCritical(alpha);
    if (df >= 30) return z;
    
    // 对小自由度的调整
    double adjustment = 1 + (4 / (4 * df + 1));
    return z * adjustment;
  }

  double _getDistributionPDF(double x) {
    if (_testType == 'z-test') {
      return (1 / math.sqrt(2 * math.pi)) * math.exp(-0.5 * x * x);
    } else {
      // 简化的t分布PDF
      int df = _sampleSize - 1;
      double gamma1 = _approximateGamma((df + 1) / 2);
      double gamma2 = _approximateGamma(df / 2);
      double coeff = gamma1 / (math.sqrt(df * math.pi) * gamma2);
      return coeff * math.pow(1 + (x * x) / df, -(df + 1) / 2);
    }
  }

  double _approximateGamma(double z) {
    // Stirling近似
    if (z < 1) return _approximateGamma(z + 1) / z;
    return math.sqrt(2 * math.pi / z) * math.pow(z / math.e, z);
  }
}

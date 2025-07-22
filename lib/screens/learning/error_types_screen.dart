import 'package:flutter/material.dart';

/// 第一类与第二类错误学习屏幕
class ErrorTypesScreen extends StatefulWidget {
  const ErrorTypesScreen({super.key});

  @override
  State<ErrorTypesScreen> createState() => _ErrorTypesScreenState();
}

class _ErrorTypesScreenState extends State<ErrorTypesScreen> {
  double _alpha = 0.05;
  double _beta = 0.20;
  double _effectSize = 1.0;
  int _sampleSize = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('错误类型学习'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 概念介绍
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '假设检验中的错误类型',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '在假设检验中，我们可能犯两种类型的错误：',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• 第一类错误 (α错误)：原假设为真时，错误地拒绝原假设',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                      const Text(
                        '• 第二类错误 (β错误)：原假设为假时，错误地接受原假设',
                        style: TextStyle(fontSize: 14, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 决策表格
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '决策表格',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Table(
                        border: TableBorder.all(color: Colors.grey),
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: Colors.grey),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'H₀为真',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'H₀为假',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  '拒绝H₀',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '第一类错误\n(α错误)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '正确决策\n(检验效能)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  '接受H₀',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '正确决策\n(1-α)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '第二类错误\n(β错误)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 参数控制
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '参数设置',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSlider(
                        '第一类错误概率 (α)',
                        _alpha,
                        0.01,
                        0.10,
                        (value) => setState(() => _alpha = value),
                        Colors.red,
                      ),
                      _buildSlider(
                        '第二类错误概率 (β)',
                        _beta,
                        0.05,
                        0.50,
                        (value) => setState(() => _beta = value),
                        Colors.orange,
                      ),
                      _buildSlider(
                        '效应大小',
                        _effectSize,
                        0.2,
                        2.0,
                        (value) => setState(() => _effectSize = value),
                        Colors.blue,
                      ),
                      Row(
                        children: [
                          const Text('样本量: '),
                          Expanded(
                            child: Slider(
                              value: _sampleSize.toDouble(),
                              min: 10,
                              max: 100,
                              divisions: 18,
                              label: _sampleSize.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _sampleSize = value.round();
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

              // 计算结果
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '计算结果',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow('第一类错误概率 (α)', _alpha, Colors.red),
                      _buildResultRow('第二类错误概率 (β)', _beta, Colors.orange),
                      _buildResultRow('检验效能 (1-β)', 1 - _beta, Colors.green),
                      _buildResultRow('置信度 (1-α)', 1 - _alpha, Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 解释说明
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '重要概念',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildConceptCard(
                        '检验效能 (Power)',
                        '检验效能是指当原假设确实为假时，能够正确拒绝原假设的概率，即 1-β。'
                        '效能越高，检验越能发现真实的差异。',
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildConceptCard(
                        '显著性水平 (α)',
                        '显著性水平是我们愿意承担第一类错误的最大概率。'
                        '常用的显著性水平有0.05、0.01和0.001。',
                        Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildConceptCard(
                        '效应大小',
                        '效应大小衡量的是实际差异的大小。效应大小越大，'
                        '在相同的样本量下，检验效能越高。',
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: 20,
              label: value.toStringAsFixed(2),
              activeColor: color,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toStringAsFixed(3),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConceptCard(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: color, width: 4),
        ),
        color: color.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

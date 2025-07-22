import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/test_provider.dart';
import '../models/test_input.dart';
import 'test_result_screen.dart';

/// 测试输入屏幕
class TestInputScreen extends StatefulWidget {
  final String testType;

  const TestInputScreen({super.key, required this.testType});

  @override
  State<TestInputScreen> createState() => _TestInputScreenState();
}

class _TestInputScreenState extends State<TestInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sample1Controller = TextEditingController();
  final _sample2Controller = TextEditingController();
  final _alphaController = TextEditingController(text: '0.05');
  final _populationMeanController = TextEditingController();
  final _populationVarianceController = TextEditingController();
  final List<TextEditingController> _groupControllers = [];
  
  String _alternativeHypothesis = 'two-sided';
  final bool _pairedSamples = false;
  int _groupCount = 3; // ANOVA默认3组

  @override
  void initState() {
    super.initState();
    if (widget.testType == 'anova') {
      _initializeGroupControllers();
    }
  }

  @override
  void dispose() {
    _sample1Controller.dispose();
    _sample2Controller.dispose();
    _alphaController.dispose();
    _populationMeanController.dispose();
    _populationVarianceController.dispose();
    for (var controller in _groupControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeGroupControllers() {
    _groupControllers.clear();
    for (int i = 0; i < _groupCount; i++) {
      _groupControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTestTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 检验说明
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTestTitle(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getTestDescription(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 数据输入
                _buildDataInputSection(),
                const SizedBox(height: 12),

                // 示例数据按钮
                Center(
                  child: TextButton.icon(
                    onPressed: _loadSampleData,
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('加载示例数据'),
                  ),
                ),
                const SizedBox(height: 20),

                // 参数设置
                _buildParameterSection(),
                const SizedBox(height: 20),

                // 假设设置
                _buildHypothesisSection(),
                const SizedBox(height: 30),

                // 计算按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _performTest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '开始计算',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataInputSection() {
    if (widget.testType == 'anova') {
      return _buildAnovaDataInput();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '数据输入',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sample1Controller,
              decoration: InputDecoration(
                labelText: _getSample1Label(),
                hintText: '请输入数据，用逗号分隔，例如：1,2,3,4,5',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入样本数据';
                }
                return null;
              },
            ),
            if (_needsSample2()) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _sample2Controller,
                decoration: InputDecoration(
                  labelText: _getSample2Label(),
                  hintText: '请输入数据，用逗号分隔',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_needsSample2() && (value == null || value.isEmpty)) {
                    return '请输入第二组样本数据';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnovaDataInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '数据输入 (ANOVA)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text('组数: '),
                    DropdownButton<int>(
                      value: _groupCount,
                      items: List.generate(8, (index) => index + 2)
                          .map((count) => DropdownMenuItem(
                                value: count,
                                child: Text(count.toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _groupCount = value!;
                          _initializeGroupControllers();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_groupCount, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: _groupControllers[index],
                  decoration: InputDecoration(
                    labelText: '第${index + 1}组数据',
                    hintText: '请输入数据，用逗号分隔',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入第${index + 1}组数据';
                    }
                    return null;
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterSection() {
    return Card(
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
            TextFormField(
              controller: _alphaController,
              decoration: const InputDecoration(
                labelText: '显著性水平 (α)',
                hintText: '0.05',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入显著性水平';
                }
                double? alpha = double.tryParse(value);
                if (alpha == null || alpha <= 0 || alpha >= 1) {
                  return '显著性水平必须在0和1之间';
                }
                return null;
              },
            ),
            if (_needsPopulationMean()) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _populationMeanController,
                decoration: InputDecoration(
                  labelText: _getPopulationMeanLabel(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_needsPopulationMean() && (value == null || value.isEmpty)) {
                    return '请输入${_getPopulationMeanLabel()}';
                  }
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return '请输入有效的数值';
                  }
                  return null;
                },
              ),
            ],
            if (_needsPopulationVariance()) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _populationVarianceController,
                decoration: const InputDecoration(
                  labelText: '总体方差',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_needsPopulationVariance() && (value == null || value.isEmpty)) {
                    return '请输入总体方差';
                  }
                  if (value != null && value.isNotEmpty) {
                    double? variance = double.tryParse(value);
                    if (variance == null || variance <= 0) {
                      return '总体方差必须大于0';
                    }
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHypothesisSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '备择假设',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _alternativeHypothesis,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'two-sided', child: Text('双侧检验 (≠)')),
                DropdownMenuItem(value: 'greater', child: Text('右侧检验 (>)')),
                DropdownMenuItem(value: 'less', child: Text('左侧检验 (<)')),
              ],
              onChanged: (value) {
                setState(() {
                  _alternativeHypothesis = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _performTest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // 解析输入数据
      List<double> sample1 = [];
      List<double>? sample2;
      Map<String, dynamic> additionalInfo = {};

      if (widget.testType == 'anova') {
        // ANOVA特殊处理
        List<List<double>> groups = [];
        for (var controller in _groupControllers) {
          if (controller.text.isNotEmpty) {
            groups.add(_parseNumbers(controller.text));
          }
        }
        additionalInfo['groups'] = groups;
      } else {
        sample1 = _parseNumbers(_sample1Controller.text);
        if (_needsSample2() && _sample2Controller.text.isNotEmpty) {
          sample2 = _parseNumbers(_sample2Controller.text);
        }
      }

      double alpha = double.parse(_alphaController.text);
      double? populationMean;
      if (_needsPopulationMean() && _populationMeanController.text.isNotEmpty) {
        populationMean = double.parse(_populationMeanController.text);
      }
      double? populationVariance;
      if (_needsPopulationVariance() && _populationVarianceController.text.isNotEmpty) {
        populationVariance = double.parse(_populationVarianceController.text);
      }

      // 创建测试输入
      TestInput input = TestInput(
        sample1: sample1,
        sample2: sample2,
        alpha: alpha,
        testType: widget.testType,
        alternativeHypothesis: _alternativeHypothesis,
        populationMean: populationMean,
        populationVariance: populationVariance,
        pairedSamples: _pairedSamples,
        additionalInfo: additionalInfo,
      );

      // 设置输入并执行测试
      final testProvider = Provider.of<TestProvider>(context, listen: false);
      testProvider.setTestInput(input);
      await testProvider.performTest();

      // 导航到结果页面
      if (mounted) {
        final navigator = Navigator.of(context);
        navigator.push(
          MaterialPageRoute(
            builder: (context) => const TestResultScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('输入错误: ${e.toString()}')),
        );
      }
    }
  }

  List<double> _parseNumbers(String text) {
    return text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => double.parse(s))
        .toList();
  }

  String _getTestTitle() {
    switch (widget.testType) {
      case 'one_sample_t':
        return '单样本t检验';
      case 'two_sample_t':
        return '双样本t检验';
      case 'paired_t':
        return '配对样本t检验';
      case 'one_sample_z':
        return '单样本Z检验';
      case 'two_sample_z':
        return '双样本Z检验';
      case 'anova':
        return '方差分析(ANOVA)';
      case 'chi_square':
        return '卡方检验';
      case 'sign_test':
        return '符号检验';
      case 'wilcoxon':
        return 'Wilcoxon检验';
      default:
        return '假设检验';
    }
  }

  String _getTestDescription() {
    switch (widget.testType) {
      case 'one_sample_t':
        return '检验样本均值是否等于已知的总体均值';
      case 'two_sample_t':
        return '比较两个独立样本的均值是否存在显著差异';
      case 'paired_t':
        return '比较配对样本的均值是否存在显著差异';
      case 'one_sample_z':
        return '在已知总体方差的情况下检验样本均值';
      case 'sign_test':
        return '检验样本中位数是否等于已知值';
      case 'wilcoxon':
        return '非参数的单样本位置检验';
      default:
        return '进行假设检验分析';
    }
  }

  String _getSample1Label() {
    switch (widget.testType) {
      case 'two_sample_t':
      case 'two_sample_z':
        return '第一组样本数据';
      case 'paired_t':
        return '配对前数据';
      case 'chi_square':
        return '观察频数';
      default:
        return '样本数据';
    }
  }

  String _getSample2Label() {
    switch (widget.testType) {
      case 'two_sample_t':
      case 'two_sample_z':
        return '第二组样本数据';
      case 'paired_t':
        return '配对后数据';
      case 'chi_square':
        return '期望频数';
      default:
        return '第二组数据';
    }
  }

  String _getPopulationMeanLabel() {
    switch (widget.testType) {
      case 'sign_test':
      case 'wilcoxon':
        return '假设中位数';
      default:
        return '总体均值';
    }
  }

  bool _needsSample2() {
    return ['two_sample_t', 'two_sample_z', 'paired_t', 'chi_square'].contains(widget.testType);
  }

  bool _needsPopulationMean() {
    return ['one_sample_t', 'one_sample_z', 'sign_test', 'wilcoxon'].contains(widget.testType);
  }

  bool _needsPopulationVariance() {
    return ['one_sample_z', 'two_sample_z'].contains(widget.testType);
  }

  void _loadSampleData() {
    switch (widget.testType) {
      case 'one_sample_t':
        _sample1Controller.text = '23.5, 24.1, 22.8, 25.2, 23.9, 24.5, 23.1, 24.8, 23.6, 24.3';
        _populationMeanController.text = '24.0';
        break;
      case 'two_sample_t':
        _sample1Controller.text = '23.5, 24.1, 22.8, 25.2, 23.9';
        _sample2Controller.text = '25.1, 26.2, 24.8, 26.5, 25.8';
        break;
      case 'paired_t':
        _sample1Controller.text = '85, 87, 82, 90, 88';
        _sample2Controller.text = '88, 90, 85, 93, 91';
        break;
      case 'one_sample_z':
        _sample1Controller.text = '98, 102, 95, 105, 99, 101, 97, 103, 100, 96';
        _populationMeanController.text = '100';
        _populationVarianceController.text = '25';
        break;
      case 'sign_test':
        _sample1Controller.text = '12, 15, 8, 18, 11, 16, 9, 14, 13, 17';
        _populationMeanController.text = '12';
        break;
      case 'wilcoxon':
        _sample1Controller.text = '12.5, 15.2, 8.8, 18.1, 11.3, 16.7, 9.2, 14.5, 13.1, 17.4';
        _populationMeanController.text = '12.0';
        break;
      case 'chi_square':
        _sample1Controller.text = '20, 15, 25, 10';
        _sample2Controller.text = '18, 18, 18, 18';
        break;
      case 'anova':
        if (_groupControllers.length >= 3) {
          _groupControllers[0].text = '23, 25, 22, 26, 24';
          _groupControllers[1].text = '28, 30, 27, 31, 29';
          _groupControllers[2].text = '20, 22, 19, 23, 21';
        }
        break;
    }
    setState(() {});
  }
}

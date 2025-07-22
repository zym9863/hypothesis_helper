import 'package:flutter/material.dart';
import 'test_input_screen.dart';

/// 检验类型选择屏幕
class TestSelectionScreen extends StatelessWidget {
  const TestSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择检验类型'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '参数检验',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            _buildTestTypeCard(
              context,
              '单样本t检验',
              '检验样本均值是否等于已知总体均值',
              Icons.looks_one,
              'one_sample_t',
            ),
            _buildTestTypeCard(
              context,
              '双样本t检验',
              '比较两个独立样本的均值差异',
              Icons.looks_two,
              'two_sample_t',
            ),
            _buildTestTypeCard(
              context,
              '配对样本t检验',
              '比较配对样本的均值差异',
              Icons.compare_arrows,
              'paired_t',
            ),
            _buildTestTypeCard(
              context,
              '单样本Z检验',
              '已知总体方差时的均值检验',
              Icons.trending_up,
              'one_sample_z',
            ),
            _buildTestTypeCard(
              context,
              '方差分析(ANOVA)',
              '比较多个组的均值差异',
              Icons.bar_chart,
              'anova',
            ),
            
            const SizedBox(height: 20),
            const Text(
              '非参数检验',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            _buildTestTypeCard(
              context,
              '符号检验',
              '检验样本中位数是否等于已知值',
              Icons.add_circle_outline,
              'sign_test',
            ),
            _buildTestTypeCard(
              context,
              'Wilcoxon符号秩检验',
              '非参数的单样本位置检验',
              Icons.show_chart,
              'wilcoxon',
            ),
            
            const SizedBox(height: 20),
            const Text(
              '其他检验',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            _buildTestTypeCard(
              context,
              '卡方拟合优度检验',
              '检验观察频数与期望频数的差异',
              Icons.pie_chart,
              'chi_square',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestTypeCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String testType,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestInputScreen(testType: testType),
            ),
          );
        },
      ),
    );
  }
}

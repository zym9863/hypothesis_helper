import 'package:flutter/material.dart';
import 'learning/p_value_visualization_screen.dart';
import 'learning/error_types_screen.dart';
import 'learning/distribution_visualization_screen.dart';
import 'learning/power_analysis_screen.dart';
import 'learning/hypothesis_steps_screen.dart';
import 'learning/rejection_region_screen.dart';

/// 交互式学习模块屏幕
class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交互式学习'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '交互式学习模块',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '通过可视化和交互式组件深入理解假设检验的核心概念',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 学习模块
            const Text(
              '学习模块',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _buildLearningCard(
                    'P值可视化',
                    '理解P值的含义及其与检验统计量的关系',
                    Icons.analytics,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PValueVisualizationScreen(),
                      ),
                    ),
                  ),
                  _buildLearningCard(
                    '第一类与第二类错误',
                    '通过交互式模拟理解α错误和β错误的概念',
                    Icons.error_outline,
                    Colors.red,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ErrorTypesScreen(),
                      ),
                    ),
                  ),
                  _buildLearningCard(
                    '检验效能分析',
                    '可视化展示样本量、效应大小对检验效能的影响',
                    Icons.trending_up,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PowerAnalysisScreen(),
                      ),
                    ),
                  ),
                  _buildLearningCard(
                    '概率分布图表',
                    '动态展示正态分布、t分布等概率分布',
                    Icons.show_chart,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DistributionVisualizationScreen(),
                      ),
                    ),
                  ),
                  _buildLearningCard(
                    '假设检验步骤',
                    '学习假设检验的标准步骤和决策过程',
                    Icons.list_alt,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HypothesisStepsScreen(),
                      ),
                    ),
                  ),
                  _buildLearningCard(
                    '拒绝域可视化',
                    '理解拒绝域的概念和显著性水平的影响',
                    Icons.crop_free,
                    Colors.teal,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RejectionRegionScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/test_result.dart';

/// 统计摘要组件
class StatisticsSummary extends StatelessWidget {
  final TestResult result;

  const StatisticsSummary({
    super.key,
    required this.result,
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
              '统计摘要',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          '检验统计量',
          result.testStatistic.toStringAsFixed(4),
          Icons.calculate,
          Colors.blue,
        ),
        _buildStatCard(
          'P值',
          result.pValue.toStringAsFixed(6),
          Icons.analytics,
          result.rejectNull ? Colors.red : Colors.green,
        ),
        _buildStatCard(
          '显著性水平',
          'α = ${result.alpha}',
          Icons.rule,
          Colors.orange,
        ),
        _buildStatCard(
          '结论',
          result.rejectNull ? '拒绝H₀' : '不拒绝H₀',
          result.rejectNull ? Icons.close : Icons.check,
          result.rejectNull ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 假设检验结果模型
class TestResult {
  final String testType;
  final double testStatistic;
  final double pValue;
  final double alpha;
  final bool rejectNull;
  final String conclusion;
  final Map<String, dynamic> additionalInfo;

  TestResult({
    required this.testType,
    required this.testStatistic,
    required this.pValue,
    required this.alpha,
    required this.rejectNull,
    required this.conclusion,
    this.additionalInfo = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'testType': testType,
      'testStatistic': testStatistic,
      'pValue': pValue,
      'alpha': alpha,
      'rejectNull': rejectNull,
      'conclusion': conclusion,
      'additionalInfo': additionalInfo,
    };
  }

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      testType: json['testType'],
      testStatistic: json['testStatistic'],
      pValue: json['pValue'],
      alpha: json['alpha'],
      rejectNull: json['rejectNull'],
      conclusion: json['conclusion'],
      additionalInfo: json['additionalInfo'] ?? {},
    );
  }
}

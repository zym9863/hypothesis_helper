/// 假设检验输入数据模型
class TestInput {
  final List<double> sample1;
  final List<double>? sample2;
  final double alpha;
  final String testType;
  final String? alternativeHypothesis; // 'two-sided', 'greater', 'less'
  final double? populationMean;
  final double? populationVariance;
  final bool pairedSamples;
  final Map<String, dynamic> additionalInfo;

  TestInput({
    required this.sample1,
    this.sample2,
    required this.alpha,
    required this.testType,
    this.alternativeHypothesis = 'two-sided',
    this.populationMean,
    this.populationVariance,
    this.pairedSamples = false,
    this.additionalInfo = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'sample1': sample1,
      'sample2': sample2,
      'alpha': alpha,
      'testType': testType,
      'alternativeHypothesis': alternativeHypothesis,
      'populationMean': populationMean,
      'populationVariance': populationVariance,
      'pairedSamples': pairedSamples,
      'additionalInfo': additionalInfo,
    };
  }

  factory TestInput.fromJson(Map<String, dynamic> json) {
    return TestInput(
      sample1: List<double>.from(json['sample1']),
      sample2: json['sample2'] != null ? List<double>.from(json['sample2']) : null,
      alpha: json['alpha'],
      testType: json['testType'],
      alternativeHypothesis: json['alternativeHypothesis'],
      populationMean: json['populationMean'],
      populationVariance: json['populationVariance'],
      pairedSamples: json['pairedSamples'] ?? false,
      additionalInfo: json['additionalInfo'] ?? {},
    );
  }
}

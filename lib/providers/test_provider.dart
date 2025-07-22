import 'package:flutter/foundation.dart';
import '../models/test_input.dart';
import '../models/test_result.dart';
import '../services/hypothesis_test_service.dart';

/// 假设检验状态管理
class TestProvider with ChangeNotifier {
  TestInput? _currentInput;
  TestResult? _currentResult;
  bool _isCalculating = false;
  String? _errorMessage;

  // Getters
  TestInput? get currentInput => _currentInput;
  TestResult? get currentResult => _currentResult;
  bool get isCalculating => _isCalculating;
  String? get errorMessage => _errorMessage;

  /// 设置测试输入
  void setTestInput(TestInput input) {
    _currentInput = input;
    _errorMessage = null;
    notifyListeners();
  }

  /// 执行假设检验
  Future<void> performTest() async {
    if (_currentInput == null) {
      _errorMessage = '请先设置测试参数';
      notifyListeners();
      return;
    }

    _isCalculating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentResult = await HypothesisTestService.performTest(_currentInput!);
    } catch (e) {
      _errorMessage = '计算错误: ${e.toString()}';
      _currentResult = null;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  /// 清除结果
  void clearResults() {
    _currentResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// 重置所有数据
  void reset() {
    _currentInput = null;
    _currentResult = null;
    _isCalculating = false;
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// UI工具类
class UIUtils {
  
  /// 显示成功消息
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示错误消息
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示信息消息
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示加载对话框
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  /// 隐藏加载对话框
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// 显示确认对话框
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 复制文本到剪贴板
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// 显示复制成功提示
  static void showCopySuccessSnackBar(BuildContext context, String content) {
    showSuccessSnackBar(context, '已复制到剪贴板: $content');
  }

  /// 触觉反馈
  static void hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  /// 获取主题颜色
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// 获取错误颜色
  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  /// 获取成功颜色
  static Color getSuccessColor(BuildContext context) {
    return Colors.green;
  }

  /// 获取警告颜色
  static Color getWarningColor(BuildContext context) {
    return Colors.orange;
  }

  /// 创建渐变背景
  static BoxDecoration createGradientBackground(List<Color> colors) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
    );
  }

  /// 创建阴影效果
  static List<BoxShadow> createShadow({
    Color color = Colors.black26,
    double blurRadius = 4.0,
    Offset offset = const Offset(0, 2),
  }) {
    return [
      BoxShadow(
        color: color,
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }

  /// 安全的导航
  static void safeNavigate(BuildContext context, Widget destination) {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }

  /// 安全的返回
  static void safeNavigateBack(BuildContext context) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// 格式化数字显示
  static String formatNumber(double number, {int decimals = 4}) {
    if (number.abs() < 0.0001 && number != 0) {
      return number.toStringAsExponential(2);
    }
    return number.toStringAsFixed(decimals);
  }

  /// 格式化百分比
  static String formatPercentage(double value, {int decimals = 2}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// 获取响应式字体大小
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseSize * 0.9;
    } else if (screenWidth > 1200) {
      return baseSize * 1.1;
    }
    return baseSize;
  }

  /// 获取响应式间距
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseSpacing * 0.8;
    } else if (screenWidth > 1200) {
      return baseSpacing * 1.2;
    }
    return baseSpacing;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/test_provider.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HypothesisHelperApp());
}

class HypothesisHelperApp extends StatelessWidget {
  const HypothesisHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TestProvider()),
      ],
      child: MaterialApp(
        title: '假设检验助手',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.light,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}



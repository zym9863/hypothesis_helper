import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/test_provider.dart';
import 'screens/main_screen.dart';

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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:points_system/points_counting_app.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:points_system/themes.dart';

void main() {
  runApp(EasyDynamicThemeWidget(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Points Counting App",
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: const PointsCountingApp(),
    );
  }
}

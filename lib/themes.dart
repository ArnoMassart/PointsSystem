import 'package:flutter/material.dart';

var lightThemeData = ThemeData(
    primaryColor: const Color.fromARGB(255, 173, 206, 116),
    textTheme: const TextTheme(
        labelLarge: TextStyle(color: Colors.white),
        labelMedium: TextStyle(color: Colors.white),
        labelSmall: TextStyle(color: Colors.white)),
    brightness: Brightness.light,
    hintColor: Colors.black54);

var darkThemeData = ThemeData(
    primaryColor: const Color.fromARGB(255, 173, 206, 116),
    textTheme: const TextTheme(
        labelLarge: TextStyle(color: Colors.black),
        labelMedium: TextStyle(color: Colors.black),
        labelSmall: TextStyle(color: Colors.black)),
    brightness: Brightness.dark,
    hintColor: Colors.white70);

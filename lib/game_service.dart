import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:points_system/classes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameService {
  static bool isDarkMode = false;

  static SizedBox getSizedBox({double width = 0, double height = 0}) {
    return SizedBox(
      width: width,
      height: height,
    );
  }

  static String firstLetterCapital(String input) {
    return input.substring(0, 1).toUpperCase() + input.substring(1);
  }

  static TextStyle getTextStyle({double fontSize = 14}) {
    return TextStyle(
        color: GameService.isDarkMode ? Colors.white : Colors.black,
        fontSize: fontSize);
  }

  static Color getColor() {
    Color color;
    GameService.isDarkMode ? color = Colors.white : color = Colors.black;

    return color;
  }

  static ButtonStyle getButtonStyleWithBackgroundChange() {
    return ElevatedButton.styleFrom(
      backgroundColor: isDarkMode ? Colors.white54 : Colors.grey[800],
      foregroundColor: isDarkMode ? Colors.black : Colors.white,
    );
  }

  static Future<void> saveGamesToPrefs(List<Game> games) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> gamesJson =
        games.map((game) => jsonEncode(game.toJson())).toList();
    await prefs.setStringList('games', gamesJson);
  }

  static Future<void> savePlayersToPrefs(List<Player> players) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> playersJson =
        players.map((player) => jsonEncode(player.toJson())).toList();
    await prefs.setStringList('players', playersJson);
  }
}

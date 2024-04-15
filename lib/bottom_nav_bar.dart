import 'package:flutter/material.dart';
import 'package:points_system/classes.dart';
import 'package:points_system/game_service.dart';
import 'package:points_system/games_list.dart';
import 'package:points_system/players_list.dart';
import 'package:points_system/points_counting_app.dart';

class BottomNavBar extends StatefulWidget {
  final List<Game> games;
  final List<Player> players;
  static int selectedIndex = 0;
  const BottomNavBar({super.key, required this.games, required this.players});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = BottomNavBar.selectedIndex;
  int _previousIndex = 0;
  final Game _game = Game(1, "", DateTime.now());
  TextEditingController textFieldController = TextEditingController();

  void _addGame(String value) {
    if (widget.games.isEmpty) {
      setState(() {
        clickedNo = true;
      });
    } else {
      _showStartWithPreviousPlayersDialog();
    }
    if (clickedNo != null) {
      if (clickedNo!) {
        setState(() {
          if (widget.games.isNotEmpty) {
            _game.id = widget.games[widget.games.length - 1].id + 1;
          }
          _game.name = GameService.firstLetterCapital(value);
          _game.date = DateTime.now();

          widget.games.add(_game);
        });
        GameService.saveGamesToPrefs(widget.games);
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PointsCountingApp()));
      } else if (!clickedNo!) {
        Game previousGame = widget.games[widget.games.length - 1];

        for (Player player in previousGame.players) {
          _game.players.add(Player(_game.players.length, player.name));
        }

        setState(() {
          if (widget.games.isNotEmpty) {
            _game.id = widget.games[widget.games.length - 1].id + 1;
          }
          _game.name = GameService.firstLetterCapital(value);
          _game.date = DateTime.now();

          widget.games.add(_game);
        });
        GameService.saveGamesToPrefs(widget.games);
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PointsCountingApp()));
      }
    }
  }

  bool? clickedNo;

  void _showStartWithPreviousPlayersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_outlined),
              SizedBox(width: 10),
              Text('Information'),
            ],
          ),
          content: const Text(
              'Do you want to start the next game with the same players as the previous game?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        clickedNo = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Yes')),
                const SizedBox(
                  width: 5,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      clickedNo = true;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                )
              ],
            )
          ],
        );
      },
    );
  }

  void _showAddGameDialog() {
    FocusNode focusNode = FocusNode(canRequestFocus: true);
    textFieldController.text =
        widget.games.isEmpty ? "" : widget.games[widget.games.length - 1].name;

    setState(() {
      focusNode.requestFocus();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Game"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(
                    text: widget.games.isEmpty
                        ? 1.toString()
                        : (widget.games.length + 1).toString()),
                focusNode: FocusNode(),
                decoration: const InputDecoration(hintText: 'Id'),
                readOnly: true,
                mouseCursor: SystemMouseCursors.basic,
              ),
              TextField(
                controller: textFieldController,
                focusNode: focusNode,
                onSubmitted: (value) {
                  _addGame(value);
                },
                decoration: const InputDecoration(hintText: 'Enter game name'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  BottomNavBar.selectedIndex = _previousIndex;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String value = textFieldController.text;
                _addGame(value);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex != 3) {
        _previousIndex = _selectedIndex;
      }
      _selectedIndex = index;

      if (_selectedIndex == 0 && BottomNavBar.selectedIndex != 0) {
        BottomNavBar.selectedIndex = _selectedIndex;
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const PointsCountingApp()));
      } else if (_selectedIndex == 1 && BottomNavBar.selectedIndex != 1) {
        BottomNavBar.selectedIndex = _selectedIndex;
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => GamesList(
                      games: widget.games,
                      players: widget.players,
                    )));
      } else if (_selectedIndex == 2 && BottomNavBar.selectedIndex != 2) {
        BottomNavBar.selectedIndex = _selectedIndex;
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: ((context) => PlayersList(
                    players: widget.players, games: widget.games))));
      } else if (_selectedIndex == 3 && BottomNavBar.selectedIndex != 3) {
        BottomNavBar.selectedIndex = _selectedIndex;
        _showAddGameDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded), label: 'Games'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_alt), label: 'Players'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Game'),
        ],
        currentIndex: BottomNavBar.selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 173, 206, 116),
        unselectedItemColor: GameService.getColor(),
        showUnselectedLabels: true,
        showSelectedLabels: true,
        onTap: _onItemTapped);
  }
}

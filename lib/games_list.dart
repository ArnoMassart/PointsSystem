import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:points_system/bottom_nav_bar.dart';
import 'package:points_system/classes.dart';
import 'package:points_system/game_detail.dart';
import 'package:points_system/game_service.dart';

class GamesList extends StatefulWidget {
  final List<Game> games;
  final List<Player> players;
  const GamesList({super.key, required this.games, required this.players});

  @override
  State<GamesList> createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
  var sortedGamesList = <Game>[];
  var playersList = <Player>[];
  var selectedPlayerNames = <String>[];
  TextEditingController sortGamesController = TextEditingController();
  FocusNode sortGamesFocus = FocusNode(canRequestFocus: true);
  bool noGamesFound = false;

  @override
  void initState() {
    super.initState();
    BottomNavBar.selectedIndex = 1;
    playersList = widget.players;
  }

  void _deleteGame(int index) {
    setState(() {
      widget.games.removeAt(index);
    });
    GameService.saveGamesToPrefs(widget.games);
  }

  void sortGamesList(String value) {
    sortedGamesList = [];
    _playerNameButtons = {};
    selectedPlayerNames = [];
    playersList = widget.players;
    setState(() {
      print(playersList.length);
      for (Game game in widget.games) {
        if (game.name.toLowerCase().contains(value.toLowerCase())) {
          sortedGamesList.add(game);
        }
      }
      if (sortedGamesList.isNotEmpty) {
        sortedGamesList.sort(((a, b) => a.id.compareTo(b.id)));
      } else {
        noGamesFound = true;
      }
      sortGamesFocus.requestFocus();
    });
  }

  void checkSortedList(List<Game> games) {
    sortGamesController.text = "";
    sortedGamesList = games
        .where((game) => selectedPlayerNames.every((playerName) =>
            game.players.any((player) => player.name == playerName)))
        .toList();

    if (sortedGamesList.isEmpty) {
      noGamesFound = true;
    }
  }

  Widget _buildRow(int i, List<Game> games) {
    return ListTile(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameDetail(
                      game: games[i],
                      games: games,
                      players: widget.players,
                    )));
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(games[i].name),
          GestureDetector(
            child: const Icon(
              Icons.delete_rounded,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_outlined,
                        ),
                        GameService.getSizedBox(
                          width: 10,
                        ),
                        Text('Delete Game: ${games[i].name}'),
                      ],
                    ),
                    content: const Text(
                        'Are you sure you want to delete this game!'),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              _deleteGame(i);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Yes'),
                          ),
                          GameService.getSizedBox(
                            width: 5,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          )
                        ],
                      )
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      subtitle: Text(
          "${games[i].date.day < 10 ? "0${games[i].date.day}" : games[i].date.day}-${games[i].date.month < 10 ? "0${games[i].date.month}" : games[i].date.month}-${games[i].date.year}"),
    );
  }

  double constraintHeight = 0;
  double maxConstraintHeight = 250;
  Map<Key, ElevatedButton> _playerNameButtons = {};

  @override
  Widget build(BuildContext context) {
    constraintHeight = widget.players.length * 50;
    if (constraintHeight > maxConstraintHeight) {
      constraintHeight = maxConstraintHeight;
    }

    setState(() {
      if (_playerNameButtons.isEmpty && sortGamesController.text.isEmpty) {
        sortedGamesList = [];
        selectedPlayerNames = [];
      }
      playersList.sort(((a, b) => a.name.compareTo(b.name)));
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          toolbarHeight: 200,
          title: widget.games.isEmpty
              ? const Text("")
              : const Text(
                  "Games",
                  style: TextStyle(fontSize: 45),
                ),
        ),
      ),
      body: widget.games.isEmpty
          ? const Center(
              heightFactor: Checkbox.width,
              widthFactor: Checkbox.width,
              child: Text(
                "No games in the list.",
                style: TextStyle(fontSize: 32),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Text(
                        "Filter Games",
                        style: GameService.getTextStyle(
                          fontSize: 18,
                        ),
                      ),
                      GameService.getSizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: TextField(
                          readOnly: _playerNameButtons.isNotEmpty,
                          controller: sortGamesController,
                          focusNode: sortGamesFocus,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                sortedGamesList = [];
                                noGamesFound = false;
                              });
                            }
                            sortGamesList(value);
                          },
                          decoration: const InputDecoration(
                              hintText: 'Enter game name'),
                        ),
                      ),
                    ],
                  ),
                ),
                GameService.getSizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: PopupMenuButton<String>(
                          icon: Row(
                            children: [
                              Text(
                                'Players Filter',
                                style: GameService.getTextStyle(fontSize: 18),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const Icon(
                                Icons.keyboard_arrow_right_outlined,
                              ),
                            ],
                          ),
                          offset: const Offset(0, 10),
                          constraints: BoxConstraints.expand(
                            height: constraintHeight,
                            width: 100,
                          ),
                          position: PopupMenuPosition.under,
                          onSelected: (newValue) {
                            setState(() {
                              if (playersList.isNotEmpty) {
                                Key key = UniqueKey();
                                _playerNameButtons[key] = ElevatedButton(
                                  onPressed: () {
                                    // Handle button press
                                  },
                                  child: Row(
                                    children: [
                                      Text(newValue),
                                      GameService.getSizedBox(width: 5),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _playerNameButtons.remove(key);
                                            playersList.add(Player(
                                                playersList.length, newValue));
                                            selectedPlayerNames
                                                .remove(newValue);
                                            noGamesFound = false;
                                            checkSortedList(widget.games);
                                          });
                                        },
                                        child: Icon(Icons.remove),
                                      ),
                                    ],
                                  ),
                                );

                                selectedPlayerNames.add(newValue);

                                playersList.removeWhere(
                                    (element) => element.name == newValue);

                                checkSortedList(widget.games);
                              }
                            });
                          },
                          itemBuilder: (BuildContext context) =>
                              widget.players.map((player) {
                            return PopupMenuItem<String>(
                              value: player.name,
                              child: Text(player.name),
                            );
                          }).toList(),
                        ),
                      ),
                      Row(
                        children: _playerNameButtons.values.toList(),
                      ),
                    ],
                  ),
                ),
                GameService.getSizedBox(height: 25),
                noGamesFound
                    ? const Center(
                        heightFactor: Checkbox.width / 2,
                        widthFactor: Checkbox.width / 2,
                        child: Text(
                          "No games in the list.",
                          style: TextStyle(fontSize: 32),
                        ),
                      )
                    : Expanded(
                        child: ListView.separated(
                          itemCount: sortedGamesList.isEmpty
                              ? widget.games.length
                              : sortedGamesList.length,
                          itemBuilder: (BuildContext context, int position) {
                            if (sortedGamesList.isEmpty) {
                              return _buildRow(position, widget.games);
                            } else {
                              return _buildRow(position, sortedGamesList);
                            }
                          },
                          separatorBuilder: (context, index) {
                            return Divider(
                              color: GameService.isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                              thickness: 1,
                              height: 20,
                            );
                          },
                        ),
                      ),
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        games: widget.games,
        players: widget.players,
      ),
    );
  }
}

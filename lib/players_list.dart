import 'package:flutter/material.dart';
import 'package:points_system/bottom_nav_bar.dart';
import 'package:points_system/classes.dart';
import 'package:points_system/game_service.dart';

class PlayersList extends StatefulWidget {
  final List<Player> players;
  final List<Game> games;
  const PlayersList({super.key, required this.players, required this.games});

  @override
  State<PlayersList> createState() => _PlayersListState();
}

class _PlayersListState extends State<PlayersList> {
  void _deletePlayer(int i) {
    setState(() {
      widget.players.removeAt(i);
    });
    GameService.savePlayersToPrefs(widget.players);
  }

  Widget _buildRow(int i) {
    return ListTile(
      onTap: () {
        _showEditPlayerNameDialog(widget.players[i]);
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${i + 1}. ${widget.players[i].name}'),
          GestureDetector(
            child: const Icon(Icons.delete_rounded),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        const Icon(Icons.warning_amber_outlined),
                        const SizedBox(width: 10),
                        Text('Delete Player: ${widget.players[i].name}'),
                      ],
                    ),
                    content: const Text(
                        'Are you sure you want to delete this player!'),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: () {
                                _deletePlayer(i);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Yes')),
                          const SizedBox(
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
    );
  }

  void _showAddPlayerDialog(BuildContext context) {
    TextEditingController textFieldController = TextEditingController();
    FocusNode focusNode = FocusNode(canRequestFocus: true);

    setState(() {
      focusNode.requestFocus();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Player"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              hasBeenFound
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Name can't be a duplicate!",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    )
                  : const Text(''),
              TextField(
                controller: textFieldController,
                focusNode: focusNode,
                decoration:
                    const InputDecoration(hintText: 'Enter player name'),
                onSubmitted: (value) {
                  _addPlayer(value);
                },
                style: GameService.getTextStyle(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String value = textFieldController.text;
                _addPlayer(value);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _editPlayerName(Player player, String value) {
    Player previousPlayer = player;
    RegExp pattern = RegExp(r'^[a-zA-Zéçàèù\-]+$');
    if (pattern.hasMatch(value)) {
      String playerName = GameService.firstLetterCapital(value);
      for (Game game in widget.games) {
        for (Player p in game.players) {
          if (p.name == previousPlayer.name) {
            setState(() {
              p.name = playerName;
            });
          }
        }
      }
      setState(() {
        player.name = playerName;
      });
      GameService.saveGamesToPrefs(widget.games);
      GameService.savePlayersToPrefs(widget.players);
      Navigator.of(context).pop();
    }
  }

  void _showEditPlayerNameDialog(Player player) {
    TextEditingController textFieldController =
        TextEditingController(text: player.name);
    FocusNode focusNode = FocusNode(canRequestFocus: true);

    setState(() {
      focusNode.requestFocus();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Player Name"),
          content: TextField(
            controller: textFieldController,
            focusNode: focusNode,
            decoration: const InputDecoration(hintText: 'Enter player name'),
            onSubmitted: (value) {
              _editPlayerName(player, value);
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String value = textFieldController.text;
                _editPlayerName(player, value);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  bool hasBeenFound = false;

  _addPlayer(String value) {
    RegExp pattern = RegExp(r'^[a-zA-Zéçàèù\-]+$');
    if (pattern.hasMatch(value)) {
      String playerName = GameService.firstLetterCapital(value);
      bool found = false;
      for (Player player in widget.players) {
        if (player.name == playerName) {
          found = true;
          break;
        }
      }

      if (found) {
        setState(() {
          hasBeenFound = true;
          Navigator.of(context).pop();
          _showAddPlayerDialog(context);
        });
      } else {
        setState(() {
          hasBeenFound = false;
          widget.players.add(Player(
              widget.players.isEmpty
                  ? 1
                  : widget.players[widget.players.length - 1].id + 1,
              playerName));
        });
        GameService.savePlayersToPrefs(widget.players);
        Navigator.of(context).pop();
      }
    }
  }

  bool isASelected = false;

  void toggleAlphabeticalSelection() {
    setState(() {
      isASelected = !isASelected;

      if (isASelected) {
        widget.players.sort(((a, b) => a.name.compareTo(b.name)));
      } else {
        widget.players.sort((a, b) => a.id.compareTo(b.id));
      }
    });
  }

  bool isZSelected = false;

  void toggleReverseAlphabeticalSelection() {
    setState(() {
      isZSelected = !isZSelected;

      if (isZSelected) {
        widget.players.sort(((a, b) => b.name.compareTo(a.name)));
      } else {
        widget.players.sort((a, b) => a.id.compareTo(b.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          toolbarHeight: 200,
          title: const Text(
            'Players',
            style: TextStyle(fontSize: 45),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 25),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showAddPlayerDialog(context);
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add,
                      ),
                      GameService.getSizedBox(width: 5),
                      const Text(
                        "Add Player",
                      ),
                    ],
                  ),
                ),
                GameService.getSizedBox(width: 15),
                ElevatedButton(
                  onPressed: toggleAlphabeticalSelection,
                  style: isASelected
                      ? GameService.getButtonStyleWithBackgroundChange()
                      : const ButtonStyle(),
                  child: const Text('A-Z'),
                ),
                GameService.getSizedBox(width: 15),
                ElevatedButton(
                  onPressed: toggleReverseAlphabeticalSelection,
                  style: isZSelected
                      ? GameService.getButtonStyleWithBackgroundChange()
                      : const ButtonStyle(),
                  child: const Text('Z-A'),
                ),
              ],
            ),
          ),
          widget.players.isEmpty
              ? const Text('')
              : Expanded(
                  child: ListView.separated(
                    itemCount: widget.players.length,
                    itemBuilder: (BuildContext context, int position) {
                      return _buildRow(position);
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
                )
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        games: widget.games,
        players: widget.players,
      ),
    );
  }
}

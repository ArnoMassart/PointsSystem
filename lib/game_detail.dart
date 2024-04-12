import 'package:flutter/material.dart';
import 'package:points_system/classes.dart';
import 'package:points_system/game_service.dart';

class GameDetail extends StatefulWidget {
  final Game game;
  final List<Game> games;
  final List<Player> players;
  const GameDetail(
      {super.key,
      required this.game,
      required this.games,
      required this.players});

  @override
  State<GameDetail> createState() => _GameDetailState();
}

class _GameDetailState extends State<GameDetail> {
  bool _readOnly = true;

  int _maxPoints(Game game) {
    int max = 0;
    for (Player player in game.players) {
      if (player.points.length > max) {
        max = player.points.length;
      }
    }
    return max;
  }

  void _addNewScore(Game game) {
    for (var player in game.players) {
      player.points.add(Point(player.points.length + 1, 0));
    }
  }

  List<DataColumn> _buildColumns(game) {
    List<DataColumn> columns = [
      const DataColumn(label: Text('Name')),
    ];

    if (game.players.isNotEmpty) {
      for (var i = 1; i <= _maxPoints(game); i++) {
        columns.add(DataColumn(label: Text('Score $i')));
      }

      if (!_readOnly) {
        columns.add(
          DataColumn(
            label: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    _addNewScore(game);
                  });
                  await GameService.saveGamesToPrefs(widget.games);
                },
                child: const Icon(Icons.add),
              ),
            ),
          ),
        );
      }

      columns.add(const DataColumn(label: Text('Total')));

      if (!_readOnly) {
        columns.add(const DataColumn(label: Text('')));
      }
    }
    return columns;
  }

  double constraintHeight = 0;
  double maxConstraintHeight = 250;

  List<DataRow> _buildRows(Game game) {
    List<DataRow> rows = [];
    constraintHeight = widget.players.length * 50;
    if (constraintHeight > maxConstraintHeight) {
      constraintHeight = maxConstraintHeight;
    }
    for (var player in game.players) {
      List<DataCell> cells = [
        DataCell(
          _readOnly
              ? Text(
                  player.name.toString(),
                )
              : PopupMenuButton<String>(
                  icon: Row(
                    children: [
                      Text(player.name.isEmpty ? 'Select Player' : player.name),
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
                      height: constraintHeight, width: 100),
                  position: PopupMenuPosition.under,
                  onSelected: (newValue) {
                    setState(() {
                      player.name = newValue;
                    });
                    GameService.saveGamesToPrefs(widget.games);
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
      ];

      if (!_readOnly) {
        for (var i = 0; i < _maxPoints(game); i++) {
          if (player.points.length != _maxPoints(game)) {
            for (var j = 0; i < _maxPoints(game) - player.points.length; j++) {
              player.points.add(Point(player.points.length + 1, 0));
            }
          }
        }
      }

      for (Point point in player.points) {
        cells.add(DataCell(
          _readOnly
              ? Center(
                  child: Text(
                    point.value.toString(),
                  ),
                )
              : EditableText(
                  controller:
                      TextEditingController(text: point.value.toString()),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onSubmitted: (newValue) {
                    final index = player.points.indexOf(point);
                    setState(() {
                      player.points[index].value = int.tryParse(newValue) ?? 0;
                      player.calculateTotal();
                    });

                    GameService.saveGamesToPrefs(widget.games);
                  },
                  focusNode: FocusNode(),
                  style: GameService.getTextStyle(),
                  cursorColor: GameService.getColor(),
                  backgroundCursorColor: Colors.black,
                ),
        ));
      }

      if (!_readOnly) {
        cells.add(DataCell.empty);
      }

      player.calculateTotal();
      cells.add(
        DataCell(Center(
          child: Text(
            player.total.toString(),
          ),
        )),
      );

      if (!_readOnly) {
        cells.add(DataCell(Center(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                _showDeletePlayerFromGameDialog(player, game);
              },
              child: const Icon(Icons.delete_rounded),
            ),
          ),
        )));
      }

      rows.add(DataRow(cells: cells));
    }

    if (!_readOnly) {
      List<DataCell> cells = [];

      cells.add(DataCell(
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  game.players.add(Player(game.players.length + 1, ''));
                });
                GameService.saveGamesToPrefs(widget.games);
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ));

      for (int i = 1; i < _buildColumns(game).length; i++) {
        cells.add(DataCell.empty);
      }

      rows.add(DataRow(cells: cells));
    }

    return rows;
  }

  void _deletePlayerFromGame(Player player, Game game) {
    setState(() {
      game.players.remove(player);
    });
    GameService.saveGamesToPrefs(widget.games);
  }

  void _showDeletePlayerFromGameDialog(Player player, Game game) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_outlined),
              const SizedBox(width: 10),
              Text('Delete Player: ${player.name}'),
            ],
          ),
          content: const Text('Are you sure you want to delete this player!'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      _deletePlayerFromGame(player, game);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: EditableText(
          controller: TextEditingController(text: widget.game.name),
          keyboardType: TextInputType.name,
          textAlign: TextAlign.left,
          onSubmitted: (value) {
            setState(() {
              widget.game.name = GameService.firstLetterCapital(value);
            });
            GameService.saveGamesToPrefs(widget.games);
          },
          focusNode: FocusNode(),
          style: GameService.getTextStyle(fontSize: 25),
          cursorColor: GameService.getColor(),
          backgroundCursorColor: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerTheme: DividerThemeData(
                    color: GameService.isDarkMode
                        ? Colors.grey[300]
                        : Colors.grey[700], // Set divider color based on theme
                    thickness: 1, // Set divider thickness
                    space: 20, // Set divider padding
                  ),
                ),
                child: DataTable(
                  columns: _buildColumns(widget.game),
                  rows: _buildRows(widget.game),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 5),
              child: ElevatedButton(
                style: GameService.getButtonStyleWithBackgroundChange(),
                onPressed: () {
                  setState(() {
                    _readOnly = !_readOnly;
                    if (!_readOnly) {
                      GameService.saveGamesToPrefs(widget.games);
                    }
                  });
                },
                child: Text(
                  _readOnly ? 'Edit' : 'Save',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

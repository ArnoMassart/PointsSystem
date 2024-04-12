import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    BottomNavBar.selectedIndex = 1;
  }

  void _deleteGame(int index) {
    setState(() {
      widget.games.removeAt(index);
    });
    GameService.saveGamesToPrefs(widget.games);
  }

  Widget _buildRow(int i) {
    return ListTile(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameDetail(
                      game: widget.games[i],
                      games: widget.games,
                      players: widget.players,
                    )));
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.games[i].name),
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
                        Text('Delete Game: ${widget.games[i].name}'),
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
      subtitle: Text(
          "${widget.games[i].date.day < 10 ? "0${widget.games[i].date.day}" : widget.games[i].date.day}-${widget.games[i].date.month < 10 ? "0${widget.games[i].date.month}" : widget.games[i].date.month}-${widget.games[i].date.year}"),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          : ListView.separated(
              itemCount: widget.games.length,
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
              }),
      bottomNavigationBar: BottomNavBar(
        games: widget.games,
        players: widget.players,
      ),
    );
  }
}

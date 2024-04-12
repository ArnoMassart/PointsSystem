class Game {
  Game(this.id, this.name, this.date, {List<Player>? players})
      : players = players ?? [];

  int id;
  String name;
  DateTime date;
  List<Player> players;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'players': players.map((player) => player.toJson()).toList(),
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      json['id'],
      json['name'],
      DateTime.parse(json['date']),
      players: List<Player>.from(
          json['players'].map((playerJson) => Player.fromJson(playerJson))),
    );
  }
}

class Player {
  Player(this.id, this.name, {List<Point>? points}) : points = points ?? [];

  int id;
  String name;
  List<Point> points;
  late int total;

  void calculateTotal() {
    int total = 0;
    for (var point in points) {
      total += point.value;
    }

    this.total = total;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points.map((point) => point.toJson()).toList(),
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      json['id'],
      json['name'],
      points: List<Point>.from(
          json['points'].map((pointJson) => Point.fromJson(pointJson))),
    );
  }
}

class Point {
  Point(this.id, this.value);

  int id;
  int value;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
    };
  }

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      json['id'],
      json['value'],
    );
  }
}

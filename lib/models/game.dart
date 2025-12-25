import 'mode.dart';

class Game {
  final String icon;
  final String name;
  final String description;
  final List<Mode> modes;

  const Game({
    required this.icon,
    required this.name,
    required this.description,
    required this.modes,
  });

  static const List<Game> availableGames = [
    Game(
      icon: '🎭',
      name: 'Impostor',
      description: 'Find the impostor among the players',
      modes: [Mode.localMultiplayer, Mode.selfMultiplayer],
    ),
  ];
}

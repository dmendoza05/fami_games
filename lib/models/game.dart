enum GameType {
  impostor,
  // Add more game types here in the future
}

class Game {
  final GameType type;
  final String name;
  final String description;
  final String icon;

  const Game({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
  });

  static const List<Game> availableGames = [
    Game(
      type: GameType.impostor,
      name: 'Impostor',
      description: 'Find the impostor among you by giving clues and voting!',
      icon: '🎭',
    ),
  ];
}


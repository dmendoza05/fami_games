class Player {
  final String id;
  final String name;
  final String? word;
  final bool isImpostor;
  final bool isEliminated;
  final String? clue;

  Player({
    required this.id,
    required this.name,
    this.word,
    this.isImpostor = false,
    this.isEliminated = false,
    this.clue,
  });

  Player copyWith({
    String? id,
    String? name,
    String? word,
    bool? isImpostor,
    bool? isEliminated,
    String? clue,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      word: word ?? this.word,
      isImpostor: isImpostor ?? this.isImpostor,
      isEliminated: isEliminated ?? this.isEliminated,
      clue: clue ?? this.clue,
    );
  }
}


import '../../../models/player.dart';

enum ImpostorGamePhase {
  setup,
  clueGiving,
  debate,
  voting,
  reveal,
  gameOver,
}

enum GameResult {
  innocentsWin,
  impostorWins,
  none,
}

class ImpostorGameState {
  final List<Player> players;
  final ImpostorGamePhase phase;
  final String? secretWord;
  final int currentPlayerIndex;
  final Map<String, String> votes; // voterId -> votedPlayerId
  final String? eliminatedPlayerId;
  final GameResult result;
  final String? impostorGuess;

  ImpostorGameState({
    required this.players,
    this.phase = ImpostorGamePhase.setup,
    this.secretWord,
    this.currentPlayerIndex = 0,
    this.votes = const {},
    this.eliminatedPlayerId,
    this.result = GameResult.none,
    this.impostorGuess,
  });

  ImpostorGameState copyWith({
    List<Player>? players,
    ImpostorGamePhase? phase,
    String? secretWord,
    int? currentPlayerIndex,
    Map<String, String>? votes,
    String? eliminatedPlayerId,
    GameResult? result,
    String? impostorGuess,
  }) {
    return ImpostorGameState(
      players: players ?? this.players,
      phase: phase ?? this.phase,
      secretWord: secretWord ?? this.secretWord,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      votes: votes ?? this.votes,
      eliminatedPlayerId: eliminatedPlayerId ?? this.eliminatedPlayerId,
      result: result ?? this.result,
      impostorGuess: impostorGuess ?? this.impostorGuess,
    );
  }

  Player? get currentPlayer {
    if (currentPlayerIndex >= 0 && currentPlayerIndex < players.length) {
      return players[currentPlayerIndex];
    }
    return null;
  }

  Player? get impostor {
    try {
      return players.firstWhere((p) => p.isImpostor);
    } catch (e) {
      return null;
    }
  }

  bool get allPlayersGaveClues {
    return players.every((p) => p.clue != null && p.clue?.isNotEmpty == true);
  }

  bool get allPlayersVoted {
    final activePlayers = players.where((p) => !p.isEliminated).toList();
    return votes.length == activePlayers.length;
  }
}


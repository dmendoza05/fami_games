import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/impostor_game_state.dart';
import '../../../models/player.dart';

class ImpostorGameNotifier extends StateNotifier<ImpostorGameState> {
  ImpostorGameNotifier() : super(ImpostorGameState(players: []));

  // Secret words pool
  static const List<String> secretWords = [
    'Pizza',
    'Ocean',
    'Guitar',
    'Dragon',
    'Rainbow',
    'Telescope',
    'Volcano',
    'Butterfly',
    'Spaceship',
    'Treasure',
    'Castle',
    'Diamond',
    'Thunder',
    'Phoenix',
    'Galaxy',
  ];

  void initializeGame(List<String> playerNames) {
    if (playerNames.length < 3) {
      throw Exception('Need at least 3 players');
    }

    // Select random secret word
    final word =
        secretWords[DateTime.now().millisecondsSinceEpoch % secretWords.length];

    // Create players
    final players = playerNames.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;
      final isImpostor = index == 0; // First player is impostor

      return Player(
        id: 'player_$index',
        name: name,
        word: isImpostor ? null : word,
        isImpostor: isImpostor,
      );
    }).toList();

    // Shuffle players to randomize impostor
    players.shuffle();
    final impostorIndex = players.indexWhere((p) => p.isImpostor);
    if (impostorIndex != -1 && impostorIndex < players.length) {
      // Ensure impostor doesn't have the word
      final impostor = players[impostorIndex];
      players[impostorIndex] = impostor.copyWith(word: null);
    }

    state = state.copyWith(
      players: players,
      secretWord: word,
      phase: ImpostorGamePhase.clueGiving,
      currentPlayerIndex: 0,
    );
  }

  void submitClue(String playerId, String clue) {
    final updatedPlayers = state.players.map((player) {
      if (player.id == playerId) {
        return player.copyWith(clue: clue);
      }
      return player;
    }).toList();

    final currentIndex = state.currentPlayerIndex;
    final nextIndex = currentIndex + 1;

    if (nextIndex >= state.players.length) {
      // All players gave clues, move to debate
      state = state.copyWith(
        players: updatedPlayers,
        phase: ImpostorGamePhase.debate,
        currentPlayerIndex: 0,
      );
    } else {
      state = state.copyWith(
        players: updatedPlayers,
        currentPlayerIndex: nextIndex,
      );
    }
  }

  void startVoting() {
    state = state.copyWith(phase: ImpostorGamePhase.voting);
  }

  void submitVote(String voterId, String votedPlayerId) {
    final updatedVotes = Map<String, String>.from(state.votes);
    updatedVotes[voterId] = votedPlayerId;

    state = state.copyWith(votes: updatedVotes);

    // Check if all players voted
    if (state.allPlayersVoted) {
      _processVotingResults();
    }
  }

  void _processVotingResults() {
    // Count votes
    final voteCounts = <String, int>{};
    for (final votedPlayerId in state.votes.values) {
      voteCounts[votedPlayerId] = (voteCounts[votedPlayerId] ?? 0) + 1;
    }

    // Find player with most votes
    String? eliminatedId;
    int maxVotes = 0;
    voteCounts.forEach((playerId, count) {
      if (count > maxVotes) {
        maxVotes = count;
        eliminatedId = playerId;
      }
    });

    if (eliminatedId != null) {
      final updatedPlayers = state.players.map((player) {
        if (player.id == eliminatedId!) {
          return player.copyWith(isEliminated: true);
        }
        return player;
      }).toList();

      state = state.copyWith(
        players: updatedPlayers,
        eliminatedPlayerId: eliminatedId,
        phase: ImpostorGamePhase.reveal,
      );
    }
  }

  void submitImpostorGuess(String guess) {
    final isCorrect =
        guess.toLowerCase().trim() == state.secretWord?.toLowerCase().trim();

    state = state.copyWith(
      impostorGuess: guess,
      result: isCorrect ? GameResult.impostorWins : GameResult.innocentsWin,
      phase: ImpostorGamePhase.gameOver,
    );
  }

  void skipImpostorGuess() {
    state = state.copyWith(
      result: GameResult.innocentsWin,
      phase: ImpostorGamePhase.gameOver,
    );
  }

  void resetGame() {
    state = ImpostorGameState(players: []);
  }
}

final impostorGameProvider =
    StateNotifierProvider<ImpostorGameNotifier, ImpostorGameState>(
      (ref) => ImpostorGameNotifier(),
    );

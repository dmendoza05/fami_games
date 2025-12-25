import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';
import '../models/impostor_game_state.dart';
import '../models/turn_order.dart';
import '../../../models/player.dart';
import '../../../models/mode.dart';

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

  void initializeGame(
    List<String> playerNames,
    Mode gameMode,
    TurnOrder turnOrder,
    int maxGuessingPhases,
  ) {
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

    // Determine starting player index based on turn order
    int startingPlayerIndex = 0;
    if (turnOrder == TurnOrder.sequential) {
      // Sequential: first player (index 0) starts round 1
      // For future rounds, this will rotate: round 2 starts with player 1, etc.
      startingPlayerIndex = 0;
    } else if (turnOrder == TurnOrder.randomized) {
      // Randomized: random starting player
      startingPlayerIndex = Random().nextInt(players.length);
    }

    state = state.copyWith(
      players: players,
      secretWord: word,
      phase: ImpostorGamePhase.clueGiving,
      currentPlayerIndex: startingPlayerIndex,
      gameMode: gameMode,
      turnOrder: turnOrder,
      currentRound: 1,
      maxGuessingPhases: maxGuessingPhases,
      currentGuessingPhase: 1,
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
    final activePlayers = updatedPlayers.where((p) => !p.isEliminated).toList();

    // Find next player index
    int nextIndex;
    if (state.turnOrder == TurnOrder.sequential) {
      // Sequential: move to next player in order, wrapping around
      nextIndex = (currentIndex + 1) % state.players.length;
      // Skip eliminated players
      while (updatedPlayers[nextIndex].isEliminated &&
          nextIndex != currentIndex) {
        nextIndex = (nextIndex + 1) % state.players.length;
      }
    } else {
      // Randomized: for now, just go to next player
      // In a full implementation, we'd shuffle the order each round
      nextIndex = (currentIndex + 1) % state.players.length;
      while (updatedPlayers[nextIndex].isEliminated &&
          nextIndex != currentIndex) {
        nextIndex = (nextIndex + 1) % state.players.length;
      }
    }

    // Check if all active players have given clues
    final allGaveClues = activePlayers.every(
      (p) => p.clue != null && p.clue?.isNotEmpty == true,
    );

    if (allGaveClues) {
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

  void hostPickImpostor(String pickedPlayerId) {
    final pickedPlayer = state.players.firstWhere(
      (p) => p.id == pickedPlayerId,
    );
    final isImpostor = pickedPlayer.isImpostor;

    if (isImpostor) {
      // Impostor was picked - innocents win
      state = state.copyWith(
        eliminatedPlayerId: pickedPlayerId,
        result: GameResult.innocentsWin,
        phase: ImpostorGamePhase.gameOver,
      );
    } else {
      // Impostor was NOT picked - eliminate accused player and continue
      final updatedPlayers = state.players.map((player) {
        if (player.id == pickedPlayerId) {
          return player.copyWith(isEliminated: true);
        }
        return player;
      }).toList();

      final nextGuessingPhase = state.currentGuessingPhase + 1;
      final activePlayers = updatedPlayers
          .where((p) => !p.isEliminated)
          .toList();
      final impostorStillAlive = activePlayers.any((p) => p.isImpostor);

      // Check if impostor survives all phases
      if (!impostorStillAlive) {
        // Impostor was eliminated - innocents win
        state = state.copyWith(
          players: updatedPlayers,
          eliminatedPlayerId: pickedPlayerId,
          result: GameResult.innocentsWin,
          phase: ImpostorGamePhase.gameOver,
        );
      } else if (nextGuessingPhase > state.maxGuessingPhases) {
        // Impostor survived all phases - impostor wins
        state = state.copyWith(
          players: updatedPlayers,
          eliminatedPlayerId: pickedPlayerId,
          result: GameResult.impostorWins,
          phase: ImpostorGamePhase.gameOver,
        );
      } else {
        // Continue to next guessing phase
        // Reset clues and votes for next round
        final resetPlayers = updatedPlayers.map((player) {
          return player.copyWith(clue: null);
        }).toList();

        state = state.copyWith(
          players: resetPlayers,
          eliminatedPlayerId: pickedPlayerId,
          currentGuessingPhase: nextGuessingPhase,
          votes: {},
          phase: ImpostorGamePhase.clueGiving,
          currentPlayerIndex: 0,
        );
      }
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

      final activePlayers = updatedPlayers
          .where((p) => !p.isEliminated)
          .toList();
      final impostorStillAlive = activePlayers.any((p) => p.isImpostor);

      if (!impostorStillAlive) {
        // Impostor was eliminated - innocents win
        state = state.copyWith(
          players: updatedPlayers,
          eliminatedPlayerId: eliminatedId,
          result: GameResult.innocentsWin,
          phase: ImpostorGamePhase.gameOver,
        );
      } else {
        // Continue to reveal phase
        state = state.copyWith(
          players: updatedPlayers,
          eliminatedPlayerId: eliminatedId,
          phase: ImpostorGamePhase.reveal,
        );
      }
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

  void startSetup() {
    state = state.copyWith(phase: ImpostorGamePhase.setup);
  }

  void resetGame() {
    state = ImpostorGameState(
      players: [],
    ).copyWith(phase: ImpostorGamePhase.landing);
  }
}

final impostorGameProvider =
    StateNotifierProvider<ImpostorGameNotifier, ImpostorGameState>(
      (ref) => ImpostorGameNotifier(),
    );

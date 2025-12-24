import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/impostor_game_state.dart';
import '../providers/impostor_game_provider.dart';
import '../widgets/impostor_setup_widget.dart';
import '../widgets/impostor_clue_widget.dart';
import '../widgets/impostor_debate_widget.dart';
import '../widgets/impostor_voting_widget.dart';
import '../widgets/impostor_reveal_widget.dart';
import '../widgets/impostor_game_over_widget.dart';

class ImpostorGameScreen extends HookConsumerWidget {
  const ImpostorGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(impostorGameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (gameState.phase == ImpostorGamePhase.setup ||
                gameState.phase == ImpostorGamePhase.gameOver) {
              Navigator.pop(context);
            } else {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Leave Game?'),
                  content: const Text('Are you sure you want to leave? Progress will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(impostorGameProvider.notifier).resetGame();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Leave'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      body: _buildPhaseContent(context, ref, gameState),
    );
  }

  Widget _buildPhaseContent(
    BuildContext context,
    WidgetRef ref,
    ImpostorGameState gameState,
  ) {
    switch (gameState.phase) {
      case ImpostorGamePhase.setup:
        return const ImpostorSetupWidget();
      case ImpostorGamePhase.clueGiving:
        return const ImpostorClueWidget();
      case ImpostorGamePhase.debate:
        return const ImpostorDebateWidget();
      case ImpostorGamePhase.voting:
        return const ImpostorVotingWidget();
      case ImpostorGamePhase.reveal:
        return const ImpostorRevealWidget();
      case ImpostorGamePhase.gameOver:
        return const ImpostorGameOverWidget();
    }
  }
}


import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../models/impostor_game_state.dart';
import '../providers/impostor_game_provider.dart';
import '../widgets/impostor_landing_widget.dart';
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
      body: Container(
        decoration: AppTheme.gradientDecoration,
        child: _buildPhaseContent(context, ref, gameState),
      ),
    );
  }

  Widget _buildPhaseContent(
    BuildContext context,
    WidgetRef ref,
    ImpostorGameState gameState,
  ) {
    switch (gameState.phase) {
      case ImpostorGamePhase.landing:
        return const ImpostorLandingWidget();
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

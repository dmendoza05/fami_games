import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/impostor_game_provider.dart';
import '../models/impostor_game_state.dart';

class ImpostorClueWidget extends HookConsumerWidget {
  const ImpostorClueWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(impostorGameProvider);
    final clueController = useTextEditingController();
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    final fadeAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn),
      ),
      [animationController],
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, [gameState.currentPlayerIndex]);

    final currentPlayer = gameState.currentPlayer;
    if (currentPlayer == null) return const SizedBox();

    final isImpostor = currentPlayer.isImpostor;
    final hasGivenClue =
        currentPlayer.clue != null && currentPlayer.clue!.isNotEmpty;

    void submitClue() {
      final clue = clueController.text.trim();
      if (clue.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a clue'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ref
          .read(impostorGameProvider.notifier)
          .submitClue(currentPlayer.id, clue);
      clueController.clear();
    }

    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          isImpostor
                              ? '🎭 You are the IMPOSTOR!'
                              : '✅ You are innocent',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isImpostor ? Colors.red : Colors.green,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (!isImpostor)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Secret Word',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  gameState.secretWord ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        if (isImpostor)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'You don\'t know the word!',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Listen carefully to clues and try to blend in',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '${currentPlayer.name}\'s Turn',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Give a one-word clue related to the secret word',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (hasGivenClue)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your clue: "${currentPlayer.clue}"',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  TextField(
                    controller: clueController,
                    decoration: InputDecoration(
                      labelText: 'Enter your clue',
                      hintText: 'One word only',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    textCapitalization: TextCapitalization.none,
                    onSubmitted: (_) => submitClue(),
                  ),
                const SizedBox(height: 16),
                if (!hasGivenClue)
                  ElevatedButton(
                    onPressed: submitClue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Clue',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                const Spacer(),
                _buildProgressIndicator(context, gameState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    ImpostorGameState gameState,
  ) {
    final total = gameState.players.length;
    final completed = gameState.players
        .where((p) => p.clue != null && p.clue?.isNotEmpty == true)
        .length;

    return Column(
      children: [
        LinearProgressIndicator(
          value: completed / total,
          backgroundColor: Colors.grey[300],
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text(
          '$completed / $total clues given',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

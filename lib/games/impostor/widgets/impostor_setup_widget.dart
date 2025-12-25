import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/impostor_game_provider.dart';

class ImpostorSetupWidget extends HookConsumerWidget {
  const ImpostorSetupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerNames = useState<List<String>>(['']);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final slideAnimation = useMemoized(
      () =>
          Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(parent: animationController, curve: Curves.easeOut),
          ),
      [animationController],
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    void addPlayer() {
      playerNames.value = [...playerNames.value, ''];
    }

    void removePlayer(int index) {
      if (playerNames.value.length > 1) {
        final updated = List<String>.from(playerNames.value);
        updated.removeAt(index);
        playerNames.value = updated;
      }
    }

    void updatePlayerName(int index, String name) {
      final updated = List<String>.from(playerNames.value);
      updated[index] = name;
      playerNames.value = updated;
    }

    void startGame() {
      final validNames = playerNames.value
          .where((name) => name.trim().isNotEmpty)
          .map((name) => name.trim())
          .toList();

      if (validNames.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need at least 3 players to start!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        ref.read(impostorGameProvider.notifier).initializeGame(validNames);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }

    return SlideTransition(
      position: slideAnimation,
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
                Text(
                  'Setup Players',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add at least 3 players to start the game',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: playerNames.value.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Player ${index + 1}',
                                  hintText: 'Enter name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                ),
                                onChanged: (value) =>
                                    updatePlayerName(index, value),
                              ),
                            ),
                            if (playerNames.value.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,
                                onPressed: () => removePlayer(index),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: addPlayer,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Player'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: startGame,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Start Game',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

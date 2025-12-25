import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../models/mode.dart';
import '../providers/impostor_game_provider.dart';
import '../models/word_category.dart';
import '../models/turn_order.dart';

class ImpostorSetupWidget extends HookConsumerWidget {
  const ImpostorSetupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPhase = useState<int>(1);
    final selectedMode = useState<Mode?>(null);
    final selectedCategories = useState<Set<String>>({});
    final turnOrder = useState<TurnOrder>(TurnOrder.sequential);
    final maxGuessingPhases = useState<int>(2);
    final numberOfPlayers = useState<int>(3);
    final playerNames = useState<List<String>>(['']);
    final skipNaming = useState<bool>(false);

    void nextPhase() {
      if (currentPhase.value == 1) {
        if (selectedMode.value == null || selectedCategories.value.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please select a game mode and at least one category',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        currentPhase.value = 2;
      } else if (currentPhase.value == 2) {
        if (!skipNaming.value) {
          final validNames = playerNames.value
              .where((name) => name.trim().isNotEmpty)
              .toList();
          if (validNames.length != numberOfPlayers.value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please enter names for all ${numberOfPlayers.value} players',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        currentPhase.value = 3;
      }
    }

    void previousPhase() {
      if (currentPhase.value > 1) {
        currentPhase.value--;
      }
    }

    void startGame() {
      List<String> names;
      if (skipNaming.value) {
        names = List.generate(
          numberOfPlayers.value,
          (index) => 'Player ${index + 1}',
        );
      } else {
        names = playerNames.value
            .where((name) => name.trim().isNotEmpty)
            .map((name) => name.trim())
            .toList();
      }

      if (names.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need at least 3 players to start!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (selectedMode.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a game mode'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        ref
            .read(impostorGameProvider.notifier)
            .initializeGame(
              names,
              selectedMode.value!,
              turnOrder.value,
              maxGuessingPhases.value,
            );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }

    void updatePlayerName(int index, String name) {
      final updated = List<String>.from(playerNames.value);
      while (updated.length < numberOfPlayers.value) {
        updated.add('');
      }
      if (index < updated.length) {
        updated[index] = name;
        playerNames.value = updated;
      }
    }

    void toggleCategory(String categoryId) {
      final updated = Set<String>.from(selectedCategories.value);
      if (updated.contains(categoryId)) {
        updated.remove(categoryId);
      } else {
        updated.add(categoryId);
      }
      selectedCategories.value = updated;
    }

    return Container(
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
              // Phase indicator
              Row(
                children: [
                  _PhaseIndicator(
                    phase: 1,
                    currentPhase: currentPhase.value,
                    label: 'Mode & Categories',
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: currentPhase.value > 1
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  _PhaseIndicator(
                    phase: 2,
                    currentPhase: currentPhase.value,
                    label: 'Players',
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: currentPhase.value > 2
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  _PhaseIndicator(
                    phase: 3,
                    currentPhase: currentPhase.value,
                    label: 'Review',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _buildPhaseContent(
                  context,
                  currentPhase.value,
                  selectedMode,
                  selectedCategories,
                  turnOrder,
                  maxGuessingPhases,
                  numberOfPlayers,
                  playerNames,
                  skipNaming,
                  updatePlayerName,
                  toggleCategory,
                ),
              ),
              const SizedBox(height: 16),
              // Navigation buttons
              Row(
                children: [
                  if (currentPhase.value > 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: previousPhase,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (currentPhase.value > 1) const SizedBox(width: 16),
                  Expanded(
                    flex: currentPhase.value == 1 ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: currentPhase.value == 3
                          ? startGame
                          : nextPhase,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        currentPhase.value == 3 ? 'Start Game' : 'Next',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseContent(
    BuildContext context,
    int phase,
    ValueNotifier<Mode?> selectedMode,
    ValueNotifier<Set<String>> selectedCategories,
    ValueNotifier<TurnOrder> turnOrder,
    ValueNotifier<int> maxGuessingPhases,
    ValueNotifier<int> numberOfPlayers,
    ValueNotifier<List<String>> playerNames,
    ValueNotifier<bool> skipNaming,
    Function(int, String) updatePlayerName,
    Function(String) toggleCategory,
  ) {
    switch (phase) {
      case 1:
        return _buildPhase1(
          context,
          selectedMode,
          selectedCategories,
          turnOrder,
          maxGuessingPhases,
          toggleCategory,
        );
      case 2:
        return _buildPhase2(
          context,
          numberOfPlayers,
          playerNames,
          skipNaming,
          updatePlayerName,
        );
      case 3:
        return _buildPhase3(
          context,
          selectedMode,
          selectedCategories,
          turnOrder,
          maxGuessingPhases,
          numberOfPlayers,
          playerNames,
          skipNaming,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildPhase1(
    BuildContext context,
    ValueNotifier<Mode?> selectedMode,
    ValueNotifier<Set<String>> selectedCategories,
    ValueNotifier<TurnOrder> turnOrder,
    ValueNotifier<int> maxGuessingPhases,
    Function(String) toggleCategory,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select Game Mode',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Mode>(
            value: selectedMode.value,
            decoration: InputDecoration(
              labelText: 'Game Mode',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            items: [
              DropdownMenuItem(
                value: Mode.localMultiplayer,
                child: Text(Mode.localMultiplayer.displayName),
                enabled: false, // Disabled for now
              ),
              DropdownMenuItem(
                value: Mode.selfMultiplayer,
                child: Text(Mode.selfMultiplayer.displayName),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                selectedMode.value = value;
              }
            },
          ),
          if (selectedMode.value == Mode.selfMultiplayer) ...[
            const SizedBox(height: 8),
            Text(
              'Pass the device to the person next to you',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Turn Order',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TurnOrder>(
            value: turnOrder.value,
            decoration: InputDecoration(
              labelText: 'Turn Order',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            items: TurnOrder.values.map((order) {
              return DropdownMenuItem(
                value: order,
                child: Text(order.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                turnOrder.value = value;
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            turnOrder.value.description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Text(
            'Number of Guessing Phases',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: maxGuessingPhases.value,
            decoration: InputDecoration(
              labelText: 'Guessing Phases',
              helperText: 'Impostor wins if they survive all phases',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            items: List.generate(9, (index) => index + 2).map((count) {
              return DropdownMenuItem(
                value: count,
                child: Text('$count phases'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                maxGuessingPhases.value = value;
              }
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Select Word Categories',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...WordCategoryGroup.availableGroups.expand((group) {
            return [
              Text(
                group.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...group.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CheckboxListTile(
                    title: Text(category.name),
                    subtitle: Text('${category.words.length} words'),
                    value: selectedCategories.value.contains(category.id),
                    onChanged: (checked) {
                      toggleCategory(category.id);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tileColor: Theme.of(context).colorScheme.surface,
                  ),
                );
              }),
              const SizedBox(height: 16),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildPhase2(
    BuildContext context,
    ValueNotifier<int> numberOfPlayers,
    ValueNotifier<List<String>> playerNames,
    ValueNotifier<bool> skipNaming,
    Function(int, String) updatePlayerName,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Number of Players',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: numberOfPlayers.value,
            decoration: InputDecoration(
              labelText: 'Players',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            items: List.generate(10, (index) => index + 3).map((count) {
              return DropdownMenuItem(
                value: count,
                child: Text('$count players'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                numberOfPlayers.value = value;
                // Update player names list
                final currentNames = List<String>.from(playerNames.value);
                while (currentNames.length < value) {
                  currentNames.add('');
                }
                while (currentNames.length > value) {
                  currentNames.removeLast();
                }
                playerNames.value = currentNames;
              }
            },
          ),
          const SizedBox(height: 24),
          CheckboxListTile(
            title: const Text('Skip naming (use default names)'),
            value: skipNaming.value,
            onChanged: (value) {
              skipNaming.value = value ?? false;
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: Theme.of(context).colorScheme.surface,
          ),
          if (!skipNaming.value) ...[
            const SizedBox(height: 24),
            Text(
              'Player Names',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(numberOfPlayers.value, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Player ${index + 1}',
                    hintText: 'Enter name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onChanged: (value) => updatePlayerName(index, value),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildPhase3(
    BuildContext context,
    ValueNotifier<Mode?> selectedMode,
    ValueNotifier<Set<String>> selectedCategories,
    ValueNotifier<TurnOrder> turnOrder,
    ValueNotifier<int> maxGuessingPhases,
    ValueNotifier<int> numberOfPlayers,
    ValueNotifier<List<String>> playerNames,
    ValueNotifier<bool> skipNaming,
  ) {
    final categoryNames = WordCategoryGroup.availableGroups
        .expand((group) => group.categories)
        .where((cat) => selectedCategories.value.contains(cat.id))
        .map((cat) => cat.name)
        .toList();

    final names = skipNaming.value
        ? List.generate(numberOfPlayers.value, (index) => 'Player ${index + 1}')
        : playerNames.value.where((name) => name.trim().isNotEmpty).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Review Setup',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _ReviewSection(
            title: 'Game Mode',
            value: selectedMode.value?.displayName ?? 'Not selected',
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Turn Order',
            value: turnOrder.value.displayName,
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Guessing Phases',
            value: '${maxGuessingPhases.value}',
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Word Categories',
            value: categoryNames.isEmpty
                ? 'None selected'
                : categoryNames.join(', '),
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Number of Players',
            value: '${numberOfPlayers.value}',
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Players',
            value: names.isEmpty
                ? 'None'
                : names
                      .asMap()
                      .entries
                      .map((e) => '${e.key + 1}. ${e.value}')
                      .join('\n'),
            isMultiline: true,
          ),
        ],
      ),
    );
  }
}

class _PhaseIndicator extends StatelessWidget {
  final int phase;
  final int currentPhase;
  final String label;

  const _PhaseIndicator({
    required this.phase,
    required this.currentPhase,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = phase <= currentPhase;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              '$phase',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final String value;
  final bool isMultiline;

  const _ReviewSection({
    required this.title,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

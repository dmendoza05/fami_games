import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/game.dart';
import '../games/impostor/screens/impostor_game_screen.dart';
import '../theme/app_theme.dart';

class GameSelectionScreen extends HookConsumerWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
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
    }, []);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: AppTheme.gradientDecoration,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: Game.availableGames.length,
                      itemBuilder: (context, index) {
                        final game = Game.availableGames[index];
                        return _GameCard(
                          game: game,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const ImpostorGameScreen(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;

                                      var tween = Tween(
                                        begin: begin,
                                        end: end,
                                      ).chain(CurveTween(curve: curve));

                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                transitionDuration: const Duration(
                                  milliseconds: 300,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends HookWidget {
  final Game game;
  final VoidCallback onTap;

  const _GameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scaleController = useAnimationController(
      duration: const Duration(milliseconds: 150),
    );
    final scaleAnimation = useMemoized(
      () => Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: scaleController, curve: Curves.easeInOut),
      ),
      [scaleController],
    );

    return GestureDetector(
      onTapDown: (_) => scaleController.forward(),
      onTapUp: (_) {
        scaleController.reverse();
        onTap();
      },
      onTapCancel: () => scaleController.reverse(),
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          decoration: AppTheme.glassCardDecoration,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.glassIconBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Center(
                    child: Text(
                      game.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(game.name, style: AppTheme.titleLarge),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(game.description, style: AppTheme.bodyMedium),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

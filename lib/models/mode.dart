enum Mode { singleplayer, localMultiplayer, selfMultiplayer }

extension ModeExtension on Mode {
  String get displayName {
    switch (this) {
      case Mode.singleplayer:
        return 'Single Player';
      case Mode.localMultiplayer:
        return 'Local Multiplayer';
      case Mode.selfMultiplayer:
        return 'Self Multiplayer';
    }
  }
}

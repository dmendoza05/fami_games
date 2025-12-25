enum TurnOrder { sequential, randomized }

extension TurnOrderExtension on TurnOrder {
  String get displayName {
    switch (this) {
      case TurnOrder.sequential:
        return 'Sequential';
      case TurnOrder.randomized:
        return 'Randomized';
    }
  }

  String get description {
    switch (this) {
      case TurnOrder.sequential:
        return '1st player starts round 1, last player starts last round';
      case TurnOrder.randomized:
        return 'Random turn order each round';
    }
  }
}

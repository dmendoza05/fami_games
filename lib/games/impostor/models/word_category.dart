class WordCategory {
  final String id;
  final String name;
  final List<String> words;

  const WordCategory({
    required this.id,
    required this.name,
    required this.words,
  });
}

class WordCategoryGroup {
  final String id;
  final String name;
  final List<WordCategory> categories;

  const WordCategoryGroup({
    required this.id,
    required this.name,
    required this.categories,
  });

  static const List<WordCategoryGroup> availableGroups = [
    WordCategoryGroup(
      id: 'general',
      name: 'General',
      categories: [
        WordCategory(
          id: 'food',
          name: 'Food',
          words: [
            'Pizza',
            'Burger',
            'Sushi',
            'Taco',
            'Pasta',
            'Ice Cream',
            'Sandwich',
            'Salad',
          ],
        ),
        WordCategory(
          id: 'animals',
          name: 'Animals',
          words: [
            'Dog',
            'Cat',
            'Elephant',
            'Lion',
            'Dolphin',
            'Eagle',
            'Butterfly',
            'Shark',
          ],
        ),
        WordCategory(
          id: 'nature',
          name: 'Nature',
          words: [
            'Ocean',
            'Mountain',
            'Rainbow',
            'Volcano',
            'Forest',
            'Desert',
            'River',
            'Galaxy',
          ],
        ),
        WordCategory(
          id: 'objects',
          name: 'Objects',
          words: [
            'Guitar',
            'Telescope',
            'Castle',
            'Diamond',
            'Spaceship',
            'Treasure',
            'Thunder',
            'Phoenix',
          ],
        ),
      ],
    ),
  ];
}

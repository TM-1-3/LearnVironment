import 'package:flutter/material.dart';

class GamesPage extends StatefulWidget {
  @override
  GamesPageState createState() => GamesPageState();
}

class GamesPageState extends State<GamesPage> {
  String _searchQuery = "";
  String? _selectedTag; // Set as nullable
  String? _selectedAge; // Set as nullable

  // List of game data
  final List<Map<String, dynamic>> games = [
    {
      'imagePath': 'assets/placeholder.png',
      'gameTitle': 'Game Title 1',
      'tags': <String>['Age: 12+', 'Recycling', 'Citizenship'],
    },
    {
      'imagePath': 'assets/placeholder.png',
      'gameTitle': 'Game Title 2',
      'tags': <String>['Age: 8+', 'Recycling'],
    },
    {
      'imagePath': 'assets/placeholder.png',
      'gameTitle': 'Game Title 3',
      'tags': <String>['Age: 10+', 'Strategy', 'Citizenship'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter games based on search query, age, and tags
    final filteredGames = games.where((game) {
      final gameTitle = game['gameTitle'].toLowerCase();
      final tags = game['tags'] as List<String>; // Explicitly cast as List<String>

      final ageTag = tags.firstWhere(
            (tag) => tag.startsWith('Age:'),
        orElse: () => '',
      );

      final matchesQuery = _searchQuery.isEmpty || gameTitle.contains(_searchQuery.toLowerCase());
      final matchesTag = _selectedTag == null || tags.contains(_selectedTag);
      final matchesAge = _selectedAge == null || ageTag.contains(_selectedAge!);

      return matchesQuery && matchesTag && matchesAge;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (query) {
            setState(() {
              _searchQuery = query.toLowerCase();
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search games...',
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters for Age and Tags
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedAge,
                  hint: const Text('Filter by Age'),
                  items: ['12+', '8+', '10+']
                      .map((age) => DropdownMenuItem<String>(
                    value: age,
                    child: Text(age),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAge = value;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: _selectedTag,
                  hint: const Text('Filter by Tag'),
                  items: ['Recycling', 'Strategy', 'Citizenship']
                      .map((tag) => DropdownMenuItem<String>(
                    value: tag,
                    child: Text(tag),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTag = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Display filtered game cards
          Expanded(
            child: filteredGames.isNotEmpty
                ? ListView.builder(
              itemCount: filteredGames.length,
              itemBuilder: (context, index) {
                final game = filteredGames[index];
                return GameCard(
                  imagePath: game['imagePath'],
                  gameTitle: game['gameTitle'],
                  tags: List<String>.from(game['tags']),
                );
              },
            )
                : const Center(
              child: Text('No results found'),
            ),
          ),
        ],
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String imagePath;
  final String gameTitle;
  final List<String> tags;

  const GameCard({
    super.key,
    required this.imagePath,
    required this.gameTitle,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(
            imagePath
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(gameTitle),
                Row(
                  children: tags
                      .map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(label: Text(tag)),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

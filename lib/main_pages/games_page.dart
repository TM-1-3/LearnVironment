import 'package:flutter/material.dart';

class GamesPage extends StatefulWidget {
  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  String _searchQuery = "";
  String _selectedTag = "";
  String _selectedAge = "";

  // List of game data
  final List<Map<String, dynamic>> games = [
    {
      'imagePath': '/assets/placeholder',
      'gameTitle': 'Game Title 1',
      'tags': ['Age: 12+', 'Recycling', 'Citizenship'],
    },
    {
      'imagePath': '/assets/placeholder',
      'gameTitle': 'Game Title 2',
      'tags': ['Age: 8+', 'Recycling'],
    },
    {
      'imagePath': '/assets/placeholder',
      'gameTitle': 'Game Title 3',
      'tags': ['Age: 10+', 'Strategy', 'Citizenship'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter games based on search query, age, and tags
    final filteredGames = games.where((game) {
      final gameTitle = game['gameTitle'].toLowerCase();
      final tags = game['tags'];
      final ageTag = tags.firstWhere((tag) => tag.startsWith('Age:'), orElse: () => '');

      // Check if search query matches game title
      final matchesQuery = _searchQuery.isEmpty || gameTitle.contains(_searchQuery);

      // Check if selected tag matches any tag in the game
      final matchesTag = _selectedTag.isEmpty || tags.contains(_selectedTag);

      // Check if selected age matches the age tag
      final matchesAge = _selectedAge.isEmpty || ageTag.contains(_selectedAge);

      return matchesQuery && matchesTag && matchesAge;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (query) {
            setState(() {
              _searchQuery = query.toLowerCase(); // Convert query to lowercase
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
                      _selectedAge = value ?? "";
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
                      _selectedTag = value ?? "";
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
                  tags: game['tags'],
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
    Key? key,
    required this.imagePath,
    required this.gameTitle,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.network(
            imagePath,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
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

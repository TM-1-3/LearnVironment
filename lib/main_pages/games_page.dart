import 'package:flutter/material.dart';
import 'package:learnvironment/games_initial_screen.dart';
import 'package:learnvironment/game_data.dart';

class GamesPage extends StatefulWidget {
  @override
  GamesPageState createState() => GamesPageState();
}

class GamesPageState extends State<GamesPage> {
  String _searchQuery = "";
  String? _selectedTag;
  String? _selectedAge;

  // List of game data
  late final List<Map<String, dynamic>> games = [
    {
      'imagePath': 'assets/quizLogo.png',
      'gameTitle': 'EcoMind Challenge',
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

  Future<void> loadGame(String gameId) async {
    try {
      GameData quizData = await fetchGameData(gameId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamesInitialScreen(gameData: quizData),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar o jogo: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getFilteredGames() {
    return games.where((game) {
      final gameTitle = game['gameTitle'].toLowerCase();
      final tags = game['tags'] as List<String>;
      final ageTag = tags.firstWhere(
            (tag) => tag.startsWith('Age:'),
        orElse: () => '',
      );

      final matchesQuery = _searchQuery.isEmpty || gameTitle.contains(_searchQuery.toLowerCase());
      final matchesTag = _selectedTag == null || tags.contains(_selectedTag);
      final matchesAge = _selectedAge == null || ageTag.contains(_selectedAge!);

      return matchesQuery && matchesTag && matchesAge;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Filter games based on search query, age, and tags
    final filteredGames = getFilteredGames();

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
                  key: Key('ageDropdown'),
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
                  key: Key('tagDropdown'),
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
                  loadGame: index == 0 ? loadGame : null, // Only make the first card clickable
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
  final Future<void> Function(String gameId)? loadGame; // Nullable function

  const GameCard({
    super.key,
    required this.imagePath,
    required this.gameTitle,
    required this.tags,
    this.loadGame, // Nullable function
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: loadGame == null
                ? null // Do nothing if loadGame is null
                : () {
              loadGame!("w4VgUzduoH9A9KuN9R9R"); // Only call loadGame for the first card
            },
            child: Image.asset(imagePath), // This is the image that you tap
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

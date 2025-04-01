import 'package:flutter/material.dart';

class GamesPage extends StatefulWidget {
  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  String _searchQuery = "";

  // List of game data
  final List<Map<String, dynamic>> games = [
    {
      'imagePath': '/assets/placeholder',
      'gameTitle': 'Game Title 1',
      'tags': ['Age: 12+', 'Recycling'],
    },
    {
      'imagePath': '/assets/placeholder',
      'gameTitle': 'Game Title 2',
      'tags': ['Age: 8+', 'Recycling'],
    },
    {
      'imagePath': '/assets/placeholder',
      'gameTitle': 'Game Title 3',
      'tags': ['Age: 10+', 'Strategy'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter games based on search query
    final filteredGames = _searchQuery.isEmpty
        ? games
        : games.where((game) => game['gameTitle'].toLowerCase().contains(_searchQuery)).toList();

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
      body: filteredGames.isNotEmpty
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

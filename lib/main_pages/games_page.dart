import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/game_data.dart';

class GamesPage extends StatefulWidget {
  final FirebaseFirestore firestore;

  GamesPage({super.key, FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  GamesPageState createState() => GamesPageState();
}

class GamesPageState extends State<GamesPage> {
  String _searchQuery = "";
  String? _selectedTag;
  String? _selectedAge;
  List<Map<String, dynamic>> games = []; // List to hold the game data

  @override
  void initState() {
    super.initState();
    // Fetch the games data when the widget is first initialized
    _loadGames();
  }

  // Fetching the game data from Firestore
  Future<void> _loadGames() async {
    List<Map<String, dynamic>> fetchedGames = await getAllDocuments('games');
    setState(() {
      games = fetchedGames; // Update the games list with the fetched data
    });
  }

  // Update to use the firestore passed in the constructor
  Future<List<Map<String, dynamic>>> getAllDocuments(String collectionName) async {
    try {
      // Fetching the collection using the firestore instance passed to the widget
      QuerySnapshot querySnapshot = await widget.firestore.collection(collectionName).get();

      // Mapping Firestore documents to your desired map structure
      List<Map<String, dynamic>> documents = querySnapshot.docs.map((doc) {
        return {
          'imagePath': doc.get('logo') ?? 'assets/placeholder.png',  // Default value if the field doesn't exist
          'gameTitle': doc.get('name') ?? 'Default Game Title',  // Default value if the field doesn't exist
          'tags': List<String>.from(doc.get('tags') ?? []),  // Ensures 'tags' is a list of strings
          'gameId': doc.id,  // Store the Firestore document ID
        };
      }).toList();

      return documents;
    } catch (e) {
      // If an error occurs, print the error and return an empty list
      print('Error getting documents: $e');
      return [];
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

  Future<void> loadGame(String gameId) async {
    try {
      GameData quizData = await fetchGameData(gameId, firestore: widget.firestore);
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
                  items: ['12+', '10+', '8+', '6+']
                      .map((age) => DropdownMenuItem<String>(value: age, child: Text(age)))
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
                      .map((tag) => DropdownMenuItem<String>(value: tag, child: Text(tag)))
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
                  gameId: game['gameId'],
                  loadGame: loadGame,
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
  final String gameId;
  final Future<void> Function(String gameId) loadGame; // Nullable function

  const GameCard({
    super.key,
    required this.imagePath,
    required this.gameTitle,
    required this.tags,
    required this.gameId,
    required this.loadGame, // Nullable function
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap:  () => loadGame(gameId),
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

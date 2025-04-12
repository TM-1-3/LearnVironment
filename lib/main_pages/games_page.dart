import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/services/firestore_service.dart';

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
  List<Map<String, dynamic>> games = [];
  late FirestoreService firestoreService;

  @override
  void initState() {
    super.initState();
    firestoreService = FirestoreService(firestore: widget.firestore);
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    List<Map<String, dynamic>> fetchedGames = await firestoreService.getAllGames();
    setState(() {
      games = fetchedGames;
    });
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
      GameData gameData = await firestoreService.fetchGameData(gameId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamesInitialScreen(gameData: gameData),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Loading game: $e')),
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

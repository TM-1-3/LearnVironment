import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/services/firestore_service.dart';
import 'package:learnvironment/services/game_cache_service.dart';

class GamesPage extends StatefulWidget {
  final FirebaseAuth auth;
  final FirestoreService firestoreService;

  GamesPage({super.key, FirebaseAuth? auth, FirestoreService? firestoreService})
      : auth = auth ?? FirebaseAuth.instance,
        firestoreService = firestoreService ?? FirestoreService();

  @override
  GamesPageState createState() => GamesPageState();
}

class GamesPageState extends State<GamesPage> {
  String _searchQuery = "";
  String? _selectedTag;
  String? _selectedAge;
  List<Map<String, dynamic>> games = [];

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    final cacheService = GameCacheService();
    final cachedIds = await cacheService.getCachedGameIds();
    List<Map<String, dynamic>> loadedGames = [];
    // Try to load each cached game
    for (final id in cachedIds) {
      final cachedGame = await cacheService.getCachedGameData(id);
      if (cachedGame != null) {
        loadedGames.add({
          'imagePath': cachedGame.gameLogo,
          'gameTitle': cachedGame.gameName,
          'tags': cachedGame.tags,
          'gameId': cachedGame.documentName,
        });
      }
    }
    // Show cached games first (even if empty)
    setState(() {
      games = loadedGames;
    });

    // Fetch from Firestore in background to update list
    final fetchedGames = await widget.firestoreService.getAllGames();

    for (final game in fetchedGames) {
      final gameId = game['gameId'];
      final gameData = await widget.firestoreService.fetchGameData(gameId);
      await cacheService.cacheGameData(gameData);
    }

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
      final matchesAge = _selectedAge == null || ageTag == 'Age: ${_selectedAge!}';

      return matchesQuery && matchesTag && matchesAge;
    }).toList();
  }

  Future<void> loadGame(String gameId) async {
    final cacheService = GameCacheService();
    try {
      GameData? gameData = await cacheService.getCachedGameData(gameId);

      // If not cached, fetch and cache it
      if (gameData == null) {
        gameData = await widget.firestoreService.fetchGameData(gameId);
        await cacheService.cacheGameData(gameData);
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamesInitialScreen(
              gameData: gameData!,
              firebaseAuth: widget.auth,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredGames = getFilteredGames();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: Key('search'),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  key: Key('ageDropdown'),
                  value: _selectedAge,
                  hint: const Text('Filter by Age'),
                  items: [null, '12+', '10+', '8+', '6+']
                      .map((age) => DropdownMenuItem<String>(
                    value: age,
                    child: Text(age ?? 'All Ages'),
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
                  items: [null, 'Recycling', 'Strategy', 'Citizenship']
                      .map((tag) => DropdownMenuItem<String>(
                    value: tag,
                    child: Text(tag ?? 'All Tags'),
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
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                var mainAxisExtent = 600.0;
                if (constraints.maxWidth <= 600) {
                  mainAxisExtent = constraints.maxWidth - 40;
                } else if (constraints.maxWidth <= 1000) {
                  mainAxisExtent = 650;
                } else if (constraints.maxWidth <= 2000) {
                  mainAxisExtent = 1050;
                } else {
                  mainAxisExtent = 1500;
                }

                return filteredGames.isNotEmpty
                    ? GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    mainAxisExtent: mainAxisExtent, // Fixed height for items
                  ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

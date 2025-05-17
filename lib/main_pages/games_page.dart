import 'package:flutter/material.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/services/cache/game_cache_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

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
    try {
      final dataService = Provider.of<DataService>(context, listen: false);

      final fetchedGames = await dataService.getAllGames();
      print('[GamesPage] Fetched Games');
      setState(() {
        games = fetchedGames;
      });
    } catch (e) {
      print('[GamesPage] Error fetching games: $e');
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

      final matchesQuery =
          _searchQuery.isEmpty || gameTitle.contains(_searchQuery.toLowerCase());
      final matchesTag = _selectedTag == null || tags.contains(_selectedTag);
      final matchesAge = _selectedAge == null || ageTag == 'Age: ${_selectedAge!}';

      return matchesQuery && matchesTag && matchesAge;
    }).toList();
  }

  Future<void> loadGame(String gameId) async {
    try {
      print('[Games Page] Loading Game');
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final gameData = await dataService.getGameData(gameId: gameId);
      final userId = await authService.getUid();

      if (gameData != null && userId.isNotEmpty && mounted) {
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => GamesInitialScreen(gameData: gameData),
          ),
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game: $e')),
        );
      }
    }
  }

  Future<void> _refreshGames() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final gameCacheService = Provider.of<GameCacheService>(context, listen: false);
      await gameCacheService.clear();

      final fetchedGames = await dataService.getAllGames();
      print('[MyGamesPage] Refreshed My Games');
      setState(() {
        games = fetchedGames;
      });
    } catch (e) {
      print('[MyGamesPage] Error refreshing my games: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredGames = getFilteredGames();

    final screenWidth = MediaQuery.of(context).size.width;
    double mainAxisExtent = 500.0;
    if (screenWidth <= 500) {
      mainAxisExtent = screenWidth + 50;
    } else if (screenWidth <= 600) {
      mainAxisExtent = screenWidth;
    } else if (screenWidth <= 1000) {
      mainAxisExtent = 850;
    } else if (screenWidth <= 2000) {
      mainAxisExtent = 1050;
    } else {
      mainAxisExtent = 1600;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/auth_gate');
          },
        ),
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
            child: RefreshIndicator(
              onRefresh: _refreshGames,
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  filteredGames.isNotEmpty
                      ? GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      mainAxisExtent: mainAxisExtent,
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
                      : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const Center(child: Text('No results found')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

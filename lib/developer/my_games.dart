import 'package:flutter/material.dart';
import 'package:learnvironment/developer/widgets/my_game_card.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/services/cache/user_cache_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class MyGamesPage extends StatefulWidget {
  const MyGamesPage({super.key});

  @override
  MyGamesPageState createState() => MyGamesPageState();
}

class MyGamesPageState extends State<MyGamesPage> {
  String _searchQuery = "";
  String? _selectedTag;
  String? _selectedAge;
  List<Map<String, dynamic>> myGames = [];

  @override
  void initState() {
    super.initState();
    _fetchMyGames();
  }

  Future<void> _fetchMyGames() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final fetchedMyGames = await dataService.getMyGames(uid: await authService.getUid());
      print('[MyGamesPage] Fetched My Games');
      setState(() {
        myGames = fetchedMyGames;
      });
    } catch (e) {
      print('[MyGamesPage] Error fetching my games: $e');
    }
  }

  Future<void> _refreshMyGames() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final userCacheService = Provider.of<UserCacheService>(context, listen: false);
      await userCacheService.clearUserCache();

      final fetchedMyGames = await dataService.getMyGames(uid: await authService.getUid());
      print('[MyGamesPage] Refreshed My Games');
      setState(() {
        myGames = fetchedMyGames;
      });
    } catch (e) {
      print('[MyGamesPage] Error refreshing my games: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredMyGames() {
    return myGames.where((game) {
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
    try {
      print('[MyGames Page] Loading Game');
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final gameData = await dataService.getGameData(gameId: gameId);
      final userId = await authService.getUid();

      if (gameData != null && userId.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamesInitialScreen(gameData: gameData),
          ),
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredGames = getFilteredMyGames();

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
              onRefresh: _refreshMyGames,
              child: filteredGames.isNotEmpty
                  ? GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.32,
                ),
                itemCount: filteredGames.length,
                itemBuilder: (context, index) {
                  final game = filteredGames[index];
                  return MyGameCard(
                    imagePath: game['imagePath'],
                    gameTitle: game['gameTitle'],
                    tags: List<String>.from(game['tags']),
                    gameId: game['gameId'],
                    loadGame: loadGame,
                    isPublic: game['public'],
                  );
                },
              ) : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(child: Text('No results found')),
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

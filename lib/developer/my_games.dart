import 'package:flutter/material.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/user_cache_service.dart';
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
      print('[Games Page] Loading Game');
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
          SnackBar(content: Text('Error loading game: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = getFilteredMyGames();

    final screenWidth = MediaQuery.of(context).size.width;
    double mainAxisExtent = 500.0;
    if (screenWidth <= 600) {
      mainAxisExtent = screenWidth - 150;
    } else if (screenWidth <= 1000) {
      mainAxisExtent = 550;
    } else if (screenWidth <= 2000) {
      mainAxisExtent = 950;
    } else {
      mainAxisExtent = 1400;
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
              onRefresh: _refreshMyGames,
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  myGames.isNotEmpty
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
                    itemCount: filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final game = filteredSubjects[index];
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

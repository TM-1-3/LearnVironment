import 'package:flutter/material.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/teacher/widgets/game_card_teacher.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';


class GamesPageTeacher extends StatefulWidget {
  const GamesPageTeacher({super.key});

  @override
  GamesPageTeacherState createState() => GamesPageTeacherState();
}

class GamesPageTeacherState extends State<GamesPageTeacher> {
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

  @override
  Widget build(BuildContext context) {
    final filteredGames = getFilteredGames();

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                double mainAxisExtent = 600.0;
                if (constraints.maxWidth <= 600) {
                  mainAxisExtent = constraints.maxWidth+45;
                } else if (constraints.maxWidth <= 1000) {
                  mainAxisExtent = 695;
                } else if (constraints.maxWidth <= 2000) {
                  mainAxisExtent = 1095;
                } else {
                  mainAxisExtent = 1545;
                }

                return filteredGames.isNotEmpty
                    ? GridView.builder(
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
                    return GameCardTeacher(
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/services/firestore_service.dart';

class StudentStatsPage extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const StudentStatsPage({
    super.key,
    this.auth,
    this.firestore,
  });

  @override
  StudentStatsPageState createState() => StudentStatsPageState();
}

class StudentStatsPageState extends State<StudentStatsPage> {
  late final FirestoreService firestoreService;
  List<Map<String, dynamic>> games = []; // Declare the games list

  @override
  void initState() {
    super.initState();
    final firestore = widget.firestore ?? FirebaseFirestore.instance;

    firestoreService = FirestoreService(firestore: firestore);
    loadGames();
  }

  Future<void> loadGames() async {
    try {
      final gamesList = await firestoreService.getPlayedGames(widget.auth!.currentUser!.uid);
      if (mounted) {
        setState(() {
          games = gamesList;
        });
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading games: $e')),
          );
        });
      }
    }
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
          SnackBar(content: Text('Error loading game: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Recommended Games',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: games.isNotEmpty
                  ? ListView.builder(
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
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
                child: Text('No games have been played yet!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

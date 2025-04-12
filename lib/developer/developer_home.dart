import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learnvironment/developer/my_games.dart';
import 'package:learnvironment/developer/new_game.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:learnvironment/main_pages/profile_screen.dart';

class DeveloperHomePage extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  DeveloperHomePage({super.key, FirebaseFirestore? firestore, FirebaseAuth? auth})
      : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  @override
  State<DeveloperHomePage> createState() => _DeveloperHomePage();
}

enum TabItem { statistics, home, games }

class _DeveloperHomePage extends State<DeveloperHomePage> {
  TabItem selectedTab = TabItem.home;

  // Map of tabs to corresponding pages
  final Map<TabItem, Widget> _pages = {};

  @override
  void initState() {
    super.initState();

    // Initialize the _pages map with the passed firestore and auth
    _pages[TabItem.statistics] = NewGamePage();
    _pages[TabItem.home] = MyGamesPage();
    _pages[TabItem.games] = GamesPage(firestore: widget.firestore);
  }

  // Method to handle bottom navigation tap
  void _onItemTapped(int index) {
    setState(() {
      selectedTab = TabItem.values[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LearnVironment'),
        actions: [
          // Profile button in AppBar
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(auth: widget.auth),
                ),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Wrap the page in Expanded to give it proper constraints
          Expanded(
            child: _pages[selectedTab]!, // Display the selected page
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: TabItem.values.indexOf(selectedTab),
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'New Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: 'Games',
          ),
        ],
      ),
    );
  }
}

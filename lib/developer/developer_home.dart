import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main_pages/profile_screen.dart';
import 'my_games.dart';
import '../main_pages/games_page.dart';
import 'new_game.dart';

class DeveloperHomePage extends StatefulWidget {
  final FirebaseFirestore firestore; // Declare the Firestore instance
  final FirebaseAuth auth; // Declare the FirebaseAuth instance

  // Constructor now takes firestore and auth as arguments, with defaults
  DeveloperHomePage({
    super.key,
    FirebaseFirestore? firestore, // Make firestore nullable
    FirebaseAuth? auth, // Make auth nullable
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  @override
  State<DeveloperHomePage> createState() => _DeveloperHomePage();
}

enum TabItem { statistics, home, games }

class _DeveloperHomePage extends State<DeveloperHomePage> {
  // Default to the Home tab
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
                  builder: (context) => ProfileScreen(),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../authentication/auth_service.dart';  // Import the AuthService for authentication handling
import '../main_pages/profile_screen.dart';  // Import your custom ProfileScreen
import '../bin.dart'; // Import the game Bin

import '../main_pages/main_page.dart';
import '../main_pages/games_page.dart';
import '../main_pages/statistics_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePage();
}

enum TabItem { statistics, home, games }

class _StudentHomePage extends State<StudentHomePage> {
  // Default to the Home tab
  TabItem selectedTab = TabItem.home;
  String message = '';

  // Map of tabs to corresponding pages
  final Map<TabItem, Widget> _pages = {
    TabItem.statistics: StatisticsPage(),
    TabItem.home: MainPage(),
    TabItem.games: GamesPage(),
  };

  // Method to handle bottom navigation tap
  void _onItemTapped(int index) {
    setState(() {
      selectedTab = TabItem.values[index];
    });
  }

  // Method to handle button press and show a message
  void _showMessage() {
    setState(() {
      message = 'Button Pressed!';
    });
  }

  // Method to log out
  void _logout() {
    // This would call your AuthService to log out
    // For now, just show a message
    setState(() {
      message = 'Logged Out';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(builder: (context, authService, _) {
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
                    builder: (context) => ProfileScreen(authService: authService),
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
              icon: Icon(Icons.pie_chart),
              label: 'Statistics',
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
    });
  }
}

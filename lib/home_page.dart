import 'package:flutter/material.dart';
import 'package:learnvironment/quiz.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';  // Import the AuthService for authentication handling
import 'profile_screen.dart';  // Import your custom ProfileScreen


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum TabItem { statistics, home, games }

class _HomePageState extends State<HomePage> {
  // Default to the Home tab
  TabItem selectedTab = TabItem.home;
  String message = '';

  // Map of tabs to corresponding pages
  final Map<TabItem, Widget> _pages = {
    TabItem.statistics: const Center(child: Text('Statistics Page')),
    TabItem.home: const Center(child: Text('Home Page')),
    TabItem.games: const Center(child: Text('Games Page')),
  };

  // Method to handle bottom navigation tap
  void _onItemTapped(int index) {
    TabItem tappedTab = TabItem.values[index];

    if (tappedTab == TabItem.games) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Quiz()),
      );
    } else {
      setState(() {
        selectedTab = tappedTab;
      });
    }
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
            _pages[selectedTab]!, // Display the selected page
            if (message.isNotEmpty) Text(message), // Show message if any
            ElevatedButton(
              onPressed: _showMessage,
              child: const Text('Show Message'),
            ),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
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

import 'package:flutter/material.dart';
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

  // Map of tabs to corresponding pages
  final Map<TabItem, Widget> _pages = {
    TabItem.statistics: const Center(child: Text('Statistics Page')),
    TabItem.home: const Center(child: Text('Home Page')),
    TabItem.games: const Center(child: Text('Games Page')),
  };

  // Method to handle bottom navigation tap
  void _onItemTapped(int index) {
    setState(() {
      selectedTab = TabItem.values[index];
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
        body: _pages[selectedTab]!, // Display the selected page
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

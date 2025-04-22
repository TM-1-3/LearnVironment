import 'package:flutter/material.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:learnvironment/main_pages/main_page.dart';
import 'package:learnvironment/main_pages/profile_screen.dart';
import 'package:learnvironment/main_pages/statistics_page.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePage();
}

enum TabItem { statistics, home, games }

class _TeacherHomePage extends State<TeacherHomePage> {
  // Default to the Home tab
  TabItem selectedTab = TabItem.home;

  // Map of tabs to corresponding pages
  final Map<TabItem, Widget> _pages = {};

  @override
  void initState() {
    super.initState();

    // Initialize the _pages map with the passed firestore and auth
    _pages[TabItem.statistics] = StatisticsPage();
    _pages[TabItem.home] = MainPage();
    _pages[TabItem.games] = const GamesPage();
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
          Expanded(
            child: _pages[selectedTab]!,
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
  }
}

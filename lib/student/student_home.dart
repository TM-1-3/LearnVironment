import 'package:flutter/material.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:learnvironment/student/student_main_page.dart';
import 'package:learnvironment/main_pages/profile_screen.dart';
import 'package:learnvironment/student/student_stats.dart';
import 'package:learnvironment/main_pages/notifications_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePage();
}

enum TabItem { statistics, home, games }

class _StudentHomePage extends State<StudentHomePage> {
  TabItem selectedTab = TabItem.home;
  String message = '';

  final Map<TabItem, Widget> _pages = {};

  @override
  void initState() {
    super.initState();

    _pages[TabItem.statistics] = StudentStatsPage();
    _pages[TabItem.home] = StudentMainPage();
    _pages[TabItem.games] = GamesPage();
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
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
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

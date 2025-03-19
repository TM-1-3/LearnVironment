import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 1;  // Default to the Home page

  // List of screens corresponding to each tab
  final List<Widget> _pages = [
    Center(child: Text('Statistics Page')),
    Center(child: Text('Home Page')),
    Center(child: Text('Games Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('LearnVironment'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<ProfileScreen>(
                      builder: (context) => ProfileScreen(
                        appBar: AppBar(title: const Text('User Profile')),
                        actions: [
                          SignedOutAction((context) {
                            Navigator.of(context).pop();
                          }),
                        ],
                        children: [
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.asset('flutterfire_300x.png'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
            automaticallyImplyLeading: false,
          ),
          body: _pages[selectedIndex], // Display the selected page
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
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
      },
    );
  }
}

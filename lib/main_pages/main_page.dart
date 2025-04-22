import 'package:flutter/material.dart';
import 'package:learnvironment/notifications_page.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Center(
            child: Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // Top-right circular card
          Positioned(
            top: 10,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()), // Navigate to HomePage
                );
              },
              child: Card(
                shape: CircleBorder(),
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '🔔', // or use 'Notifications' text if preferred
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

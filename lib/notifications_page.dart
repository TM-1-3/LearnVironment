import 'package:flutter/material.dart';
import 'package:learnvironment/student/student_home.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        leading: IconButton(  // Override the leading property
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StudentHomePage()),
            ); // Navigate to GamesPage
          },
        ),
      ),
      body: Stack(
        children: [
      // Main content
      Center(
      child: Text(
      'Notifications Page!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:learnvironment/services/firebase_messaging_service.dart';
import 'package:learnvironment/student/student_home.dart';

class NotificationsPage extends StatefulWidget {
  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentHomePage()),
            );
          },
        ),
      ),
      body: notificationMessages.isEmpty
          ? Center(
        child: Text(
          'No notifications yet!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: notificationMessages.length,
        itemBuilder: (context, index) {
          final message = notificationMessages[index];
          return ListTile(
            title: Text(message.notification?.title ?? 'No title'),
            subtitle: Text(message.notification?.body ?? 'No body'),
            trailing: Text(
              message.sentTime?.toLocal().toString().split('.')[0] ?? '',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Force rebuild on return to the screen
    setState(() {});
  }
}
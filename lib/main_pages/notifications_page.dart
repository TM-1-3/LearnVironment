import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/data/notification_storage.dart';
import 'package:learnvironment/student/student_home.dart';

class NotificationsPage extends StatefulWidget {
  final List<RemoteMessage> notifications;

  NotificationsPage({super.key, List<RemoteMessage>? notifications})
      : notifications = notifications ?? NotificationStorage.notificationMessages;

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  late List<RemoteMessage> notifications;

  @override
  void initState() {
    super.initState();
    notifications = widget.notifications;
  }

  Future<void> _refreshNotifications() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      notifications = NotificationStorage.notificationMessages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/auth_gate');
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications, // Triggered when user pulls down
        child: notifications.isEmpty
            ? Center(
          child: Text(
            'No notifications yet!',
            style: TextStyle(fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final message = notifications[index];
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
      ),
    );
  }
}

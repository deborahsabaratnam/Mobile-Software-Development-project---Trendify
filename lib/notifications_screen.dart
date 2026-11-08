import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 15),
            Text(
              "No notifications yet",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
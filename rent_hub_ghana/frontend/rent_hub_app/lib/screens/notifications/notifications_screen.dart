import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.token});
  final String token;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notifications')),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService(token: token).fetchNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Unable to load notifications.'));
        }
        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) {
          return const Center(child: Text('You are all caught up.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: notifications.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, index) {
            final item = notifications[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2A2143),
                child: Icon(
                  item['is_read'] == true
                      ? Icons.notifications_none
                      : Icons.notifications,
                  color: const Color(0xFFBDA8FF),
                ),
              ),
              title: Text(
                item['title'] as String? ?? 'Rent Hub update',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                item['message'] as String? ?? '',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          },
        );
      },
    ),
  );
}

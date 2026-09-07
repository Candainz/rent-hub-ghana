import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class InquiriesScreen extends StatelessWidget {
  const InquiriesScreen({super.key, required this.token});
  final String token;

  String _extractUsername(String message) {
    final match = RegExp(r"username is ([A-Za-z0-9_.-]+)", caseSensitive: false)
        .firstMatch(message);
    return match != null ? match.group(1)! : 'unknown_user';
  }

  String _extractPhone(String message) {
    final match = RegExp(r"phone number is ([^\.]*)", caseSensitive: false)
        .firstMatch(message);
    return match != null ? match.group(1)!.trim() : 'Not provided';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Inquiries')),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService(token: token).fetchInquiries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Unable to load inquiries.'));
        }
        final inquiries = snapshot.data ?? [];
        if (inquiries.isEmpty) {
          return const Center(child: Text('No inquiries yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: inquiries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final item = inquiries[index];
            final message = item['message'] as String? ?? 'New inquiry';
            final username = _extractUsername(message);
            final phone = _extractPhone(message);

            return Card(
              elevation: 0,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.chat_bubble_outline),
                ),
                title: Text('New inquiry from $username'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Phone: $phone'),
                    const SizedBox(height: 4),
                    Text(message),
                    const SizedBox(height: 4),
                    Text('Status: ${item['status'] ?? 'new'}'),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    ),
  );
}

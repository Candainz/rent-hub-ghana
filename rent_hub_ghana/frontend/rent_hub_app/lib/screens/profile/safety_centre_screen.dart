import 'package:flutter/material.dart';

class SafetyCentreScreen extends StatelessWidget {
  const SafetyCentreScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Safety centre')),
    body: ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Text(
          'Tips for a confident rental search',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 24),
        _SafetyTip(
          icon: Icons.verified_user,
          title: 'Verify listings',
          description:
              'Look for verified badges on listings. Contact landlords directly through the app to confirm details.',
        ),
        const SizedBox(height: 18),
        _SafetyTip(
          icon: Icons.visibility,
          title: 'View in person',
          description:
              'Always visit the property before making any payment. Meet the landlord or agent in person.',
        ),
        const SizedBox(height: 18),
        _SafetyTip(
          icon: Icons.description,
          title: 'Review agreements carefully',
          description:
              'Read all rental agreements thoroughly. Understand terms, conditions, and payment schedules.',
        ),
        const SizedBox(height: 18),
        _SafetyTip(
          icon: Icons.money,
          title: 'Secure payment methods',
          description:
              'Never send cash directly. Use bank transfers or formal payment methods with documentation.',
        ),
        const SizedBox(height: 18),
        _SafetyTip(
          icon: Icons.people,
          title: 'Ask for references',
          description:
              'Request references from previous tenants. Reach out to them to verify the landlord\'s reliability.',
        ),
        const SizedBox(height: 18),
        _SafetyTip(
          icon: Icons.document_scanner,
          title: 'Document everything',
          description:
              'Keep copies of all communications, agreements, and receipts. Maintain records for future reference.',
        ),
        const SizedBox(height: 18),
        _SafetyTip(
          icon: Icons.warning,
          title: 'Watch for red flags',
          description:
              'Be cautious of extremely low prices, pressure to pay quickly, or requests for cash deposits.',
        ),
        const SizedBox(height: 18),
        _SafetyTip(
          icon: Icons.support_agent,
          title: 'Contact support',
          description:
              'If something seems suspicious, contact our support team immediately for assistance.',
        ),
        const SizedBox(height: 30),
      ],
    ),
  );
}

class _SafetyTip extends StatelessWidget {
  const _SafetyTip({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1F2E),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFF2A2143),
          child: Icon(icon, color: const Color(0xFFBDA8FF)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

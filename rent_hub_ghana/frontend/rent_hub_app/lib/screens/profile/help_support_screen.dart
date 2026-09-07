import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Help & Support')),
    body: ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Text(
          'Frequently Asked Questions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 24),
        _FAQItem(
          question: 'How do I create an account?',
          answer:
              'Tap the Sign up button on the login screen. Enter your email, password, full name, and phone number. Select your role (Renter, Landlord, or Agent) and complete registration.',
        ),
        const SizedBox(height: 16),
        _FAQItem(
          question: 'How do I search for properties?',
          answer:
              'Use the search bar in the Explore tab to search by area, city, or landmark. Use the filter button to refine by price, bedrooms, and property type.',
        ),
        const SizedBox(height: 16),
        _FAQItem(
          question: 'How do I save a property?',
          answer:
              'Tap the bookmark icon on any property card or in the property details. Your saved properties appear in the Saved tab.',
        ),
        const SizedBox(height: 16),
        _FAQItem(
          question: 'How do I contact a landlord?',
          answer:
              'Open a property details page and tap "Contact agent". You can send an inquiry directly through the app.',
        ),
        const SizedBox(height: 16),
        _FAQItem(
          question: 'How do I list a property as a landlord?',
          answer:
              'Go to the Landlord Dashboard from the home screen. Tap "Add Property" and fill in details like location, price, bedrooms, and add photos.',
        ),
        const SizedBox(height: 16),
        _FAQItem(
          question: 'How do I manage my property listings?',
          answer:
              'In the Landlord Dashboard, view all your properties. Tap any property to edit details, upload images, or delete the listing.',
        ),
        const SizedBox(height: 16),
        _FAQItem(
          question: 'What does "Verified" mean?',
          answer:
              'A verified property has been checked and approved by our team. These listings are reliable and trustworthy.',
        ),
        const SizedBox(height: 16),
        _FAQItem(
          question: 'How do I reset my password?',
          answer:
              'On the login screen, tap "Forgot password?". Enter your email and follow the instructions sent to reset your password.',
        ),
        const SizedBox(height: 16),
        _FAQItem(
          question: 'How do notifications work?',
          answer:
              'Notifications alert you about new property listings, inquiry updates, and saved search alerts. Enable notifications in Settings.',
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2143),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.help_center,
                color: Color(0xFFBDA8FF),
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Still need help?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFBDA8FF),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Contact our support team at support@renthubghana.com or call +233 XXX XXX XXXX',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFBDA8FF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    ),
  );
}

class _FAQItem extends StatefulWidget {
  const _FAQItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1A1F2E),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white12),
    ),
    child: ExpansionTile(
      title: Text(
        widget.question,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      onExpansionChanged: (expanded) {
        setState(() => isExpanded = expanded);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            widget.answer,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

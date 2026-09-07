import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../auth/auth_choice_screen.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});
  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String role = 'renter';

  void continueToApp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AuthChoiceScreen(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 44, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/logo.svg',
                width: 56,
                height: 56,
              ),
              const SizedBox(height: 90),
              Text(
                'Let’s find your place',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tell us how you’ll use Rent Hub Ghana so we can set up the right experience for you.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 34),
              _RoleCard(
                icon: Icons.search_rounded,
                title: 'I’m looking for a home',
                detail: 'Browse verified rentals and connect with agents.',
                selected: role == 'renter',
                onTap: () => setState(() => role = 'renter'),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.home_work_outlined,
                title: 'I have a property',
                detail: 'List homes, manage availability and inquiries.',
                selected: role != 'renter',
                onTap: () => setState(() => role = 'landlord'),
              ),
              if (role != 'renter') ...[
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'landlord', label: Text('Landlord')),
                    ButtonSegment(value: 'agent', label: Text('Agent')),
                  ],
                  selected: {role},
                  onSelectionChanged: (value) =>
                      setState(() => role = value.first),
                ),
              ],
              const SizedBox(height: 54),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: continueToApp,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String title, detail;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2A2143) : const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? const Color(0xFFBDA8FF) : const Color(0xFF352D4D),
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: selected
                ? const Color(0xFF7C4DFF)
                : const Color(0xFF2A2143),
            child: Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFFBDA8FF),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(color: Colors.white70, height: 1.3),
                ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: selected ? const Color(0xFFBDA8FF) : Colors.white38,
          ),
        ],
      ),
    ),
  );
}

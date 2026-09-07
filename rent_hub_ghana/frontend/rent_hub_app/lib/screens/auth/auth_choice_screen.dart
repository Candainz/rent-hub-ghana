import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Change role',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text('Account access'),
    ),
    body: Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2143),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  role == 'renter'
                      ? Icons.search_rounded
                      : Icons.home_work_outlined,
                  size: 16,
                  color: const Color(0xFFBDA8FF),
                ),
                const SizedBox(width: 6),
                Text(
                  role == 'renter'
                      ? 'Renter account'
                      : role == 'agent'
                      ? 'Agent account'
                      : 'Landlord account',
                  style: const TextStyle(
                    color: Color(0xFFBDA8FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Change role'),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome to Rent Hub',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            role == 'renter'
                ? 'Find a home you can trust, save your favourites and speak directly with agents.'
                : 'Publish your spaces, keep availability current and respond to interested renters.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen(role: role)),
              ),
              icon: const Icon(Icons.login),
              label: const Text('Log in securely'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterScreen(role: role)),
              ),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Create free account'),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Your account keeps your activity secure and in sync.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white60,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

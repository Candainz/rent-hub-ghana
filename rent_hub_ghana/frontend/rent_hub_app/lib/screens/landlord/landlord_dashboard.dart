import 'package:flutter/material.dart';
import '../../main.dart';
import 'add_property_screen.dart';
import 'my_properties_screen.dart';
import '../inquiries/inquiries_screen.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key, required this.role, this.token});
  final String role;
  final String? token;
  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int tab = 0;
  int _propertiesRefreshVersion = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      MyPropertiesScreen(
        key: ValueKey('my-properties-$_propertiesRefreshVersion'),
        role: widget.role,
        token: widget.token,
      ),
      widget.token == null
          ? const Center(child: Text('Sign in to view inquiries.'))
          : InquiriesScreen(token: widget.token!),
      ProfilePage(token: widget.token),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.role == 'agent' ? 'Agent workspace' : 'My properties',
        ),
      ),
      body: pages[tab],
      floatingActionButton: tab == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPropertyScreen(token: widget.token),
                  ),
                );
                if (added == true && mounted) {
                  setState(() {
                    _propertiesRefreshVersion += 1;
                  });
                }
              },
              icon: const Icon(Icons.add_home_work_outlined),
              label: const Text('Add property'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_work_outlined),
            selectedIcon: Icon(Icons.home_work),
            label: 'Properties',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Inquiries',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

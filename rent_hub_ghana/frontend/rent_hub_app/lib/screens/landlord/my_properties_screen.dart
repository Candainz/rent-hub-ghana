import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/api_service.dart';
import 'edit_property_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key, required this.role, this.token});
  final String role;
  final String? token;

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  List<Property> _listings = <Property>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void didUpdateWidget(covariant MyPropertiesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      _loadListings();
    }
  }

  Future<void> _loadListings() async {
    if (widget.token == null) {
      setState(() => _listings = <Property>[]);
      return;
    }

    setState(() => _loading = true);
    try {
      final listings = await ApiService(token: widget.token).fetchMyListings();
      if (mounted) {
        setState(() {
          _listings = listings;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      Text(
        'Your listings',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 8),
      const Text(
        'Keep availability and renter interest up to date.',
        style: TextStyle(color: Colors.white70),
      ),
      const SizedBox(height: 24),
      if (_loading)
        const Center(child: CircularProgressIndicator())
      else if (_listings.isEmpty)
        const Text(
          'No properties published yet.',
          style: TextStyle(color: Colors.white70),
        )
      else
        ..._listings.map(
          (property) => _ListingTile(
            title: property.title,
            location: property.area,
            price: property.price,
            available: property,
            token: widget.token,
            onDeleted: () {
              setState(() {
                _listings.removeWhere((listing) => listing.id == property.id);
              });
            },
            onAvailabilityChanged: (updatedProperty) {
              setState(() {
                final index = _listings.indexWhere(
                  (listing) => listing.id == updatedProperty.id,
                );
                if (index != -1) {
                  _listings[index] = updatedProperty;
                }
              });
            },
          ),
        ),
    ],
  );
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({
    required this.title,
    required this.location,
    required this.price,
    required this.available,
    this.token,
    required this.onDeleted,
    required this.onAvailabilityChanged,
  });
  final String title, location, price;
  final Property available;
  final String? token;
  final VoidCallback onDeleted;
  final ValueChanged<Property> onAvailabilityChanged;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    margin: const EdgeInsets.only(bottom: 14),
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2143),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.home_work_outlined, color: Color(0xFFBDA8FF)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Text(
        '$location\n$price / month',
        style: const TextStyle(color: Colors.white70),
      ),
      isThreeLine: true,
      trailing: PopupMenuButton<String>(
        onSelected: (action) async {
          if (action == 'edit') {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditPropertyScreen(property: available, token: token),
              ),
            );
            if (updated == true && context.mounted) {
              final state = context.findAncestorStateOfType<_MyPropertiesScreenState>();
              state?._loadListings();
            }
          } else if (action == 'toggle_availability' && available.id != null) {
            final toggled = !available.isAvailable;
            try {
              final updated = await ApiService(token: token).updateListing(
                available.id!,
                {'is_available': toggled},
              );
              onAvailabilityChanged(
                updated.copyWith(
                  isAvailable: toggled,
                  tag: toggled ? 'Available' : 'Unavailable',
                ),
              );
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unable to update availability.')),
                );
              }
            }
          } else if (action == 'delete' && available.id != null) {
            await ApiService(token: token).deleteListing(available.id!);
            onDeleted();
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit listing')),
          PopupMenuItem(
            value: 'toggle_availability',
            child: Text(available.isAvailable ? 'Mark unavailable' : 'Mark available'),
          ),
          const PopupMenuItem(value: 'delete', child: Text('Delete listing')),
        ],
      ),
    ),
  );
}

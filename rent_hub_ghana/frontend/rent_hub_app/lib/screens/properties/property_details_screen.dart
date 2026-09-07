import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'property_images_screen.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({
    super.key,
    required this.property,
    required this.isFavorite,
    required this.onFavorite,
    this.token,
  });
  final Property property;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final String? token;

  String? get effectiveToken => token ?? authService.token;

  String buildInquiryMessage() {
    final renter = authService.user;
    final renterUsername = (renter?.username ?? '').trim();
    final renterPhone = (renter?.phone ?? '').trim();
    final usernameText = renterUsername.isNotEmpty ? renterUsername : 'unknown_user';
    final phoneText = renterPhone.isNotEmpty ? renterPhone : 'Not provided';

    return 'Hello, my username is $usernameText and my phone number is $phoneText. I am interested in ${property.title}. Is it still available?';
  }

  Future<void> inquire(BuildContext context) async {
    final resolvedToken = effectiveToken;
    if (resolvedToken == null || authService.user == null || property.id == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to send an inquiry.')),
        );
      }
      return;
    }

    try {
      await ApiService(token: resolvedToken).sendInquiry(
        property.id!,
        buildInquiryMessage(),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inquiry sent to the agent.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send inquiry right now.')),
        );
      }
    }
  }

  Future<void> contact(BuildContext context) async {
    final ownerPhone = property.ownerPhone.trim();

    if (ownerPhone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No contact number available.')),
        );
      }
      return;
    }

    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Contact agent'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Call the agent or landlord using this number:'),
              const SizedBox(height: 12),
              SelectableText(
                ownerPhone,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                final uri = Uri(scheme: 'tel', path: ownerPhone);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Call now'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home details'),
        actions: [
          IconButton(
            onPressed: onFavorite,
            icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PropertyImagesScreen(property: property),
              ),
            ),
            child: Hero(
              tag: 'property-${property.id ?? property.title}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 1.35,
                  child: Image.network(
                    property.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFDCE9E3),
                      child: const Icon(
                        Icons.home_work_outlined,
                        size: 56,
                        color: Color(0xFF5B3FD6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _Tag(property.tag),
          const SizedBox(height: 14),
          Text(
            property.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(property.area, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 22),
          Text(
            property.price,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF5B3FD6),
            ),
          ),
          const Text('per month', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(Icons.bed_outlined, '${property.beds} Beds'),
              _Stat(Icons.bathtub_outlined, '${property.baths} Baths'),
              _Stat(
                Icons.chair_outlined,
                property.furnished ? 'Furnished' : 'Unfurnished',
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'About this home',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'A thoughtfully designed space in a well-connected neighbourhood. Enjoy bright rooms, quality finishes and the peace of a home that feels just right.',
            style: TextStyle(height: 1.5, color: Colors.black54),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => contact(context),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Contact agent'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => inquire(context),
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Inquire'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFEDE7FF),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF5B3FD6),
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: const Color(0xFF5B3FD6)),
      const SizedBox(height: 6),
      Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

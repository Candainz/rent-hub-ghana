import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key, this.token});
  final String? token;
  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController(),
      area = TextEditingController(),
      city = TextEditingController(),
      price = TextEditingController(),
      description = TextEditingController(),
      image = TextEditingController();
  String type = 'apartment';
  int bedrooms = 1;
  bool furnished = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add a property')),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            'Share your space',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Give renters the details they need to make a confident inquiry.',
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: title,
            validator: requiredValue,
            decoration: const InputDecoration(labelText: 'Property title'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: area,
                  validator: requiredValue,
                  decoration: const InputDecoration(labelText: 'Area'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: city,
                  validator: requiredValue,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: price,
            keyboardType: TextInputType.number,
            validator: requiredValue,
            decoration: const InputDecoration(
              labelText: 'Monthly rent (GH₵)',
              prefixText: 'GH₵ ',
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Property type'),
            items: const [
              DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
              DropdownMenuItem(value: 'house', child: Text('House')),
              DropdownMenuItem(value: 'studio', child: Text('Studio')),
              DropdownMenuItem(value: 'townhouse', child: Text('Townhouse')),
            ],
            onChanged: (value) => setState(() => type = value ?? 'apartment'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: bedrooms,
            decoration: const InputDecoration(labelText: 'Bedrooms'),
            items: [1, 2, 3, 4, 5]
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text('$value')),
                )
                .toList(),
            onChanged: (value) => setState(() => bedrooms = value ?? 1),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Furnished'),
            value: furnished,
            onChanged: (value) => setState(() => furnished = value),
          ),
          TextFormField(
            controller: image,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Photo URL (optional)',
              prefixIcon: Icon(Icons.image_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: description,
            maxLines: 4,
            validator: requiredValue,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: submit,
              icon: const Icon(Icons.publish),
              label: const Text('Publish property'),
            ),
          ),
        ],
      ),
    ),
  );

  String? requiredValue(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final data = {
      'title': title.text.trim(),
      'area': area.text.trim(),
      'city': city.text.trim(),
      'price': double.parse(price.text.replaceAll(RegExp(r'[^0-9.]'), '')),
      'property_type': type,
      'bedrooms': bedrooms,
      'bathrooms': 1,
      'furnished': furnished,
      'image_url': image.text.trim(),
      'description': description.text.trim(),
    };
    try {
      if (widget.token == null) {
        throw Exception('Sign in required');
      }
      await ApiService(token: widget.token).createListing(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property published successfully.')),
        );
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sign in as a landlord or agent to publish this property.',
            ),
          ),
        );
      }
    }
  }
}

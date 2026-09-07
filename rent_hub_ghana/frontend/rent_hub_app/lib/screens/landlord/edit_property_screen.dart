import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/api_service.dart';

class EditPropertyScreen extends StatefulWidget {
  const EditPropertyScreen({super.key, required this.property, this.token});
  final Property property;
  final String? token;
  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final formKey = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.property.title);
  late final area = TextEditingController(
    text: widget.property.area.split(',').first.trim(),
  );
  late final city = TextEditingController(
    text: widget.property.area.split(',').last.trim(),
  );
  late final price = TextEditingController(
    text: widget.property.price.replaceAll(RegExp(r'[^0-9.]'), ''),
  );
  late final description = TextEditingController(
    text: 'A thoughtfully designed home in a well-connected neighbourhood.',
  );
  late final image = TextEditingController(text: widget.property.image);
  late String type = widget.property.type.toLowerCase();
  late int bedrooms = widget.property.beds.clamp(1, 5);
  late bool furnished = widget.property.furnished;

  String? requiredValue(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Future<void> save() async {
    if (!formKey.currentState!.validate() ||
        widget.property.id == null ||
        widget.token == null) {
      return;
    }
    final data = <String, dynamic>{
      'title': title.text.trim(),
      'area': area.text.trim(),
      'city': city.text.trim(),
      'price': double.parse(price.text),
      'property_type': type,
      'bedrooms': bedrooms,
      'bathrooms': widget.property.baths,
      'furnished': furnished,
      'image_url': image.text.trim(),
      'description': description.text.trim(),
    };
    try {
      await ApiService(
        token: widget.token,
      ).updateListing(widget.property.id!, data);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Property updated.')));
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update property. Sign in and try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit property')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
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
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue:
                  ['apartment', 'house', 'studio', 'townhouse'].contains(type)
                  ? type
                  : 'apartment',
              decoration: const InputDecoration(labelText: 'Property type'),
              items: const [
                DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                DropdownMenuItem(value: 'house', child: Text('House')),
                DropdownMenuItem(value: 'studio', child: Text('Studio')),
                DropdownMenuItem(value: 'townhouse', child: Text('Townhouse')),
              ],
              onChanged: (value) => setState(() => type = value ?? 'apartment'),
            ),
            DropdownButtonFormField<int>(
              initialValue: bedrooms,
              decoration: const InputDecoration(labelText: 'Bedrooms'),
              items: [1, 2, 3, 4, 5]
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text('$value bedrooms'),
                    ),
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
              decoration: const InputDecoration(labelText: 'Photo URL'),
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
              child: FilledButton(
                onPressed: save,
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

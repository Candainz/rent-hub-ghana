import 'package:flutter/material.dart';
import '../../main.dart';

class PropertyImagesScreen extends StatelessWidget {
  const PropertyImagesScreen({super.key, required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: const Text('Property photos'),
    ),
    body: InteractiveViewer(
      minScale: 0.8,
      maxScale: 3,
      child: Center(
        child: Hero(
          tag: 'property-${property.id ?? property.title}',
          child: Image.network(
            property.image,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white54,
              size: 72,
            ),
          ),
        ),
      ),
    ),
  );
}

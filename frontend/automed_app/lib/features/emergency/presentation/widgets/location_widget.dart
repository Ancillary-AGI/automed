import 'package:flutter/material.dart';

// Minimal location widget stub
class LocationWidget extends StatelessWidget {
  final String? address;

  const LocationWidget({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on),
        const SizedBox(width: 8),
        Expanded(child: Text(address ?? 'Unknown location')),
      ],
    );
  }
}

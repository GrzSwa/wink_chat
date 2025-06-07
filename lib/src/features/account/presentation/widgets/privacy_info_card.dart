import 'package:flutter/material.dart';

class PrivacyInfoCard extends StatelessWidget {
  const PrivacyInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Twój pseudonim i płeć są widoczne dla innych. Twoje prawdziwe dane są chronione.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}

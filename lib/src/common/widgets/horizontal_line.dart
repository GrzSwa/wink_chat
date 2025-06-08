import 'package:flutter/material.dart';

class HorizontalLine extends StatelessWidget {
  final String text;
  const HorizontalLine({super.key, this.text = ""});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        const Expanded(child: Divider(color: Colors.black12)),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black26,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Expanded(child: Divider(color: Colors.black12)),
      ],
    );
  }
}

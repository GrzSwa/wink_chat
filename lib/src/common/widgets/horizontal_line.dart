import 'package:flutter/material.dart';

class HorizontalLine extends StatelessWidget {
  final String text;
  const HorizontalLine({Key? key, this.text = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Expanded(child: Divider(color: Colors.black12)),
        Text(
          text,
          style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w600),
        ),
        Expanded(child: Divider(color: Colors.black12)),
      ],
    );
  }
}

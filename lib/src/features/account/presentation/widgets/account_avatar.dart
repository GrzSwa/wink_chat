import 'package:flutter/material.dart';

class AccountAvatar extends StatelessWidget {
  final String pseudonym;

  const AccountAvatar({super.key, required this.pseudonym});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Theme.of(context).primaryColor,
      child: Text(
        pseudonym[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class UserChatsScreen extends StatelessWidget {
  const UserChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Twoje Czaty')),
      body: const Center(child: Text('Ekran Twoje Czaty')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wink_chat/src/features/explore/domain/models/explore_user.dart';
import 'package:wink_chat/src/features/explore/presentation/screens/chat_request_screen.dart';
import 'package:wink_chat/src/features/explore/data/repositories/chat_repository.dart';

class UserListTile extends StatelessWidget {
  final ExploreUser user;
  final ChatStatus status;
  final String lastSeenFormatted;

  const UserListTile({
    super.key,
    required this.user,
    required this.status,
    required this.lastSeenFormatted,
  });

  String _getStatusText(ChatStatus status) {
    switch (status) {
      case ChatStatus.none:
        return '';
      case ChatStatus.pending:
        return 'Wysłano prośbę o rozmowę.';
      case ChatStatus.active:
        return 'Rozmowa została zaakceptowana!';
      case ChatStatus.rejected:
        return 'Rozmowa została odrzucona!';
      case ChatStatus.ended:
        return 'Ta rozmowa została zakończona.';
    }
  }

  Color _getStatusColor(ChatStatus status) {
    switch (status) {
      case ChatStatus.none:
        return Colors.black;
      case ChatStatus.pending:
        return Colors.blue;
      case ChatStatus.active:
        return Colors.green;
      case ChatStatus.rejected:
        return Colors.red;
      case ChatStatus.ended:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(user.pseudonim[0].toUpperCase())),
      title: Text(user.pseudonim),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ostatnio aktywny: $lastSeenFormatted'),
          Text(
            _getStatusText(status),
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      trailing: Icon(
        user.gender == 'M' ? Icons.male : Icons.female,
        color: user.gender == 'M' ? Colors.blue : Colors.pink,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRequestScreen(user: user),
          ),
        );
      },
    );
  }
}

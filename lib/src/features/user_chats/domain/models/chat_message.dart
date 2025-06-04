import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String from;
  final String to;
  final String message;
  final DateTime time;

  ChatMessage({
    required this.id,
    required this.from,
    required this.to,
    required this.message,
    required this.time,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      from: data['from'] as String,
      to: data['to'] as String,
      message: data['message'] as String,
      time: (data['time'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'message': message,
      'time': Timestamp.fromDate(time),
    };
  }
}

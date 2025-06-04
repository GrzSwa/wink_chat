import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveChat {
  final String id;
  final String participantId;
  final String participantPseudonim;
  final String messageId;
  final String status;
  final String initiatorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? endedAt;

  ActiveChat({
    required this.id,
    required this.participantId,
    required this.participantPseudonim,
    required this.messageId,
    required this.status,
    required this.initiatorId,
    required this.createdAt,
    required this.updatedAt,
    this.endedAt,
  });

  factory ActiveChat.fromFirestore(
    String participantId,
    Map<String, dynamic> data,
    String participantPseudonim,
  ) {
    return ActiveChat(
      id: participantId,
      participantId: participantId,
      participantPseudonim: participantPseudonim,
      messageId: data['messageID'] as String,
      status: data['status'] as String,
      initiatorId: data['initiatorId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      endedAt:
          data['endedAt'] != null
              ? (data['endedAt'] as Timestamp).toDate()
              : null,
    );
  }
}

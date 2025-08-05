import 'package:chat_app/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required String id,
    required String content,
    required String senderId,
    required String conversationId,
    required String createdAt,
  }) : super(
    id: id,
    content: content,
    senderId: senderId,
    conversationId: conversationId,
    createdAt: createdAt,
  );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      senderId: json['sender_id'],
      conversationId: json['conversation_id'],
      createdAt: json['created_at'],
    );
  }
}
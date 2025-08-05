class MessageEntity {
  final String id;
  final String content;
  final String senderId;
  final String conversationId;
  final String createdAt;

  MessageEntity({
    required this.id,
    required this.content,
    required this.senderId,
    required this.conversationId,
    required this.createdAt,
  });
}
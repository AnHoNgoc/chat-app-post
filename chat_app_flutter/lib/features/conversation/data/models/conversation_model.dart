import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {


  ConversationModel({
    required String id,
    required String participantName,
    required String participantImage,
    required String lastMessage,
    required DateTime lastMessageTime,
  }) : super(
      id: id,
      participantName: participantName,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      participantImage:participantImage
  );

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['conversation_id'],
      participantName: json['participant_name'],
      participantImage: json['participant_image'] ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDk_071dbbz-bewOvpfYa3IlyImYtpvQmluw&s",
      lastMessage: json['last_message'] ?? 'No message',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.tryParse(json['last_message_time']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': id,
      'participant_name': participantName,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.toIso8601String(),
    };
  }
}
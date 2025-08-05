import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';

abstract class ConversationsRepository {
  Future<List<ConversationEntity>> fetchConversation({String? search});

  Future<String> checkOrCreateConversation({required String contactId});
}
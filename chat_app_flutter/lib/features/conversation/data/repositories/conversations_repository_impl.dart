

import 'package:chat_app/features/conversation/data/datasources/conversations_remote_data_source.dart';
import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';
import 'package:chat_app/features/conversation/domain/repositories/conversations_repository.dart';

class ConversationsRepositoryImpl implements ConversationsRepository {

  final  ConversationsRemoteDataSource conversationsRemoteDataSource;

  ConversationsRepositoryImpl({required this.conversationsRemoteDataSource});

  @override
  Future<List<ConversationEntity>> fetchConversation({String? search}) async {
    return await conversationsRemoteDataSource.fetchConversations(search: search);
  }

  @override
  Future<String> checkOrCreateConversation({required String contactId}) async {
    return await conversationsRemoteDataSource.checkOrCreateConversation(contactId: contactId);
  }
}
import 'package:chat_app/features/chat/data/datasources/message_remote_data_source.dart';
import 'package:chat_app/features/chat/domain/entities/daily_question_entity.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository{
  final MessageRemoteDataSource messageRemoteDataSource;
  MessageRepositoryImpl({required this.messageRemoteDataSource});

  @override
  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    return await messageRemoteDataSource.fetchMessage(conversationId);
  }

  @override
  Future<void> sendMessage(MessageEntity message) {
    throw UnimplementedError();
  }

  @override
  Future<DailyQuestionEntity> fetchDailyQuestion(String conversationId) async {
    return await messageRemoteDataSource.fetchDailyQuestion(conversationId);
  }

}
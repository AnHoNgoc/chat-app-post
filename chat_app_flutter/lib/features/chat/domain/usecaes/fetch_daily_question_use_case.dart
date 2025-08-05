import 'package:chat_app/features/chat/domain/entities/daily_question_entity.dart';

import '../repositories/message_repository.dart';

class FetchDailyQuestionUseCase {
  final MessageRepository messageRepository;

  FetchDailyQuestionUseCase({required this.messageRepository});

  Future<DailyQuestionEntity> call(String conversationId) async {
    return await messageRepository.fetchDailyQuestion(conversationId);
  }
}
import '../entities/conversation_entity.dart';
import '../repositories/conversations_repository.dart';

class FetchConversationsUseCase {
  final ConversationsRepository repository;

  FetchConversationsUseCase(this.repository);

  Future<List<ConversationEntity>> call({String? search}) {
    return repository.fetchConversation(search: search);
  }
}
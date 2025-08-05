import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';

abstract class ConversationsState {}

class ConversationsInitialState extends ConversationsState {}

class ConversationsLoadingState extends ConversationsState {}

class ConversationsLoadedState extends ConversationsState {
  final List<ConversationEntity> conversations;

  ConversationsLoadedState(this.conversations);
}

class ConversationsFailureState extends ConversationsState {
  final String message;

  ConversationsFailureState( this.message);
}
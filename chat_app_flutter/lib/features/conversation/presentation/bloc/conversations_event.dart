abstract class ConversationsEvent {}

class FetchConversationsEvent extends ConversationsEvent {
  final String? search;

  FetchConversationsEvent({this.search});
}




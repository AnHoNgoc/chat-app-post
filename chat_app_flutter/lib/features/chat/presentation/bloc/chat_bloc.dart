import 'package:chat_app/core/socket_service.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/usecaes/fetch_daily_question_use_case.dart';
import 'package:chat_app/features/chat/domain/usecaes/fetch_messages_use_case.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessagesUseCase fetchMessagesUseCase;
  final FetchDailyQuestionUseCase fetchDailyQuestionUseCase;
  final SocketService _socketService = SocketService();
  final List<MessageEntity> _message = [];
  final _storage = FlutterSecureStorage();

  ChatBloc({required this.fetchMessagesUseCase, required this.fetchDailyQuestionUseCase}):super(ChatLoadingState()){
    on<LoadMessageEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessages);
    on<ReceiveMessageEvent>(_onReceiveMessages);
    on<LoadDailyQuestionEvent>(_onLoadDailyQuestion);
  }

  Future<void> _onLoadMessages(LoadMessageEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoadingState());
    try {
      final messages = await fetchMessagesUseCase(event.conversationId);
      _message.clear();
      _message.addAll(messages);
      emit(ChatLoadedState(List.from(_message)));

      _socketService.socket.off("newMessage");

      _socketService.socket.emit("joinConversation", event.conversationId);
      _socketService.socket.on("newMessage" , (data){
        add(ReceiveMessageEvent(data));
      });
    } catch (error) {
      emit(ChatErrorState("Failed to load messages"));
    }
  }

  Future<void> _onSendMessages(SendMessageEvent event, Emitter<ChatState> emit) async {
      String userId = await _storage.read(key: "userId") ?? "";

      final newMessage = {
        "conversationId" : event.conversationId,
        "content": event.content,
        "senderId": userId
      };
      print(newMessage);
      
      _socketService.socket.emit("sendMessage", newMessage);
  }

  Future<void> _onReceiveMessages(ReceiveMessageEvent event, Emitter<ChatState> emit) async {

    final message = MessageEntity(
        id: event.message["id"],
        content: event.message["content"],
        senderId: event.message["sender_id"],
        conversationId: event.message["conversation_id"],
        createdAt: event.message["created_at"]
    );
    _message.add(message);
    print(_message);
    emit(ChatLoadedState(List.from(_message)));
  }

  Future<void> _onLoadDailyQuestion(LoadDailyQuestionEvent event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoadingState());
      final dailyQuestion = await fetchDailyQuestionUseCase(event.conversationId);
      emit(ChatDailyQuestionLoadedState(dailyQuestion));
    } catch (error) {
      // emit(ChatErrorState("Failed to load Daily question"));
      print("Failed to load Daily question");
    }
  }
}


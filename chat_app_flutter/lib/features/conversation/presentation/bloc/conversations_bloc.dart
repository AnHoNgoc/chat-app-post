import 'package:chat_app/core/socket_service.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_event.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/fetch_conversations_use_case.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final FetchConversationsUseCase fetchConversationsUseCase;
  final SocketService _socketService = SocketService();

  ConversationsBloc({required this.fetchConversationsUseCase}):super(ConversationsInitialState()){
    on<FetchConversationsEvent>(_onFetchConversations);

    _initializeSocketListeners();
  }

  void _initializeSocketListeners(){
    try {
      _socketService.socket.on("conversationUpdated", _onConversationUpdated);
    }catch (e) {
      print("Error initializing socket listeners:  $e");
    }
  }

  Future<void> _onFetchConversations(FetchConversationsEvent event, Emitter<ConversationsState> emit) async {
    emit(ConversationsLoadingState());

    try {
      final conversations = await fetchConversationsUseCase(search: event.search);
      emit(ConversationsLoadedState(conversations));
    } catch (error) {
      emit(ConversationsFailureState("Failed to load conversations"));
    }
  }


  void _onConversationUpdated (data) {
    add(FetchConversationsEvent());
  }


}

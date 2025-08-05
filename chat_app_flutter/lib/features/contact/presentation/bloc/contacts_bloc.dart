import 'package:chat_app/features/contact/domain/usecases/delete_contact_use_case.dart';
import 'package:chat_app/features/contact/domain/usecases/fetch_contacts_use_case.dart';
import 'package:chat_app/features/contact/presentation/bloc/contacts_event.dart';
import 'package:chat_app/features/contact/presentation/bloc/contacts_state.dart';
import 'package:chat_app/features/conversation/domain/usecases/check_or_create_conversation_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_contact_use_case.dart';
import '../../domain/usecases/fetch_recent_contacts_use_case.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final FetchContactsUseCase fetchContactsUseCase;
  final AddContactUseCase addContactUseCase;
  final CheckOrCreateConversationUseCase checkOrCreateConversationUseCase;
  final FetchRecentContactsUseCase fetchRecentContactsUseCase;
  final DeleteContactUseCase deleteContactUseCase;


  ContactsBloc({
    required this.fetchContactsUseCase,
    required this.addContactUseCase,
    required this.checkOrCreateConversationUseCase,
    required this.fetchRecentContactsUseCase,
    required this.deleteContactUseCase
  }):super(ContactsInitialState()){
    on<FetchContactsEvent>(_onFetchContacts);
    on<AddContactsEvent>(_onAddContacts);
    on<CheckOrCreateConversationEvent>(_onCheckOrCreateConversation);
    on<LoadRecentContactsEvent>(_onLoadRecentContacts);
    on<DeleteContactEvent>(_onDeleteContact);
    on<ClearRecentContactsEvent>(_onClearRecentContacts);
  }

  void _onClearRecentContacts(ClearRecentContactsEvent event, Emitter<ContactsState> emit) {
    emit(ContactsInitialState());
  }


  Future<void> _onFetchContacts(FetchContactsEvent event, Emitter<ContactsState> emit) async {
    emit(ContactsLoadingState());

    try {
      final contacts = await fetchContactsUseCase();
      emit(ContactsLoadedState(contacts));
    } catch (error) {
      emit(ContactsFailureState("Failed to load contacts"));
    }
  }

  Future<void> _onLoadRecentContacts(LoadRecentContactsEvent event, Emitter<ContactsState> emit) async {
    emit(ContactsLoadingState());

    try {
      final recentContacts = await fetchRecentContactsUseCase();
      emit(RecentContactsLoadedState(recentContacts));
    } catch (error) {
      emit(ContactsFailureState("Failed to load recent contacts"));
    }
  }

  Future<void> _onAddContacts(AddContactsEvent event, Emitter<ContactsState> emit) async {
    emit(ContactsLoadingState());

    try {
      await addContactUseCase(email: event.email);
      emit(ContactAdded());
      add(FetchContactsEvent());
    } catch (error) {
      emit(ContactsFailureState("Failed to add contact"));
    }
  }

  Future<void> _onDeleteContact(DeleteContactEvent event, Emitter<ContactsState> emit) async {
    emit(ContactsLoadingState()); // Hiện loading (nếu cần)

    try {
      await deleteContactUseCase(contactId: event.contactId);
      emit(ContactDeleted());
      add(FetchContactsEvent());
    } catch (error) {
      emit(ContactsFailureState("Failed to delete contact"));
    }
  }

  Future<void> _onCheckOrCreateConversation(CheckOrCreateConversationEvent event, Emitter<ContactsState> emit) async {
    emit(ContactsLoadingState());
    try {
      final conversationId = await checkOrCreateConversationUseCase(contactId: event.contactId);

      emit(ConversationReady(conversationId: conversationId, contact: event.contact));
    } catch (e) {
      print("Error in useCase: $e");
      emit(ContactsFailureState("Failed to check conversation"));
    }
  }

}
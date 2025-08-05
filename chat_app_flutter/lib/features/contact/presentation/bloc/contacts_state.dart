import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';

import '../../domain/entities/contact_entity.dart';

abstract class ContactsState {}

class ContactsInitialState extends ContactsState {}

class ContactsLoadingState extends ContactsState {}

class ContactsLoadedState extends ContactsState {
  final List<ContactEntity> contacts;

  ContactsLoadedState(this.contacts);
}

class ContactsFailureState extends ContactsState {
  final String message;

  ContactsFailureState(this.message);
}

class ContactAdded extends ContactsState{}

class ContactDeleted extends ContactsState {}

class ConversationReady extends ContactsState{
  final String conversationId;
  final ContactEntity  contact;

  ConversationReady({required this.conversationId, required this.contact});

}


class RecentContactsLoadedState extends ContactsState {
  final List<ContactEntity> recentContacts;

  RecentContactsLoadedState(this.recentContacts);
}

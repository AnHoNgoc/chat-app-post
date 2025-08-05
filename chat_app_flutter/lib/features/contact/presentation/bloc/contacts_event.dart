import 'package:chat_app/features/contact/domain/entities/contact_entity.dart';

abstract class ContactsEvent {}

class FetchContactsEvent extends ContactsEvent {}

class LoadRecentContactsEvent extends ContactsEvent {}

class CheckOrCreateConversationEvent extends ContactsEvent {
  final String contactId;
  final ContactEntity contact;

  CheckOrCreateConversationEvent(this.contactId, this.contact);
}

class AddContactsEvent extends ContactsEvent {
  final String email;
  AddContactsEvent(this.email);
}

class ClearRecentContactsEvent extends ContactsEvent {}

class DeleteContactEvent extends ContactsEvent {
  final String contactId;

  DeleteContactEvent(this.contactId);
}


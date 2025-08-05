import 'package:chat_app/features/contact/domain/entities/contact_entity.dart';

abstract class ContactsRepository {
  Future<List<ContactEntity>> fetchContacts ();
  Future <void> addContact ({required String email});
  Future <void> deleteContact ({required String contactId});
  Future<List<ContactEntity>> getRecentContacts ();
}
import 'package:chat_app/features/contact/data/datasources/contacts_remote_data_source.dart';
import 'package:chat_app/features/contact/domain/entities/contact_entity.dart';
import 'package:chat_app/features/contact/domain/repositories/contact_repository.dart';

class ContactsRepositoryImpl implements ContactsRepository {

  final ContactsRemoteDataSource contactsRemoteDataSource;

  ContactsRepositoryImpl({required this.contactsRemoteDataSource});

  @override
  Future<void> addContact({required String email})async {
    await contactsRemoteDataSource.addContact(email: email);
  }

  @override
  Future<void> deleteContact({required String contactId})async {
    await contactsRemoteDataSource.deleteContact(contactId: contactId);
  }

  @override
  Future<List<ContactEntity>> fetchContacts() async {
    return await contactsRemoteDataSource.fetchContacts();
  }

  @override
  Future<List<ContactEntity>> getRecentContacts() async {
    return await contactsRemoteDataSource.fetchRecentContacts();
  }
  
}
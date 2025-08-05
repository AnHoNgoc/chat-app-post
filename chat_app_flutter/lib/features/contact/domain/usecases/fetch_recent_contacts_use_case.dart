import '../entities/contact_entity.dart';
import '../repositories/contact_repository.dart';

class FetchRecentContactsUseCase {
  final ContactsRepository contactsRepository;

  FetchRecentContactsUseCase({required this.contactsRepository});

  Future<List<ContactEntity>> call() async {
    return await contactsRepository.getRecentContacts();
  }
}

import '../repositories/contact_repository.dart';

class DeleteContactUseCase {
  final ContactsRepository contactsRepository;

  DeleteContactUseCase({required this.contactsRepository});

  Future<void> call({required String contactId}) async {
    return await contactsRepository.deleteContact(contactId: contactId);
  }
}
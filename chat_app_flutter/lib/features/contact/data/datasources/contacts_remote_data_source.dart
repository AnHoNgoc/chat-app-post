import 'package:chat_app/features/contact/data/models/contact_model.dart';
import '../../../../core/dio_client.dart';
import '../../../../utils/app_constant.dart';

class ContactsRemoteDataSource {

  final String baseUrl = AppConstant.baseUrl;

  ContactsRemoteDataSource();

  Future<List<ContactModel>> fetchContacts() async {
    final dio = await DioClient.getDio();
    String url = "$baseUrl/contacts";

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => ContactModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch contacts");
      }
    } catch (e) {
      print("fetchContacts error: $e");
      throw Exception("Error");
    }
  }

  Future<void> addContact({required String email}) async {
    final dio = await DioClient.getDio();
    String url = "$baseUrl/contacts";

    try {
      final response = await dio.post(
        url,
        data: {
          "contactEmail": email,
        },
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add contact");
      }
    } catch (e) {
      print("addContact error: $e");
      throw Exception("Error");
    }
  }

  Future<void> deleteContact({required String contactId}) async {
    final dio = await DioClient.getDio();
    String url = "$baseUrl/contacts/$contactId";

    try {
      final response = await dio.delete(url);

      if (response.statusCode != 200) {
        throw Exception("Failed to delete contact");
      }
    } catch (e) {
      print("deleteContact error: $e");
      throw Exception("Error");
    }
  }

  Future<List<ContactModel>> fetchRecentContacts() async {
    final dio = await DioClient.getDio();
    String url = "$baseUrl/contacts/recent";

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data as List;
        print("Recent data $data");
        return data.map((json) => ContactModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch recent contacts");
      }
    } catch (e) {
      print("fetchRecentContacts error: $e");
      throw Exception("Error");
    }
  }
}
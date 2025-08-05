import 'package:chat_app/features/conversation/data/models/conversation_model.dart';
import '../../../../core/dio_client.dart';
import '../../../../utils/app_constant.dart';

class ConversationsRemoteDataSource {

   final String baseUrl = AppConstant.baseUrl;

   ConversationsRemoteDataSource();

   Future<List<ConversationModel>> fetchConversations({String? search}) async {
     String url = "$baseUrl/conversations";

     if (search != null && search.isNotEmpty) {
       url += "?search=${Uri.encodeComponent(search)}";
     }

     final dio = await DioClient.getDio();

     try {
       final response = await dio.get(url);

       if (response.statusCode == 200) {
         final data = response.data as List;
         return data.map((json) => ConversationModel.fromJson(json)).toList();
       } else {
         throw Exception("Failed to fetch conversations");
       }
     } catch (e) {
       print("fetchConversations error: $e");
       throw Exception("Error");
     }
   }

   Future<String> checkOrCreateConversation({required String contactId}) async {
     String url = "$baseUrl/conversations/check-or-create";
     final dio = await DioClient.getDio();

     try {
       final response = await dio.post(
         url,
         data: {
           "contactId": contactId,
         },
       );

       if (response.statusCode == 200) {
         final data = response.data;
         return data["conversationId"];
       } else {
         throw Exception("Failed to check or create conversation");
       }
     } catch (e) {
       print("checkOrCreateConversation error: $e");
       throw Exception("Error");
     }
   }
}
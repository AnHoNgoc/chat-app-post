

import 'package:chat_app/features/chat/data/models/daily_question_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import '../../../../core/dio_client.dart';
import '../../../../utils/app_constant.dart';

class MessageRemoteDataSource {
  final String baseUrl = AppConstant.baseUrl;

  MessageRemoteDataSource();

  Future<List<MessageModel>> fetchMessage(String conversationId) async {
    final dio = await DioClient.getDio();
    final url = "$baseUrl/messages/$conversationId";

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch message");
      }
    } catch (e) {
      print("fetchMessage error: $e");
      throw Exception("Error");
    }
  }

  Future<DailyQuestionModel> fetchDailyQuestion(String conversationId) async {
    final dio = await DioClient.getDio();
    final url = "$baseUrl/conversations/$conversationId/daily-question";

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        return DailyQuestionModel.fromJson(response.data);
      } else {
        throw Exception("Failed to fetch daily question");
      }
    } catch (e) {
      print("fetchDailyQuestion error: $e");
      throw Exception("Error");
    }
  }
}
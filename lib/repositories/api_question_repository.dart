import 'package:ophthal_vivaedge/models/question_model.dart';
import 'package:ophthal_vivaedge/repositories/question_repository.dart';
import 'package:ophthal_vivaedge/services/api_client.dart';

class ApiQuestionRepository implements QuestionRepository {
  final ApiClient _apiClient;

  ApiQuestionRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<QuestionModel>> getQuestions() async {
    final response = await _apiClient.get('/questions');
    final list = response as List? ?? [];
    return list.map((item) => QuestionModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<QuestionModel> getQuestionById(int id) async {
    final response = await _apiClient.get('/questions/$id');
    return QuestionModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<QuestionModel> createQuestion(QuestionModel question) async {
    final response = await _apiClient.post('/questions', body: question.toJson());
    return QuestionModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<QuestionModel> updateQuestion(int id, QuestionModel question) async {
    final response = await _apiClient.put('/questions/$id', body: question.toJson());
    return QuestionModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteQuestion(int id) async {
    await _apiClient.delete('/questions/$id');
  }
}

import 'package:ophthal_vivaedge/models/question_model.dart';

abstract class QuestionRepository {
  Future<List<QuestionModel>> getQuestions();
  Future<QuestionModel> getQuestionById(int id);
  Future<QuestionModel> createQuestion(QuestionModel question);
  Future<QuestionModel> updateQuestion(int id, QuestionModel question);
  Future<void> deleteQuestion(int id);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophthal_vivaedge/models/question_model.dart';
import 'package:ophthal_vivaedge/repositories/mock_question_repository.dart';

final adminQuestionsViewModelProvider = FutureProvider.autoDispose<List<QuestionModel>>((ref) async {
  final repo = MockQuestionRepository();
  return await repo.getQuestions();
});

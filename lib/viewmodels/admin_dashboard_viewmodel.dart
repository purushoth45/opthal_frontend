import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophthal_vivaedge/models/question_model.dart';
import 'package:ophthal_vivaedge/viewmodels/viva_viewmodel.dart';

final adminQuestionsViewModelProvider = FutureProvider.autoDispose<List<QuestionModel>>((ref) async {
  final repo = ref.watch(questionRepositoryProvider);
  return await repo.getQuestions();
});

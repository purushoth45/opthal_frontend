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
    final List<QuestionModel> questions = [];

    for (final item in list) {
      final qMap = item as Map<String, dynamic>;
      final id = qMap['id'] as int;

      try {
        final answersResponse = await _apiClient.get('/questions/$id/answers');
        qMap['answerBlocks'] = answersResponse;
      } catch (_) {}

      questions.add(QuestionModel.fromJson(qMap));
    }
    return questions;
  }

  @override
  Future<QuestionModel> getQuestionById(int id) async {
    final response = await _apiClient.get('/questions/$id');
    final qMap = response as Map<String, dynamic>;

    try {
      final answersResponse = await _apiClient.get('/questions/$id/answers');
      qMap['answerBlocks'] = answersResponse;
    } catch (_) {}

    return QuestionModel.fromJson(qMap);
  }

  @override
  Future<QuestionModel> createQuestion(QuestionModel question) async {
    // 1. Create the question metadata
    final qResponse = await _apiClient.post('/questions', body: {
      'questionText': question.questionText,
      'category': question.topic,
    });

    final createdQMap = qResponse as Map<String, dynamic>;
    final questionId = createdQMap['id'] as int;

    // 2. Sequentially add all answer blocks
    for (final block in question.answerBlocks) {
      if (block.type == AnswerBlockType.text || block.type == AnswerBlockType.heading) {
        final contentVal = block.type == AnswerBlockType.heading ? '## ${block.content ?? ""}' : block.content;
        await _apiClient.post(
          '/questions/$questionId/answers/text',
          body: {
            'content': contentVal,
            'displayOrder': block.displayOrder,
          },
        );
      } else if (block.type == AnswerBlockType.table) {
        await _apiClient.post(
          '/questions/$questionId/answers/table',
          body: {
            'displayOrder': block.displayOrder,
            'columns': block.columns ?? [],
            'rows': block.rows ?? [],
          },
        );
      }
    }

    return await getQuestionById(questionId);
  }

  @override
  Future<QuestionModel> updateQuestion(int id, QuestionModel question) async {
    // 1. Update the question metadata
    await _apiClient.put('/questions/$id', body: {
      'questionText': question.questionText,
      'category': question.topic,
    });

    // 2. Retrieve existing blocks to determine deletions vs additions vs updates
    final existingResponse = await _apiClient.get('/questions/$id/answers');
    final existingList = existingResponse as List? ?? [];
    final existingBlocks = existingList
        .map((item) => AnswerBlockModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final existingIds = existingBlocks.map((b) => b.id).whereType<int>().toSet();
    final incomingIds = question.answerBlocks.map((b) => b.id).whereType<int>().toSet();

    // Delete blocks no longer present in incoming list
    for (final existingBlock in existingBlocks) {
      final blockId = existingBlock.id;
      if (blockId != null && !incomingIds.contains(blockId)) {
        await _apiClient.delete('/questions/$id/answers/$blockId');
      }
    }

    // Create or update blocks
    for (final block in question.answerBlocks) {
      final blockId = block.id;
      if (blockId == null || blockId == 0 || !existingIds.contains(blockId)) {
        // Create block
        if (block.type == AnswerBlockType.text || block.type == AnswerBlockType.heading) {
          final contentVal = block.type == AnswerBlockType.heading ? '## ${block.content ?? ""}' : block.content;
          await _apiClient.post(
            '/questions/$id/answers/text',
            body: {
              'content': contentVal,
              'displayOrder': block.displayOrder,
            },
          );
        } else if (block.type == AnswerBlockType.table) {
          await _apiClient.post(
            '/questions/$id/answers/table',
            body: {
              'displayOrder': block.displayOrder,
              'columns': block.columns ?? [],
              'rows': block.rows ?? [],
            },
          );
        }
      } else {
        // Update block
        if (block.type == AnswerBlockType.text || block.type == AnswerBlockType.heading) {
          final contentVal = block.type == AnswerBlockType.heading ? '## ${block.content ?? ""}' : block.content;
          await _apiClient.put(
            '/questions/$id/answers/$blockId/text',
            body: {
              'content': contentVal,
              'displayOrder': block.displayOrder,
            },
          );
        } else if (block.type == AnswerBlockType.table) {
          await _apiClient.put(
            '/questions/$id/answers/$blockId/table',
            body: {
              'displayOrder': block.displayOrder,
              'columns': block.columns ?? [],
              'rows': block.rows ?? [],
            },
          );
        }
      }
    }

    return await getQuestionById(id);
  }

  @override
  Future<void> deleteQuestion(int id) async {
    await _apiClient.delete('/questions/$id');
  }
}

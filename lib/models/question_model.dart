import 'answer_block_model.dart';

class QuestionModel {
  final int id;
  final String questionText;
  final String topic;
  final List<AnswerBlockModel> answerBlocks;

  const QuestionModel({
    required this.id,
    required this.questionText,
    required this.topic,
    required this.answerBlocks,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    var rawBlocks = json['answerBlocks'] as List? ?? [];
    List<AnswerBlockModel> blocks = rawBlocks
        .map((blockJson) => AnswerBlockModel.fromJson(blockJson as Map<String, dynamic>))
        .toList();

    blocks.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return QuestionModel(
      id: json['id'] as int? ?? 0,
      questionText: json['questionText'] as String? ?? json['question'] as String? ?? '',
      topic: json['category'] as String? ?? json['topic'] as String? ?? 'General Ophthalmology',
      answerBlocks: blocks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'question': questionText,
      'category': topic,
      'topic': topic,
      'answerBlocks': answerBlocks.map((b) => b.toJson()).toList(),
    };
  }

  QuestionModel copyWith({
    int? id,
    String? questionText,
    String? topic,
    List<AnswerBlockModel>? answerBlocks,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      topic: topic ?? this.topic,
      answerBlocks: answerBlocks ?? this.answerBlocks,
    );
  }
}

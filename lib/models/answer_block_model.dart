import 'package:ophthal_vivaedge/core/enums/answer_block_type.dart';

class AnswerBlockModel {
  final int? id;
  final AnswerBlockType type;
  final String? content;
  final int displayOrder;
  final List<String>? columns;
  final List<List<String>>? rows;

  const AnswerBlockModel({
    this.id,
    required this.type,
    this.content,
    required this.displayOrder,
    this.columns,
    this.rows,
  });

  factory AnswerBlockModel.text({
    int? id,
    required String text,
    required int displayOrder,
  }) {
    return AnswerBlockModel(
      id: id,
      type: AnswerBlockType.text,
      content: text,
      displayOrder: displayOrder,
    );
  }

  factory AnswerBlockModel.heading({
    int? id,
    required String heading,
    required int displayOrder,
  }) {
    return AnswerBlockModel(
      id: id,
      type: AnswerBlockType.heading,
      content: heading,
      displayOrder: displayOrder,
    );
  }

  factory AnswerBlockModel.table({
    int? id,
    required List<String> columns,
    required List<List<String>> rows,
    required int displayOrder,
  }) {
    return AnswerBlockModel(
      id: id,
      type: AnswerBlockType.table,
      displayOrder: displayOrder,
      columns: columns,
      rows: rows,
    );
  }

  factory AnswerBlockModel.fromJson(Map<String, dynamic> json) {
    List<String>? parsedColumns;
    if (json['columns'] != null) {
      parsedColumns = List<String>.from(json['columns']);
    }

    List<List<String>>? parsedRows;
    if (json['rows'] != null) {
      parsedRows = (json['rows'] as List)
          .map((row) => List<String>.from(row))
          .toList();
    }

    return AnswerBlockModel(
      id: json['id'] as int?,
      type: AnswerBlockTypeX.fromString(json['type'] as String? ?? 'TEXT'),
      content: json['content'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 1,
      columns: parsedColumns,
      rows: parsedRows,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type.value,
      if (content != null) 'content': content,
      'displayOrder': displayOrder,
      if (columns != null) 'columns': columns,
      if (rows != null) 'rows': rows,
    };
  }

  AnswerBlockModel copyWith({
    int? id,
    AnswerBlockType? type,
    String? content,
    int? displayOrder,
    List<String>? columns,
    List<List<String>>? rows,
  }) {
    return AnswerBlockModel(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      displayOrder: displayOrder ?? this.displayOrder,
      columns: columns ?? (this.columns != null ? List<String>.from(this.columns!) : null),
      rows: rows ?? this.rows?.map((r) => List<String>.from(r)).toList(),
    );
  }
}

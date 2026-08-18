import 'dart:typed_data';
import 'package:ophthal_vivaedge/core/enums/answer_block_type.dart';

class AnswerBlockModel {
  final int? id;
  final AnswerBlockType type;
  final String? content;
  final int displayOrder;
  final List<String>? columns;
  final List<List<String>>? rows;
  final Uint8List? imageBytes;
  final String? localFileName;

  const AnswerBlockModel({
    this.id,
    required this.type,
    this.content,
    required this.displayOrder,
    this.columns,
    this.rows,
    this.imageBytes,
    this.localFileName,
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

  factory AnswerBlockModel.image({
    int? id,
    required String filename,
    required int displayOrder,
    Uint8List? imageBytes,
    String? localFileName,
  }) {
    return AnswerBlockModel(
      id: id,
      type: AnswerBlockType.image,
      content: filename,
      displayOrder: displayOrder,
      imageBytes: imageBytes,
      localFileName: localFileName,
    );
  }

  factory AnswerBlockModel.fromJson(Map<String, dynamic> json) {
    List<String>? parsedColumns;
    if (json['columns'] != null) {
      parsedColumns = List<String>.from(json['columns']);
    } else if (json['table'] != null && json['table']['columns'] != null) {
      parsedColumns = List<String>.from(json['table']['columns']);
    }

    List<List<String>>? parsedRows;
    if (json['rows'] != null) {
      parsedRows = (json['rows'] as List)
          .map((row) => List<String>.from(row))
          .toList();
    } else if (json['table'] != null && json['table']['rows'] != null) {
      parsedRows = (json['table']['rows'] as List)
          .map((row) => List<String>.from(row))
          .toList();
    }

    final rawType = json['type'] as String? ?? 'TEXT';
    final rawContent = json['content'] as String?;

    AnswerBlockType blockType = AnswerBlockTypeX.fromString(rawType);
    String? content = rawContent;

    // Decode markdown heading prefix if type is TEXT and content starts with "## "
    if (blockType == AnswerBlockType.text && content != null && content.startsWith('## ')) {
      blockType = AnswerBlockType.heading;
      content = content.substring(3);
    }

    return AnswerBlockModel(
      id: json['id'] as int?,
      type: blockType,
      content: content,
      displayOrder: json['displayOrder'] as int? ?? 1,
      columns: parsedColumns,
      rows: parsedRows,
    );
  }

  Map<String, dynamic> toJson() {
    final isHeading = type == AnswerBlockType.heading;
    return {
      if (id != null) 'id': id,
      'type': isHeading ? 'TEXT' : type.value,
      'content': isHeading ? '## ${content ?? ""}' : content,
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
    Uint8List? imageBytes,
    String? localFileName,
  }) {
    return AnswerBlockModel(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      displayOrder: displayOrder ?? this.displayOrder,
      columns: columns ?? (this.columns != null ? List<String>.from(this.columns!) : null),
      rows: rows ?? this.rows?.map((r) => List<String>.from(r)).toList(),
      imageBytes: imageBytes ?? this.imageBytes,
      localFileName: localFileName ?? this.localFileName,
    );
  }
}

enum AnswerBlockType {
  text,
  heading,
  table,
}

extension AnswerBlockTypeX on AnswerBlockType {
  String get value {
    switch (this) {
      case AnswerBlockType.text:
        return 'TEXT';
      case AnswerBlockType.heading:
        return 'HEADING';
      case AnswerBlockType.table:
        return 'TABLE';
    }
  }

  static AnswerBlockType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'HEADING':
        return AnswerBlockType.heading;
      case 'TABLE':
        return AnswerBlockType.table;
      case 'TEXT':
      default:
        return AnswerBlockType.text;
    }
  }
}

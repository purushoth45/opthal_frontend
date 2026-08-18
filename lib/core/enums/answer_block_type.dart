enum AnswerBlockType {
  text,
  heading,
  table,
  image,
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
      case AnswerBlockType.image:
        return 'IMAGE';
    }
  }

  static AnswerBlockType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'HEADING':
        return AnswerBlockType.heading;
      case 'TABLE':
        return AnswerBlockType.table;
      case 'IMAGE':
        return AnswerBlockType.image;
      case 'TEXT':
      default:
        return AnswerBlockType.text;
    }
  }
}

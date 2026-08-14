import 'package:flutter/material.dart';
import 'package:ophthal_vivaedge/core/enums/answer_block_type.dart';
import 'package:ophthal_vivaedge/models/answer_block_model.dart';
import 'package:ophthal_vivaedge/views/widgets/heading_block_widget.dart';
import 'package:ophthal_vivaedge/views/widgets/medical_answer_table.dart';
import 'package:ophthal_vivaedge/views/widgets/text_block_widget.dart';

class AnswerContentRenderer extends StatelessWidget {
  final List<AnswerBlockModel> blocks;

  const AnswerContentRenderer({
    super.key,
    required this.blocks,
  });

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No detailed answer content available.',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    final sortedBlocks = List<AnswerBlockModel>.from(blocks)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: sortedBlocks.map((block) {
        switch (block.type) {
          case AnswerBlockType.text:
            return TextBlockWidget(block: block);
          case AnswerBlockType.heading:
            return HeadingBlockWidget(block: block);
          case AnswerBlockType.table:
            return MedicalAnswerTable(block: block);
        }
      }).toList(),
    );
  }
}

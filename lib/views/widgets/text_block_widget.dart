import 'package:flutter/material.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/answer_block_model.dart';

class TextBlockWidget extends StatelessWidget {
  final AnswerBlockModel block;

  const TextBlockWidget({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final text = block.content ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SelectableText(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.9) : AppColors.textPrimary,
              height: 1.55,
              fontSize: 15,
            ),
      ),
    );
  }
}

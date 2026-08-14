import 'package:flutter/material.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/answer_block_model.dart';

class HeadingBlockWidget extends StatelessWidget {
  final AnswerBlockModel block;

  const HeadingBlockWidget({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final text = block.content ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.accentBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : AppColors.primaryNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

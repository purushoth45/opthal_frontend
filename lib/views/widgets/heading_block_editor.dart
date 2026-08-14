import 'package:flutter/material.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/answer_block_model.dart';

class HeadingBlockEditor extends StatelessWidget {
  final AnswerBlockModel block;
  final ValueChanged<AnswerBlockModel> onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const HeadingBlockEditor({
    super.key,
    required this.block,
    required this.onChanged,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'HEADING BLOCK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
                const Spacer(),
                if (onMoveUp != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                    onPressed: onMoveUp,
                    tooltip: 'Move Up',
                  ),
                if (onMoveDown != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                    onPressed: onMoveDown,
                    tooltip: 'Move Down',
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                  onPressed: onDelete,
                  tooltip: 'Delete Block',
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: block.content ?? '',
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: 'e.g. Fincham\'s Test or Differential Diagnosis',
                labelText: 'Section Heading Title',
              ),
              onChanged: (val) {
                onChanged(block.copyWith(content: val));
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final textCol = isDark ? Colors.white : AppColors.primaryNavy;
    final labelCol = isDark ? Colors.white70 : AppColors.primaryNavy;
    final hintCol = isDark ? Colors.white38 : AppColors.textMuted;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderCol, width: 1),
      ),
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
                    color: isDark ? const Color(0xFF1E3A5F) : AppColors.accentBlue.withOpacity(0.1),
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
                    icon: Icon(Icons.arrow_upward_rounded, size: 18, color: labelCol),
                    onPressed: onMoveUp,
                    tooltip: 'Move Up',
                  ),
                if (onMoveDown != null)
                  IconButton(
                    icon: Icon(Icons.arrow_downward_rounded, size: 18, color: labelCol),
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
              style: TextStyle(fontSize: 14, color: textCol, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: fieldBg,
                hintText: 'e.g. Fincham\'s Test or Differential Diagnosis',
                hintStyle: TextStyle(color: hintCol, fontSize: 13, fontWeight: FontWeight.normal),
                labelText: 'Section Heading Title',
                labelStyle: TextStyle(color: labelCol, fontSize: 13, fontWeight: FontWeight.w600),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderCol, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
                ),
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

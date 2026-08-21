import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/answer_block_model.dart';
import 'package:ophthal_vivaedge/views/widgets/image_block_widget.dart';

class ImageBlockEditor extends StatefulWidget {
  final AnswerBlockModel block;
  final ValueChanged<AnswerBlockModel> onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const ImageBlockEditor({
    super.key,
    required this.block,
    required this.onChanged,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  State<ImageBlockEditor> createState() => _ImageBlockEditorState();
}

class _ImageBlockEditorState extends State<ImageBlockEditor> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  Future<void> _pickImage(BuildContext context) async {
    setState(() => _isPicking = true);
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (file == null) {
        return; // User cancelled
      }

      final bytes = await file.readAsBytes();
      final length = bytes.length;

      if (length == 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a valid image.')),
          );
        }
        return;
      }

      if (length > 15 * 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File is too large. Maximum size is 15MB.')),
          );
        }
        return;
      }

      widget.onChanged(widget.block.copyWith(
        imageBytes: bytes,
        localFileName: file.name,
        content: file.name,
      ));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final textCol = isDark ? Colors.white : AppColors.primaryNavy;
    final labelCol = isDark ? Colors.white70 : AppColors.textSecondary;

    final hasImage = widget.block.imageBytes != null ||
        (widget.block.content != null && widget.block.content!.trim().isNotEmpty);

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
                    color: isDark ? const Color(0xFF4C1D95) : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'IMAGE BLOCK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFC084FC) : Colors.purple.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.block.localFileName != null)
                  Expanded(
                    child: Text(
                      widget.block.localFileName!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: labelCol),
                    ),
                  ),
                const Spacer(),
                if (widget.onMoveUp != null)
                  IconButton(
                    icon: Icon(Icons.arrow_upward_rounded, size: 18, color: textCol),
                    onPressed: widget.onMoveUp,
                    tooltip: 'Move Up',
                  ),
                if (widget.onMoveDown != null)
                  IconButton(
                    icon: Icon(Icons.arrow_downward_rounded, size: 18, color: textCol),
                    onPressed: widget.onMoveDown,
                    tooltip: 'Move Down',
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete Block',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Select Image Button
            OutlinedButton.icon(
              onPressed: _isPicking ? null : () => _pickImage(context),
              icon: _isPicking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_rounded, size: 18),
              label: Text(hasImage ? 'Change Image' : 'Select Image (JPG, PNG, WEBP)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? const Color(0xFF38BDF8) : AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                side: BorderSide(color: isDark ? const Color(0xFF38BDF8) : AppColors.primaryNavy),
              ),
            ),

            if (hasImage) ...[
              const SizedBox(height: 14),
              Text(
                'Image Preview:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: labelCol),
              ),
              const SizedBox(height: 6),
              ImageBlockWidget(block: widget.block),
            ],
          ],
        ),
      ),
    );
  }
}

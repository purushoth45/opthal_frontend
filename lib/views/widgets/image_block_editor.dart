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

      // Check file size (15MB limit)
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
    final hasImage = widget.block.imageBytes != null ||
        (widget.block.content != null && widget.block.content!.trim().isNotEmpty);

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
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'IMAGE BLOCK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.block.localFileName != null)
                  Expanded(
                    child: Text(
                      widget.block.localFileName!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                const Spacer(),
                if (widget.onMoveUp != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                    onPressed: widget.onMoveUp,
                    tooltip: 'Move Up',
                  ),
                if (widget.onMoveDown != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_downward_rounded, size: 18),
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
                foregroundColor: AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                side: const BorderSide(color: AppColors.primaryNavy),
              ),
            ),

            if (hasImage) ...[
              const SizedBox(height: 14),
              const Text(
                'Image Preview:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
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

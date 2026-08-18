import 'package:flutter/material.dart';
import 'package:ophthal_vivaedge/core/constants/api_config.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/answer_block_model.dart';
import 'package:ophthal_vivaedge/services/secure_storage_service.dart';

class ImageBlockWidget extends StatefulWidget {
  final AnswerBlockModel block;

  const ImageBlockWidget({
    super.key,
    required this.block,
  });

  @override
  State<ImageBlockWidget> createState() => _ImageBlockWidgetState();
}

class _ImageBlockWidgetState extends State<ImageBlockWidget> {
  final SecureStorageService _storageService = SecureStorageService();
  String? _token;
  bool _isLoadingToken = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    if (widget.block.imageBytes != null) {
      if (mounted) {
        setState(() {
          _isLoadingToken = false;
        });
      }
      return;
    }
    final token = await _storageService.getToken();
    if (mounted) {
      setState(() {
        _token = token;
        _isLoadingToken = false;
      });
    }
  }

  String get _imageUrl {
    final filename = widget.block.content ?? '';
    return '${ApiConfig.baseUrl}/questions/answers/images/$filename';
  }

  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: widget.block.imageBytes != null
                    ? Image.memory(
                        widget.block.imageBytes!,
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        _imageUrl,
                        headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image_rounded, size: 48, color: Colors.white70),
                              SizedBox(height: 8),
                              Text('Failed to load image', style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingToken && widget.block.imageBytes == null) {
      return Container(
        height: 180,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => _showFullScreenImage(context),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 380,
                    minHeight: 140,
                  ),
                  child: widget.block.imageBytes != null
                      ? Image.memory(
                          widget.block.imageBytes!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        )
                      : Image.network(
                          _imageUrl,
                          headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 200,
                              color: AppColors.background,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 160,
                            color: AppColors.background,
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary, size: 36),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Unable to load image: ${widget.block.content ?? ""}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xAA000000),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Tap to Zoom',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

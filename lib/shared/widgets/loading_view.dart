import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'app_shimmer.dart';

class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppShimmer(
              child: Column(
                children: [
                  ShimmerBox(width: 60, height: 60, borderRadius: 30),
                  SizedBox(height: 16),
                  ShimmerBox(width: 220, height: 18, borderRadius: 8),
                  SizedBox(height: 10),
                  ShimmerBox(width: 150, height: 14, borderRadius: 6),
                ],
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/answer_block_model.dart';
import 'package:ophthal_vivaedge/viewmodels/settings_viewmodel.dart';

class MedicalAnswerTable extends ConsumerWidget {
  final AnswerBlockModel block;

  const MedicalAnswerTable({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = block.columns ?? [];
    final rows = block.rows ?? [];

    if (columns.isEmpty || rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsViewModelProvider);
    final highContrast = settings.highContrastTables;

    final tableBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final headerBg = isDark
        ? (highContrast ? const Color(0xFF0F172A) : const Color(0xFF162032))
        : (highContrast ? const Color(0xFFE2E8F0) : AppColors.tableHeaderBg);

    final borderColor = isDark
        ? (highContrast ? const Color(0xFF94A3B8) : const Color(0xFF334155))
        : (highContrast ? const Color(0xFF475569) : AppColors.tableBorder);

    final borderWidth = highContrast ? 1.6 : 1.0;

    final headerTextColor = isDark
        ? (highContrast ? Colors.white : AppColors.accentBlue)
        : (highContrast ? const Color(0xFF0F172A) : AppColors.primaryNavy);

    final bodyTextColor = isDark
        ? Colors.white.withOpacity(0.95)
        : (highContrast ? Colors.black : AppColors.textPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: tableBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(highContrast ? 0.1 : 0.04),
              blurRadius: highContrast ? 10 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 64,
            ),
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(flex: 1.0),
              border: TableBorder(
                horizontalInside: BorderSide(color: borderColor, width: borderWidth),
                verticalInside: BorderSide(color: borderColor, width: borderWidth),
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: headerBg,
                  ),
                  children: columns.map((colText) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        colText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: headerTextColor,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                ...rows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final rowCells = entry.value;
                  final isEven = index % 2 == 0;
                  final rowBg = isEven
                      ? Colors.transparent
                      : (isDark
                          ? (highContrast ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.03))
                          : (highContrast ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC)));

                  return TableRow(
                    decoration: BoxDecoration(
                      color: rowBg,
                    ),
                    children: rowCells.map((cellText) {
                      return Container(
                        padding: const EdgeInsets.all(12.0),
                        constraints: const BoxConstraints(
                          minWidth: 140,
                          maxWidth: 260,
                        ),
                        child: SelectableText(
                          cellText,
                          style: TextStyle(
                            color: bodyTextColor,
                            fontSize: 13.5,
                            fontWeight: highContrast ? FontWeight.w500 : FontWeight.normal,
                            height: 1.45,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


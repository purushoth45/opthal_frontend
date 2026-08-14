import 'package:flutter/material.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/answer_block_model.dart';

class MedicalAnswerTable extends StatelessWidget {
  final AnswerBlockModel block;

  const MedicalAnswerTable({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final columns = block.columns ?? [];
    final rows = block.rows ?? [];

    if (columns.isEmpty || rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tableBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final headerBg = isDark ? const Color(0xFF0F172A) : AppColors.tableHeaderBg;
    final borderColor = isDark ? const Color(0xFF334155) : AppColors.tableBorder;
    final headerTextColor = isDark ? AppColors.accentBlue : AppColors.primaryNavy;
    final bodyTextColor = isDark ? Colors.white.withOpacity(0.9) : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: tableBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
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
                horizontalInside: BorderSide(color: borderColor, width: 1),
                verticalInside: BorderSide(color: borderColor, width: 1),
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
                ...rows.map((rowCells) {
                  return TableRow(
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

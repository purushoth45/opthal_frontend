import 'package:flutter/material.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/answer_block_model.dart';

class TableBlockEditor extends StatefulWidget {
  final AnswerBlockModel block;
  final ValueChanged<AnswerBlockModel> onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const TableBlockEditor({
    super.key,
    required this.block,
    required this.onChanged,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  State<TableBlockEditor> createState() => _TableBlockEditorState();
}

class _TableBlockEditorState extends State<TableBlockEditor> {
  late List<String> _columns;
  late List<List<String>> _rows;

  @override
  void initState() {
    super.initState();
    _columns = List<String>.from(widget.block.columns ?? ['Column 1', 'Column 2']);
    _rows = (widget.block.rows ?? [
      ['Cell 1', 'Cell 2']
    ]).map((r) => List<String>.from(r)).toList();
  }

  void _notifyParent() {
    widget.onChanged(
      widget.block.copyWith(
        columns: _columns,
        rows: _rows,
      ),
    );
  }

  void _addColumn() {
    setState(() {
      _columns.add('Column ${_columns.length + 1}');
      for (var row in _rows) {
        row.add('Cell Text');
      }
    });
    _notifyParent();
  }

  void _removeColumn(int index) {
    if (_columns.length <= 1) return;
    setState(() {
      _columns.removeAt(index);
      for (var row in _rows) {
        if (index < row.length) {
          row.removeAt(index);
        }
      }
    });
    _notifyParent();
  }

  void _addRow() {
    setState(() {
      _rows.add(List.generate(_columns.length, (i) => 'New cell content'));
    });
    _notifyParent();
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows.removeAt(index);
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final rowBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final textCol = isDark ? Colors.white : AppColors.primaryNavy;
    final labelCol = isDark ? Colors.white70 : AppColors.textSecondary;

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
                    color: isDark ? const Color(0xFF064E3B) : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TABLE BLOCK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.onMoveUp != null)
                  IconButton(
                    icon: Icon(Icons.arrow_upward_rounded, size: 18, color: textCol),
                    onPressed: widget.onMoveUp,
                  ),
                if (widget.onMoveDown != null)
                  IconButton(
                    icon: Icon(Icons.arrow_downward_rounded, size: 18, color: textCol),
                    onPressed: widget.onMoveDown,
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'Column Headers',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: labelCol),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_columns.length, (colIdx) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 160,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _columns[colIdx],
                              style: TextStyle(fontSize: 13, color: textCol, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: fieldBg,
                                labelText: 'Col ${colIdx + 1}',
                                labelStyle: TextStyle(color: labelCol, fontSize: 12),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: borderCol),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
                                ),
                              ),
                              onChanged: (val) {
                                _columns[colIdx] = val;
                                _notifyParent();
                              },
                            ),
                          ),
                          if (_columns.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 16, color: AppColors.error),
                              onPressed: () => _removeColumn(colIdx),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addColumn,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+ Add Column', style: TextStyle(fontSize: 12)),
              ),
            ),

            Divider(height: 24, color: borderCol),

            Text(
              'Table Rows & Cell Content',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: labelCol),
            ),
            const SizedBox(height: 8),

            ...List.generate(_rows.length, (rowIdx) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: rowBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Row ${rowIdx + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textCol),
                        ),
                        if (_rows.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            onPressed: () => _removeRow(rowIdx),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...List.generate(_columns.length, (colIdx) {
                      final cellValue = (colIdx < _rows[rowIdx].length) ? _rows[rowIdx][colIdx] : '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextFormField(
                          initialValue: cellValue,
                          maxLines: 2,
                          style: TextStyle(fontSize: 13, color: textCol),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: fieldBg,
                            labelText: '${_columns[colIdx]} Content',
                            labelStyle: TextStyle(color: labelCol, fontSize: 12),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: borderCol),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
                            ),
                          ),
                          onChanged: (val) {
                            if (colIdx < _rows[rowIdx].length) {
                              _rows[rowIdx][colIdx] = val;
                              _notifyParent();
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),

            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: _addRow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('+ Add Row', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                    color: AppColors.success.withOpacity(0.1),
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
                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                    onPressed: widget.onMoveUp,
                  ),
                if (widget.onMoveDown != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                    onPressed: widget.onMoveDown,
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Text(
              'Column Headers',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary),
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
                              decoration: InputDecoration(
                                labelText: 'Col ${colIdx + 1}',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

            const Divider(height: 24),

            const Text(
              'Table Rows & Cell Content',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),

            ...List.generate(_rows.length, (rowIdx) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Row ${rowIdx + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                          decoration: InputDecoration(
                            labelText: '${_columns[colIdx]} Content',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../widgets.dart';

class EditTaskSheet extends StatefulWidget {
  final TodoTask? task;
  final Function(TodoTask) onSave;

  const EditTaskSheet({super.key, this.task, required this.onSave});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  DateTime? _reminderDate;
  late TaskCategory _category;
  late bool _isUrgent;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _subtitleController = TextEditingController(text: widget.task?.subtitle ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
    _reminderDate = widget.task?.reminderDate;
    _category = widget.task?.category ?? TaskCategory.personal;
    _isUrgent = widget.task?.isUrgent ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_titleController.text.isNotEmpty) {
      final task = TodoTask(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        subtitle: _subtitleController.text.isNotEmpty 
            ? _subtitleController.text 
            : (_dueDate != null ? DateFormat('MMM dd, yyyy').format(_dueDate!) : 'NO DUE DATE'),
        description: _descriptionController.text,
        dueDate: _dueDate,
        reminderDate: _reminderDate,
        isUrgent: _isUrgent,
        category: _category,
        isDone: widget.task?.isDone ?? false,
        leftDeco: widget.task?.leftDeco,
      );
      widget.onSave(task);
      Navigator.pop(context);
    }
  }

  Future<void> _pickReminderTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A1F2B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1F2B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final baseDate = _dueDate ?? now;
      setState(() {
        _reminderDate = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    final isEditing = widget.task != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: darkColor, width: 4),
          left: BorderSide(color: darkColor, width: 4),
          right: BorderSide(color: darkColor, width: 4),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'EDIT TASK' : 'ADD NEW TASK',
                  style: GoogleFonts.epilogue(
                    fontWeight: FontWeight.w900,
                    color: darkColor,
                    letterSpacing: -0.5,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: darkColor, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildLabel('TITLE'),
            const SizedBox(height: 8),
            _buildTextField(_titleController, 'e.g. Finish Project Report'),
            
            const SizedBox(height: 16),
            _buildLabel('SUBTITLE'),
            const SizedBox(height: 8),
            _buildTextField(_subtitleController, 'e.g. Work • Urgent'),
            
            const SizedBox(height: 16),
            _buildLabel('DESCRIPTION'),
            const SizedBox(height: 8),
            _buildTextField(_descriptionController, 'Add more details...', maxLines: 3),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('DUE DATE'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: darkColor,
                                    onPrimary: Colors.white,
                                    onSurface: darkColor,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() => _dueDate = picked);
                          }
                        },
                        child: NeuBox(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: const Color(0xFFF3F4F6),
                          borderRadius: 0,
                          borderWidth: 2.5,
                          offset: const Offset(3, 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dueDate == null ? 'DATE' : DateFormat('MMM dd').format(_dueDate!),
                                style: GoogleFonts.epilogue(fontWeight: FontWeight.w700, color: darkColor, fontSize: 13),
                              ),
                              const Icon(Icons.calendar_today, size: 14, color: darkColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('REMINDER'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickReminderTime,
                        child: NeuBox(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: _reminderDate != null ? const Color(0xFFFFD19A) : const Color(0xFFF3F4F6),
                          borderRadius: 0,
                          borderWidth: 2.5,
                          offset: const Offset(3, 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _reminderDate == null ? 'OFF' : DateFormat('HH:mm').format(_reminderDate!),
                                style: GoogleFonts.epilogue(fontWeight: FontWeight.w700, color: darkColor, fontSize: 13),
                              ),
                              Icon(_reminderDate == null ? Icons.notifications_off_outlined : Icons.notifications_active, size: 14, color: darkColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildLabel('CATEGORY'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChoiceChip('WORK', TaskCategory.work),
                const SizedBox(width: 8),
                _buildChoiceChip('PERSONAL', TaskCategory.personal),
              ],
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _isUrgent,
                    onChanged: (value) => setState(() => _isUrgent = value ?? false),
                    activeColor: const Color(0xFFFF649C),
                    side: const BorderSide(color: darkColor, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                ),
                const SizedBox(width: 12),
                Text('MARK AS URGENT', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 12, color: darkColor)),
              ],
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: NeuBox(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF00FF7F),
                borderRadius: 0,
                borderWidth: 3,
                offset: const Offset(4, 4),
                child: InkWell(
                  onTap: _handleSave,
                  child: Center(
                    child: Text(
                      isEditing ? 'UPDATE TASK' : 'CONFIRM ADD',
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.w900,
                        color: darkColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.epilogue(
        fontWeight: FontWeight.w800,
        fontSize: 12,
        color: const Color(0xFF1A1F2B),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    const darkColor = Color(0xFF1A1F2B);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.epilogue(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.epilogue(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: const OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 2.5)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 2.5)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: darkColor, width: 3)),
      ),
    );
  }

  Widget _buildChoiceChip(String label, TaskCategory category) {
    const darkColor = Color(0xFF1A1F2B);
    final isSelected = _category == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _category = category);
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: GoogleFonts.epilogue(
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : darkColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: const BorderSide(color: darkColor, width: 2),
      ),
    );
  }
}

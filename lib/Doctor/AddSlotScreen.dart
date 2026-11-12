import 'package:flutter/material.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';

class AddSlotScreen extends StatefulWidget {
  final String doctorId;

  const AddSlotScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<AddSlotScreen> createState() => _AddSlotScreenState();
}

class _AddSlotScreenState extends State<AddSlotScreen> {
  static const Color bgColor = Color(0xFF252525);
  static const Color primaryBlue = Color(0xFF1E64B0);
  static const Color cardBg = Color(0xFF1E1E1E);
  static const Color successGreen = Color(0xFF00C48C);

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  final List<Map<String, String>> _slotsToAdd = [];

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: primaryBlue,
            surface: Color(0xFF1E1E1E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: primaryBlue,
            surface: Color(0xFF1E1E1E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _addToList() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both date and time'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    final dateStr = _formatDate(_selectedDate!);
    final timeStr = _formatTime(_selectedTime!);

    // Prevent duplicates
    final exists =
        _slotsToAdd.any((s) => s["date"] == dateStr && s["time"] == timeStr);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('This slot is already added'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() {
      _slotsToAdd.add({"date": dateStr, "time": timeStr});
    });
  }

  Future<void> _saveSlots() async {
    if (_slotsToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add at least one slot before saving'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      for (final slot in _slotsToAdd) {
        await ApiService.addDoctorSlot(
          doctorId: widget.doctorId,
          date: slot["date"]!,
          time: slot["time"]!,
        );
      }
      if (!mounted) return;
      // Return the last slot for the schedule screen to display
      Navigator.pop(context, _slotsToAdd.last);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: primaryBlue, size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('Add availability slots',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[800], height: 1),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Select date & time for each slot',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Date Picker Card
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: primaryBlue.withOpacity(0.5), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.calendar_month_rounded,
                                color: primaryBlue, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date',
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedDate != null
                                      ? _formatDate(_selectedDate!)
                                      : 'Tap to select date',
                                  style: TextStyle(
                                      color: _selectedDate != null
                                          ? Colors.white
                                          : Colors.white38,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: Colors.white38),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Time Picker Card
                  GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: successGreen.withOpacity(0.5), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: successGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.access_time_rounded,
                                color: successGreen, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Time',
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedTime != null
                                      ? _formatTime(_selectedTime!)
                                      : 'Tap to select time',
                                  style: TextStyle(
                                      color: _selectedTime != null
                                          ? Colors.white
                                          : Colors.white38,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: Colors.white38),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add to list button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _addToList,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryBlue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add, color: primaryBlue),
                      label: const Text('Add this slot',
                          style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Slots preview list
                  if (_slotsToAdd.isNotEmpty) ...[
                    const Text('Slots to be saved',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._slotsToAdd.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final slot = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: successGreen.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: successGreen, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${slot["date"]}  ·  ${slot["time"]}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _slotsToAdd.removeAt(idx)),
                              child: const Icon(Icons.close,
                                  color: Colors.white38, size: 18),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveSlots,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        disabledBackgroundColor: primaryBlue.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save slots',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

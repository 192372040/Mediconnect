import 'package:flutter/material.dart';
import '../Patientdashboard/services/api_service.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;
  const DoctorDetailsScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  Map<String, dynamic>? doctorData;
  List<dynamic> appointments = [];
  bool isLoading = true;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    fetchDoctorData();
  }

  Future<void> fetchDoctorData() async {
    try {
      final data = await ApiService.getDoctorProfile(widget.doctorId);
      setState(() {
        doctorData = data;
      });
      if (data != null && data['full_name'] != null) {
        final appts = await ApiService.getDoctorAppointments(data['full_name']);
        if (appts != null) {
          setState(() {
            appointments = appts;
          });
        }
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> get filteredAppointments {
    if (selectedFilter == 'All') {
      return appointments;
    } else if (selectedFilter == 'Today') {
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      return appointments.where((appt) => appt['appointment_date'] == todayStr).toList();
    } else if (selectedFilter == 'Upcoming') {
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      return appointments.where((appt) {
        final date = appt['appointment_date'] ?? '';
        final status = appt['booking_status'] ?? '';
        return (date.compareTo(todayStr) >= 0) && (status != 'Completed' && status != 'Cancelled' && status != 'Done');
      }).toList();
    } else if (selectedFilter == 'Done') {
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      return appointments.where((appt) {
        final date = appt['appointment_date'] ?? '';
        final status = appt['booking_status'] ?? '';
        return (date.compareTo(todayStr) < 0) || (status == 'Completed' || status == 'Cancelled' || status == 'Done');
      }).toList();
    }
    return appointments;
  }

  void _showEditDoctorDialog() {
    if (doctorData == null) return;

    final feeController = TextEditingController(text: (doctorData!['consultation_fee'] ?? '').toString());
    final startTimeController = TextEditingController(text: doctorData!['start_time'] ?? '09:00 AM');
    final endTimeController = TextEditingController(text: doctorData!['end_time'] ?? '05:00 PM');
    
    String selectedMode = doctorData!['consultation_mode'] ?? 'In-person';
    if (selectedMode.contains('Both') || (selectedMode.contains('In-person') && selectedMode.contains('Video'))) {
      selectedMode = 'Both';
    } else if (selectedMode.contains('Video')) {
      selectedMode = 'Video call';
    } else {
      selectedMode = 'In-person';
    }

    final List<String> allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final Map<String, String> dayAbbreviationMap = {
      'Mon': 'Monday',
      'Tue': 'Tuesday',
      'Wed': 'Wednesday',
      'Thu': 'Thursday',
      'Fri': 'Friday',
      'Sat': 'Saturday',
      'Sun': 'Sunday',
    };
    final List<String> currentDays = (doctorData!['working_days']?.toString() ?? '')
        .split(',')
        .map((d) => d.trim())
        .where((d) => d.isNotEmpty)
        .map((d) => dayAbbreviationMap[d] ?? d)
        .toList();
    final List<String> selectedDays = List<String>.from(currentDays);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Edit Doctor Details', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: feeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Consultation Fee (₹)',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startTimeController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                              hintText: 'e.g. 09:00 AM',
                              hintStyle: TextStyle(color: Colors.white24),
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: endTimeController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              hintText: 'e.g. 05:00 PM',
                              hintStyle: TextStyle(color: Colors.white24),
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Consultation Mode', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    DropdownButton<String>(
                      dropdownColor: const Color(0xFF1E1E1E),
                      value: selectedMode,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      items: <String>['In-person', 'Video call', 'Both'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          setDialogState(() {
                            selectedMode = newVal;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Working Days', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    ...allDays.map((day) {
                      final bool isSelected = selectedDays.contains(day);
                      return CheckboxListTile(
                        title: Text(day, style: const TextStyle(color: Colors.white)),
                        value: isSelected,
                        activeColor: const Color(0xFFC7781E),
                        checkColor: Colors.white,
                        onChanged: (bool? checked) {
                          setDialogState(() {
                            if (checked == true) {
                              if (!selectedDays.contains(day)) {
                                selectedDays.add(day);
                              }
                            } else {
                              selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final res = await ApiService.updateDoctorDetails(
                      doctorId: widget.doctorId,
                      consultationFee: feeController.text.trim(),
                      workingDays: selectedDays,
                      startTime: startTimeController.text.trim(),
                      endTime: endTimeController.text.trim(),
                      consultationMode: [selectedMode],
                    );
                    if (res['success'] == true) {
                      Navigator.pop(context);
                      fetchDoctorData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Doctor details updated successfully'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${res['error']}'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC7781E)),
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF252525);
    const Color primaryColor = Color(0xFFC7781E); // Orange
    const Color cardBgColor = Color(0xFF1E1E1E);
    const Color blueHeaderColor = Color(0xFF1B63A9);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (doctorData == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 18),
                        onPressed: () => Navigator.pop(context),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Doctor details not found',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final initials = doctorData!['full_name'] != null && doctorData!['full_name'].toString().isNotEmpty
        ? doctorData!['full_name'].toString().substring(0, 2).toUpperCase()
        : 'DOC';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 18),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Doctor details',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showEditDoctorDialog,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: const [
                          Icon(Icons.edit, color: primaryColor, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[800], height: 1),
            
            // Scrollable Content
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: blueHeaderColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctorData!['full_name'] ?? '',
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${doctorData!['specialization'] ?? 'General'} · ${doctorData!['hospital_name'] ?? ''}",
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  doctorData!['doctor_id'] ?? '',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildBadge('Active', Icons.circle, Colors.transparent),
                                    const SizedBox(width: 8),
                                    _buildBadge('4.9', Icons.star, const Color(0xFFFFC107)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats Row
                    Row(
                      children: [
                        _buildStatBox('${appointments.length}', 'Total patients', Colors.blue[400]!, cardBgColor),
                        const SizedBox(width: 12),
                        _buildStatBox('${appointments.where((a) => a['appointment_date'] == "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}").length}', 'Today', Colors.green[400]!, cardBgColor),
                        const SizedBox(width: 12),
                        _buildStatBox('${appointments.length}', 'Prescriptions', primaryColor, cardBgColor),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Personal Details Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        border: Border.all(color: Colors.grey[800]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text('Personal details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          _buildDetailRow('Full name', doctorData!['full_name'] ?? ''),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Age', doctorData!['age'] != null ? '${doctorData!['age']} years' : 'N/A'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Gender', doctorData!['gender'] ?? 'N/A'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Mobile', doctorData!['phone'] ?? 'N/A'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Email', doctorData!['email'] ?? 'N/A'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Professional Details Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        border: Border.all(color: Colors.grey[800]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text('Professional details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          _buildDetailRow('Qualification', doctorData!['qualification'] ?? 'N/A'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Specialization', doctorData!['specialization'] ?? 'N/A'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Experience', doctorData!['experience'] != null ? '${doctorData!['experience']} years' : 'N/A'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('License', doctorData!['license_number'] ?? 'N/A'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Department', doctorData!['department'] ?? 'N/A'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Working days', doctorData!['working_days'] ?? 'N/A'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Timing', (doctorData!['start_time'] != null && doctorData!['end_time'] != null) ? '${doctorData!['start_time']} - ${doctorData!['end_time']}' : 'N/A'),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Fee', doctorData!['consultation_fee'] != null ? '₹${doctorData!['consultation_fee']}' : 'N/A', valueColor: Colors.tealAccent[400]),
                          Divider(color: Colors.grey[800], height: 1),
                          _buildDetailRow('Mode', doctorData!['consultation_mode'] ?? 'N/A'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Doctor's appointments
                    const Text('Doctor\'s appointments', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    // Appointment Filters
                    Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Today'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Upcoming'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Done'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Appointment List
                    if (filteredAppointments.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No appointments found', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ...filteredAppointments.map((appt) {
                        final pName = appt['patient_name'] ?? 'Patient';
                        final pInitials = pName.toString().isNotEmpty ? pName.toString().substring(0, 2).toUpperCase() : 'PT';
                        final dateStr = appt['appointment_date'] ?? '';
                        final slotStr = appt['appointment_slot'] ?? '';
                        final reasonStr = appt['reason'] ?? '';
                        final statusStr = appt['booking_status'] ?? 'Scheduled';
                        
                        Color statusColor = primaryColor;
                        if (statusStr == 'Completed' || statusStr == 'Done') {
                          statusColor = Colors.green[600]!;
                        } else if (statusStr == 'Confirmed' || statusStr == 'Upcoming') {
                          statusColor = Colors.blue[600]!;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildAppointmentCard(
                            initials: pInitials,
                            name: pName,
                            details: "$dateStr · $slotStr · $reasonStr",
                            status: statusStr,
                            color: statusColor,
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: 24),

                    // Bottom Actions
                    GestureDetector(
                      onTap: _showEditDoctorDialog,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF332617), // Deep orange tint
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.edit, color: primaryColor, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Edit doctor details',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF331E1E), // Deep red tint
                          border: Border.all(color: Colors.red[400]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red[400], size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Remove from hospital',
                              style: TextStyle(
                                color: Colors.red[400],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData? icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && iconColor != Colors.transparent) ...[
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: color.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor ?? Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isActive = selectedFilter == label;
    const Color primaryColor = Color(0xFFC7781E);
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          border: Border.all(color: isActive ? primaryColor : Colors.grey[700]!),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[500],
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String initials,
    required String name,
    required String details,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.15),
            child: Text(
              initials,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_project/Doctor/AI.dart';
import 'package:my_project/Doctor/Schdule.dart';
import 'package:my_project/Doctor/records.dart';
import 'package:my_project/Doctor/Doctordashscreen.dart';
import 'package:my_project/Doctor/Patdetails.dart';
import 'package:my_project/Doctor/Prescriptions.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';

class MyPatientsScreen extends StatefulWidget {
  final String doctorId;

  const MyPatientsScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<MyPatientsScreen> createState() => _MyPatientsScreenState();
}

class _MyPatientsScreenState extends State<MyPatientsScreen> {
  static const Color bgColor = Color(0xFF252525);
  static const Color primaryBlue = Color(0xFF1E64B0);
  static const Color cardBgColor = Color(0xFF1E1E1E);

  List<dynamic> _appointments = [];
  List<dynamic> _filteredPatients = [];
  bool _loading = true;
  String? _doctorName;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() => _loading = true);
    final res = await ApiService.getDoctorSummary(widget.doctorId);
    _doctorName = res?["full_name"] ?? "";
    final appts = await ApiService.getDoctorAppointments(_doctorName!);
    final activeAppts =
        appts.where((a) => (a["booking_status"] ?? "") != "Cancelled").toList();

    setState(() {
      _appointments = activeAppts;
      _filteredPatients = activeAppts;
      _loading = false;
    });

  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _appointments.where((a) {
        final name = (a["patient_name"] ?? "").toString().toLowerCase();
        final email = (a["patient_email"] ?? "").toString().toLowerCase();
        return name.contains(q) || email.contains(q);
      }).toList();
    });
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
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 18),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('My patients',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: primaryBlue.withOpacity(0.6)),
                      borderRadius: BorderRadius.circular(12),
                      color: primaryBlue.withOpacity(0.1),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Text(
                      '${_appointments.length} total',
                      style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[800], height: 1),

            // Content
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryBlue))
                  : RefreshIndicator(
                      onRefresh: _loadPatients,
                      color: primaryBlue,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Search bar
                          TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: cardBgColor,
                              prefixIcon: const Icon(Icons.search,
                                  color: primaryBlue),
                              hintText: 'Search by name or email...',
                              hintStyle:
                                  TextStyle(color: Colors.grey[500]),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: primaryBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: primaryBlue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_filteredPatients.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Text('No patients found',
                                    style: TextStyle(color: Colors.white54)),
                              ),
                            )
                          else
                            ..._filteredPatients.map((a) =>
                                _buildPatientCard(context, a)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildPatientCard(BuildContext context, dynamic a) {
    final name = a["patient_name"] ?? "Unknown";
    final email = a["patient_email"] ?? "";
    final initials = name.isNotEmpty ? name[0].toUpperCase() : "?";
    final slot = a["appointment_slot"] ?? "";
    final date = a["appointment_date"] ?? "";
    final status = a["booking_status"] ?? "Booked";

    Color statusColor;
    switch (status) {
      case "Completed":
        statusColor = const Color(0xFF00C48C);
        break;
      case "Confirmed":
        statusColor = Colors.blue[400]!;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: primaryBlue.withOpacity(0.15),
                child: Text(initials,
                    style: const TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(email,
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 11)),
                    const SizedBox(height: 3),
                    Text('$slot · $date',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final apptId = a["id"];
                      setState(() {
                        _appointments.remove(a);
                        _onSearch();
                      });
                      if (apptId != null) {
                        final idInt = int.tryParse(apptId.toString());
                        if (idInt != null) {
                          await ApiService.deleteAppointment(idInt);
                        }
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Appointment deleted"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),

                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(status,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final patientData =
                        await ApiService.getPatientProfile(email);
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PatientDetailsScreen(patient: patientData),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: Colors.blue[400]!.withOpacity(0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('View',
                      style: TextStyle(
                          color: Colors.blue[400],
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          WritePrescriptionScreen(appointment: a),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(
                        color: const Color(0xFF00C48C).withOpacity(0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Write Rx',
                      style: TextStyle(
                          color: Color(0xFF00C48C),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent),
      child: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        DoctorDashboardScreen(doctorId: widget.doctorId)),
                (r) => false);
          } else if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        MyScheduleScreen(doctorId: widget.doctorId)));
          } else if (index == 2) {
            return;
          } else if (index == 3) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        MyRecordsScreen(doctorId: widget.doctorId)));
          } else if (index == 4) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DoctorAssistantScreen(
                        doctorId: widget.doctorId)));
          }
        },
        backgroundColor: const Color(0xFF1E1E1E),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        currentIndex: 2,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_outlined)),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.calendar_today)),
              label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_outline)),
              label: 'Patients'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.description_outlined)),
              label: 'Records'),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.smart_toy_outlined)),
              label: 'AI'),
        ],
      ),
    );
  }
}

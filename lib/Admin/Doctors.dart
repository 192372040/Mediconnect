
import 'package:flutter/material.dart';
import 'package:my_project/Admin/AdProfile.dart';
import 'package:my_project/Admin/BedsS.dart';
import 'package:my_project/Admin/Doctors.dart';
import 'package:my_project/Admin/Analytis.dart';
import 'package:my_project/Admin/Dashboard.dart';
import '../Patientdashboard/services/api_service.dart';
import 'package:my_project/Admin/ViewDoctorDetailsScreen.dart';
class ManageDoctorsScreen extends StatefulWidget {

  final String hospitalId;

  const ManageDoctorsScreen({
    Key? key,
    required this.hospitalId,
  }) : super(key: key);

  @override
  State<ManageDoctorsScreen> createState() =>
      _ManageDoctorsScreenState();
}

class _ManageDoctorsScreenState
    extends State<ManageDoctorsScreen> {

  final TextEditingController
      doctorIdController =
      TextEditingController();
      List doctors = [];

@override
void initState() {

  super.initState();

  loadDoctors();
}

Future loadDoctors() async {

  doctors =
      await ApiService
          .getHospitalDoctors(

    widget.hospitalId,
  );

  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF252525);
    const Color primaryColor = Color(0xFFC7781E);
    const Color cardBgColor = Color(0xFF1E1E1E);

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
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Manage doctors',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[800], height: 1),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Search Bar
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: cardBgColor,
                      prefixIcon: const Icon(Icons.search, color: primaryColor),
                      hintText: 'Search by Doctor ID or name...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Add Doctor Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      border: Border.all(color: primaryColor.withOpacity(0.6)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add doctor to hospital',
                          style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                       TextField(
  controller: doctorIdController,
  style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF2A2A2A),
                            hintText: 'Enter Doctor ID (MED-DOC-...)',
                            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {

  var res =
      await ApiService.addDoctorToHospital(

    hospitalId:
        widget.hospitalId,

    doctorId:
        doctorIdController.text,
  );

  ScaffoldMessenger.of(context)
      .showSnackBar(

    SnackBar(

      content: Text(
        res["message"] ??
        res["error"],
      ),
    ),
  );
  loadDoctors();
},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Add to hospital',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Section Title
                  const Text(
                    'Hospital doctors (45)',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Doctor List
                 if (doctors.isEmpty)

  const Center(
    child: Text(
      "No doctors added",
      style: TextStyle(
        color: Colors.white,
      ),
    ),
  )

else

  ...doctors.map((doctor) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: _buildDoctorCard(
        doctorId: doctor["doctor_id"],
        initials:
            doctor["full_name"]
                .substring(0, 1),

        name:
            doctor["full_name"],

        details:
            "${doctor["doctor_id"]} - ${doctor["specialization"] ?? "General"}",

        status: "Active",

        statusColor:
            Colors.green,

        avatarColor:
            primaryColor,
      ),
    );
  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1E1E1E),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          currentIndex: 1, 
          onTap: (index) {

  // HOME
  if (index == 0) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            HospitalDashboardScreen(

          hospitalId: widget.hospitalId,

        ),
      ),
    );
  }

  // DOCTORS
  else if (index == 1) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            ManageDoctorsScreen(
hospitalId: widget.hospitalId,
),

      ),
    );
  }

  // BEDS
  else if (index == 2) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            BedManagementScreen( hospitalId: widget.hospitalId,),

      ),
    );
  }

  // ANALYTICS
  else if (index == 3) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            AnalyticsScreen( hospitalId: widget.hospitalId,),

      ),
    );
  }

  // PROFILE
  else if (index == 4) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            HospitalProfileScreen(

          hospitalData: null,
hospitalId: widget.hospitalId,
        ),
      ),
    );
  }
},// 'Doctors' is active
          elevation: 10,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_outlined)), label: 'Home'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline)), label: 'Doctors'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.medical_services_outlined)), label: 'Beds'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.show_chart)), label: 'Analytics'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.circle_outlined)), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard({
    required String doctorId,
    required String initials,
    required String name,
    required String details,
    required String status,
    required Color statusColor,
    required Color avatarColor,
  }) {
    const Color cardBgColor = Color(0xFF1E1E1E);

    return Container(
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
                radius: 24,
                backgroundColor: avatarColor.withOpacity(0.15),
                child: Text(
                  initials,
                  style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details.split(' - ')[0],
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    Text(
                      '- ${details.split(' - ')[1]}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
             Expanded(
  child: OutlinedButton(
    onPressed: () {

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (context) =>
              DoctorDetailsScreen(doctorId: doctorId),

        ),
      );
    },

    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 12),
      side: BorderSide(color: Colors.blue[600]!),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    child: Text(
      'View',
      style: TextStyle(
        color: Colors.blue[400],
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
              const SizedBox(width: 12),
             Expanded(
  child: OutlinedButton(
    onPressed: () {},
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 12),
      side: BorderSide(color: Colors.red[400]!),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(
      'Remove',
      style: TextStyle(
        color: Colors.red[400],
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
            ],
          ),
        ],
      ),
    );
  }
}

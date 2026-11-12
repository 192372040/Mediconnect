import 'package:flutter/material.dart';
import 'package:my_project/Admin/AdProfile.dart';
import 'package:my_project/Admin/Doctors.dart';
import 'package:my_project/Admin/Analytis.dart';
import 'package:my_project/Admin/Dashboard.dart';
import '../Patientdashboard/services/api_service.dart';

class BedManagementScreen extends StatefulWidget {
  final String hospitalId;

  const BedManagementScreen({
    Key? key,
    required this.hospitalId,
  }) : super(key: key);

  @override
  State<BedManagementScreen> createState() => _BedManagementScreenState();
}

class _BedManagementScreenState extends State<BedManagementScreen> {
  List<dynamic> bedsData = [];
  bool isLoading = true;

  int totalAvailable = 0;
  int totalOccupied = 0;
  int overallTotal = 0;
  double occupancyRate = 0.0;

  @override
  void initState() {
    super.initState();
    fetchBeds();
  }

  Future<void> fetchBeds() async {
    setState(() => isLoading = true);
    final data = await ApiService.getHospitalBeds(widget.hospitalId);
    
    int tAvailable = 0;
    int tOccupied = 0;

    int parseSafeInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    for (var ward in data) {
      tAvailable += parseSafeInt(ward['available_beds']);
      tOccupied += parseSafeInt(ward['occupied_beds']);
    }


    setState(() {
      bedsData = data;
      totalAvailable = tAvailable;
      totalOccupied = tOccupied;
      overallTotal = tAvailable + tOccupied;
      occupancyRate = overallTotal == 0 ? 0.0 : (totalOccupied / overallTotal);
      isLoading = false;
    });
  }

  void _showAddEditBedDialog({Map<String, dynamic>? ward}) {
    final TextEditingController nameController = TextEditingController(text: ward?['ward_name'] ?? '');
    final TextEditingController availableController = TextEditingController(text: (ward?['available_beds'] ?? 0).toString());
    final TextEditingController occupiedController = TextEditingController(text: (ward?['occupied_beds'] ?? 0).toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(ward == null ? 'Add Beds' : 'Manage Beds', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                readOnly: ward != null,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Ward Name', labelStyle: TextStyle(color: Colors.grey)),
              ),
              TextField(
                controller: availableController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Available Beds', labelStyle: TextStyle(color: Colors.grey)),
              ),
              TextField(
                controller: occupiedController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Occupied Beds', labelStyle: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () async {
                await ApiService.updateHospitalBeds(
                  hospitalId: widget.hospitalId,
                  wardName: nameController.text.trim(),
                  availableBeds: int.tryParse(availableController.text) ?? 0,
                  occupiedBeds: int.tryParse(occupiedController.text) ?? 0,
                );
                Navigator.pop(context);
                fetchBeds();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC7781E)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF252525);
    const Color primaryColor = Color(0xFFC7781E);
    const Color cardBgColor = Color(0xFF1E1E1E);
    const Color successColor = Color(0xFF00C48C);
    const Color dangerColor = Color(0xFFFF5252);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            'Bed management',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showAddEditBedDialog(),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: primaryColor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: const Text(
                              '+ Add beds',
                              style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
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
                        // Top Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatCard('$totalAvailable', 'Available', successColor, cardBgColor),
                            const SizedBox(width: 12),
                            _buildStatCard('$totalOccupied', 'Occupied', dangerColor, cardBgColor),
                            const SizedBox(width: 12),
                            _buildStatCard('$overallTotal', 'Total', primaryColor, cardBgColor),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Overall Occupancy
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Overall occupancy',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${(occupancyRate * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: occupancyRate,
                                  backgroundColor: Colors.grey[800],
                                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                                  minHeight: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Section Title
                        const Text(
                          'Ward wise availability',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        
                        // Ward Cards
                        if (bedsData.isEmpty)
                          const Center(child: Text("No beds added yet.", style: TextStyle(color: Colors.white70)))
                        else
                          ...bedsData.map((ward) {
                            int available = ward['available_beds'] ?? 0;
                            int occupied = ward['occupied_beds'] ?? 0;
                            int total = available + occupied;
                            double progress = total == 0 ? 0.0 : (occupied / total);
                            bool isCritical = available <= 5 && total > 0;
                            
                            Color statusColor = isCritical ? dangerColor : (progress > 0.8 ? primaryColor : successColor);
                            String statusText = isCritical ? 'Critical — $available left' : 'Good — $available left';
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildWardCard(
                                title: ward['ward_name'],
                                subtitle: 'Hospital Ward',
                                status: statusText,
                                statusColor: statusColor,
                                occupancyText: '$occupied/$total occupied',
                                progress: progress,
                                actionText: 'Manage',
                                isCritical: isCritical,
                                cardBgColor: cardBgColor,
                                onTapManage: () => _showAddEditBedDialog(ward: ward),
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
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalDashboardScreen(hospitalId: widget.hospitalId)));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ManageDoctorsScreen(hospitalId: widget.hospitalId)));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BedManagementScreen(hospitalId: widget.hospitalId)));
            } else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsScreen(hospitalId: widget.hospitalId)));
            } else if (index == 4) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalProfileScreen(hospitalData: null, hospitalId: widget.hospitalId)));
            }
          },
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

  Widget _buildStatCard(String value, String label, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: color.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildWardCard({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required String occupancyText,
    required double progress,
    required String actionText,
    required bool isCritical,
    required Color cardBgColor,
    required VoidCallback onTapManage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        border: Border.all(color: isCritical ? statusColor.withOpacity(0.8) : Colors.grey[800]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
              Text(
                status,
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                occupancyText,
                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
              ),
              GestureDetector(
                onTap: onTapManage,
                child: Text(
                  actionText,
                  style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
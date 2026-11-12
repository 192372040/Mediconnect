
import 'package:flutter/material.dart';
import 'package:my_project/Doctor/DoctorStep5Screen.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
class Step4HospitalDetailsScreen extends StatefulWidget {
  final String doctorId;

  const Step4HospitalDetailsScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<Step4HospitalDetailsScreen> createState() => _Step4HospitalDetailsScreenState();
}

class _Step4HospitalDetailsScreenState extends State<Step4HospitalDetailsScreen> {
  // Pre-filled with data from your images
  late TextEditingController _hospitalNameController;
  late TextEditingController _departmentController;
  late TextEditingController _addressController;

  List<String> _selectedDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  List<String> _selectedModes = ['In-person', 'Video call'];

  String _startTime = "";
  String _endTime = "";

  @override
  void initState() {
    super.initState();
    _hospitalNameController = TextEditingController();
    _departmentController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _departmentController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282828), // Dark background matching the image
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Hospital details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Where do you practice?',
                      style: TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildLabel('Department'),
                    _buildTextField(_departmentController, 'Enter department', true),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Working days'),
                    _buildWorkingDays(),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Available timing'),
                    _buildTimingBoxes(),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Consultation mode'),
                    _buildConsultationModes(),
                    const SizedBox(height: 48),
                    
                    _buildContinueButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF195E9A), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Step Indicators (3 Green, 1 Blue Pill, 1 Grey)
          Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00A36C), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00A36C), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00A36C), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(
                width: 24,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF195E9A),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4A4A4A), shape: BoxShape.circle)),
            ],
          ),
          // Step Text
          const Text(
            'Step 4 of 5',
            style: TextStyle(
              color: Color(0xFF195E9A),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Stack(
      children: [
        Container(
          height: 2,
          width: double.infinity,
          color: const Color(0xFF3A3A3A),
        ),
        Container(
          height: 2,
          width: MediaQuery.of(context).size.width * 0.8, // Represents 4/5 progress
          color: const Color(0xFF195E9A),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8E8E8E),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isFocusedMode) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF5A5A5A)),
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isFocusedMode ? const Color(0xFF195E9A) : const Color(0xFF3A3A3A)
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF195E9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return TextField(
      controller: _addressController,
      maxLines: 3,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: 'Enter full address',
        hintStyle: const TextStyle(color: Color(0xFF5A5A5A)),
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)), // Grey border for address
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF195E9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildWorkingDays() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: days.map((day) {
        bool isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(day);
              } else {
                _selectedDays.add(day);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF195E9A) : const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF195E9A) : const Color(0xFF3A3A3A),
              ),
            ),
            child: Text(
              day,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimingBoxes() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 9, minute: 0),
              );
              if (picked != null) {
                setState(() => _startTime = picked.format(context));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: Column(
                children: [
                  const Text('From', style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
  _startTime.isEmpty
      ? "Select"
      : _startTime, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(Icons.arrow_forward, color: Color(0xFF5A5A5A), size: 20),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 17, minute: 0),
              );
              if (picked != null) {
                setState(() => _endTime = picked.format(context));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: Column(
                children: [
                  const Text('To', style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12)),
                  const SizedBox(height: 4),
                 Text(
  _endTime.isEmpty
      ? "Select"
      : _endTime,style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationModes() {
    return Row(
      children: [
        Expanded(child: _buildModeOption('In-person', Icons.person_outline)),
        const SizedBox(width: 12),
        Expanded(child: _buildModeOption('Video call', Icons.videocam_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildModeOption('Both', Icons.assignment_outlined)),
      ],
    );
  }

  Widget _buildModeOption(String mode, IconData icon) {
    bool isSelected = _selectedModes.contains(mode);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (mode == 'Both') {
            _selectedModes = ['In-person', 'Video call', 'Both'];
          } else {
            if (isSelected) {
              _selectedModes.remove(mode);
            } else {
              _selectedModes.add(mode);
            }
            _selectedModes.remove('Both');
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A2634) : const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF195E9A) : const Color(0xFF3A3A3A),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4A89C8) : const Color(0xFF5A5A5A),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              mode,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4A89C8) : const Color(0xFF8E8E8E),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
   onPressed: () async {

  var res =
      await ApiService
          .saveHospitalDetails(

   doctorId:
    widget.doctorId,

    hospitalName:
        "",

    department:
        _departmentController.text,

    workingDays:
        _selectedDays,

    startTime:
        _startTime,

    endTime:
        _endTime,

    hospitalAddress:
        "",

    consultationMode:
        _selectedModes,
  );

  print(res);

  if (res["message"] != null) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Step5SuccessScreen(
  doctorId:
      widget.doctorId,
)
      ),
    );

  } else {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          res["error"] ??
              "Something went wrong",
        ),
      ),
    );
  }
},

 
      
        // Handle API submission and navigation to Step 5 here
       
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF195E9A),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Continue',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

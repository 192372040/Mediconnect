
import 'package:flutter/material.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
class WritePrescriptionScreen extends StatefulWidget {

  final Map appointment;

  const WritePrescriptionScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<WritePrescriptionScreen> createState() =>
      _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState
    extends State<WritePrescriptionScreen> {

  final diagnosisController =
      TextEditingController();

  final medicinesController =
      TextEditingController();

  final notesController =
      TextEditingController();
      List<Map<String, TextEditingController>> medicines = [
  {
    "name": TextEditingController(),
    "frequency": TextEditingController(),
    "duration": TextEditingController(),
    "instruction": TextEditingController(),
  }
];

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF252525);
    const Color successGreen = Color(0xFF00C48C);
    const Color buttonGreen = Color(0xFF167654); // Deep green for the save button

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
                      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0D5E42), size: 18),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Write prescription',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                    // Patient Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF17293A), // Dark blue tint
                        border: Border.all(color: Colors.blue[800]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Builder(builder: (_) {
                        final rawName = (widget.appointment["patient_name"] ?? "").toString().trim();
                        final rawEmail = (widget.appointment["patient_email"] ?? "").toString().trim();
                        final pName = rawName.isNotEmpty
                            ? rawName
                            : (rawEmail.contains('@') ? rawEmail.split('@')[0] : 'Patient');
                        final pInit = pName.isNotEmpty ? pName[0].toUpperCase() : 'P';
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.blue[600],
                              child: Text(pInit,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  rawEmail.isNotEmpty ? rawEmail : 'Patient',
                                  style: TextStyle(
                                      color: Colors.blue[300], fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 24),
                    
                    // Diagnosis Section
                    const Text('Diagnosis', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
  controller: diagnosisController,
  style: const TextStyle(
    color: Colors.white,
  ),
  decoration: InputDecoration(
    filled: true,
    fillColor: const Color(0xFF2A2A2A),
    hintText: "Enter diagnosis",
    hintStyle: const TextStyle(
      color: Colors.grey,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  ),
),
                    
                    // Medicines Section
                    const Text('Medicines', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    
                    // Medicine Cards
       ...List.generate(
  medicines.length,
  (index) => _buildMedicineCard(
    medicines[index],
    index,
  ),
),
                    
                    // Add Medicine Button
                    GestureDetector(
                     onTap: () {
  setState(() {
    medicines.add({
      "name": TextEditingController(),
      "frequency": TextEditingController(),
      "duration": TextEditingController(),
      "instruction": TextEditingController(),
    });
  });
},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: successGreen.withOpacity(0.05), // Very subtle green tint
                          border: Border.all(
                            color: successGreen.withOpacity(0.5), 
                            width: 1.5,
                            style: BorderStyle.solid, // Using solid as a fallback for dashed in core flutter
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '+ Add medicine',
                          style: TextStyle(color: successGreen, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Doctor notes Section
                    const Text('Doctor notes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                   TextField(
  controller: notesController,
  maxLines: 3,
  style: const TextStyle(
    color: Colors.white,
  ),
  decoration: InputDecoration(
    filled: true,
    fillColor: const Color(0xFF2A2A2A),
    hintText: "Enter doctor notes",
    hintStyle: const TextStyle(
      color: Colors.grey,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  ),
),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    GestureDetector(
                     onTap: () async {
                       final rawName = (widget.appointment["patient_name"] ?? "").toString().trim();
                       final rawEmail = (widget.appointment["patient_email"] ?? "").toString().trim();
                       final pName = rawName.isNotEmpty
                           ? rawName
                           : (rawEmail.contains('@') ? rawEmail.split('@')[0] : 'Patient');
                       final dName = (widget.appointment["doctor_name"] ?? "").toString().trim();

                       final medContent = medicines
                           .where((m) => (m["name"]?.text.trim().isNotEmpty ?? false))
                           .map((m) {
                         return '''
Medicine: ${m["name"]?.text.trim()}
Frequency: ${m["frequency"]?.text.trim()}
Duration: ${m["duration"]?.text.trim()}
Instructions: ${m["instruction"]?.text.trim()}
''';
                       }).join("\n\n");

                       var result = await ApiService.savePrescription(
                         patientName: pName,
                         patientEmail: rawEmail,
                         doctorName: dName,
                         diagnosis: diagnosisController.text.trim(),
                         medicines: medContent.isNotEmpty
                             ? medContent
                             : medicines.map((m) => "Medicine: ${m["name"]?.text}").join("\n"),
                         doctorNotes: notesController.text.trim(),
                       );

                       if (mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
                             content: Text("Prescription Saved Successfully"),
                             backgroundColor: Color(0xFF00C48C),
                           ),
                         );
                         Navigator.pop(context, true);
                       }
                     },

                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: buttonGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Save prescription',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildMedicineCard(
  Map<String, TextEditingController> medicine,
  int index,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [

    Text(
      "Medicine ${index + 1}",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),

    IconButton(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () {
        setState(() {
          medicines.removeAt(index);
        });
      },
    ),

  ],
),

const SizedBox(height: 10),
        TextField(
          controller: medicine["name"],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            hintText: "Medicine Name",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [

            Expanded(
              child: TextField(
                controller: medicine["frequency"],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Frequency",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: TextField(
                controller: medicine["duration"],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Duration",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        TextField(
          controller: medicine["instruction"],
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Instructions",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildInputField({required String text, bool isHint = false, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: TextStyle(color: isHint ? Colors.grey[600] : Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        hintText: isHint ? text : null,
        hintStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      controller: isHint ? null : TextEditingController(text: text),
    );
  }
}

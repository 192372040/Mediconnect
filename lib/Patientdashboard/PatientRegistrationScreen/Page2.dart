import 'package:flutter/material.dart';
import 'Page3.dart';
import '../services/api_service.dart';

class Step2PersonalDetailsScreen extends StatefulWidget {
  final String email;
  final Map? user;

 const Step2PersonalDetailsScreen({
  super.key,
  required this.email,
  this.user,
});
  @override
  State<Step2PersonalDetailsScreen> createState() =>
      _Step2PersonalDetailsScreenState();
}

class _Step2PersonalDetailsScreenState
    extends State<Step2PersonalDetailsScreen> {
  // Theme Colors
  static const Color primary = Color(0xFF167B58);
  static const Color primaryBg = Color(0xFF242424);

  // State variables
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  int _age = 18;
  String _selectedBloodGroup = 'B+';
  String _selectedGender = 'Female';

  // Country Code variables
  String _selectedCountryCode = '+91';
  final List<String> _countryCodes = [
    '+91',
    '+1',
    '+44',
    '+61',
    '+81',
    '+86',
    '+49',
    '+33',
    '+971'
  ];

  // Medical History Data & State
  final List<String> _defaultHistory = [
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Heart disease',
    'Thyroid',
  ];
  final List<String> _moreHistory = [
    'Arthritis',
    'High Cholesterol',
    'Kidney issues',
    'Liver issues',
    'Cancer',
  ];
  final List<String> _selectedHistory = ['Diabetes'];
  bool _showMoreHistory = false; // Controls the "+" button expansion

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  
void initState() {
  super.initState();

  if (widget.user != null) {
    _nameController.text = widget.user!["name"] ?? "";
    _mobileController.text = widget.user!["phone"] ?? "";

    _age = widget.user!["age"] ?? 18;

    _selectedBloodGroup =
        widget.user!["blood_group"] ?? "B+";

    _selectedGender =
        widget.user!["gender"] ?? "Female";

    String history =
        widget.user!["medical_history"] ?? "";

    if (history.isNotEmpty) {
      _selectedHistory.clear();
      _selectedHistory.addAll(history.split(","));
    }
  }
}
  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  String _calculateRiskLevel() {
    if (_selectedHistory.contains('Heart disease') ||
        _selectedHistory.contains('Hypertension') ||
        _selectedHistory.contains('Cancer')) {
      return 'High';
    } else if (_selectedHistory.contains('Diabetes') ||
        _selectedHistory.contains('Asthma') ||
        _selectedHistory.contains('Thyroid')) {
      return 'Moderate';
    }
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation and Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _buildHeader(),
            ),
            const SizedBox(height: 16),

            // Progress Bar (Step 2 of 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  Container(
                    height: 3,
                    width: MediaQuery.of(context).size.width * 0.66,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Your basic details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Help us personalise your care",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 32),

                    // Full Name
                    const Text(
                      'Full name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: const TextStyle(color: Colors.black26),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mobile Number with Country Code Dropdown
                    const Text(
                      'Mobile number',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Country Code Dropdown
                        Container(
                          height: 54, // Matches the textfield height
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountryCode,
                              dropdownColor: Colors.white,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.black54),
                              items: _countryCodes.map((code) {
                                return DropdownMenuItem(
                                  value: code,
                                  child: Text(code),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCountryCode = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Mobile Text Field
                        Expanded(
                          child: TextField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Enter your mobile number',
                              hintStyle: const TextStyle(color: Colors.black26),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Age and Blood Group Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Age Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Age',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Colors.black54,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      if (_age > 1) {
                                        setState(() => _age--);
                                      }
                                    },
                                  ),
                                  Text(
                                    '$_age',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Color(
                                        0xFFE5F5EF,
                                      ), // Light green block
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        color: primary,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _age++),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        // Blood Group Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Blood group',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _bloodGroups.map((bg) {
                                  bool isSelected = _selectedBloodGroup == bg;
                                  return GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedBloodGroup = bg,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected ? primary : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        bg,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Gender Section
                    const Text(
                      'Gender',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _genders.map((gender) {
                        bool isSelected = _selectedGender == gender;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedGender = gender),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: gender == 'Other' ? 0 : 12,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? primary : Colors.white54,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                gender,
                                style: TextStyle(
                                  color: isSelected ? primary : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Medical History Section
                    Row(
                      children: [
                        const Text(
                          'Medical history',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'optional',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white38),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          // Render default items
                          ..._defaultHistory.map(
                            (item) => _buildHistoryChip(item),
                          ),

                          // Render extra items if the plus button was clicked
                          if (_showMoreHistory)
                            ..._moreHistory.map(
                              (item) => _buildHistoryChip(item),
                            ),

                          // The Plus/Minus Expand Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMoreHistory = !_showMoreHistory;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.white54),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _showMoreHistory ? Icons.remove : Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Risk Profile Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAEEDB), // Light beige
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Risk profile: Moderate',
                                  style: TextStyle(
                                    color: Color(0xFF5E3A1A), // Dark brown
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Based on your age & medical history',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF5E3A1A,
                                    ).withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Save & Continue Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    var res = await ApiService.updateProfile(
                           widget.email,
                           _nameController.text.trim(),
                          _mobileController.text.trim(), // ✅ ADD THIS
                          _age,
                          _selectedBloodGroup,
                          _selectedGender,
                          _selectedHistory,
                            ); 

                    print(res);

                if (res["message"] == "Profile saved successfully") {
  print("Profile updated ✅");

  if (widget.user != null) {
    // ✅ Edit mode
    Navigator.pop(context, res["user"]);
  } else {
    // ✅ Registration mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Step3ProfileCreatedScreen(
          user: res["user"],
          name: _nameController.text.trim(),
          phone: _mobileController.text.trim().isEmpty
              ? 'N/A'
              : '$_selectedCountryCode ${_mobileController.text.trim()}',
          age: _age,
          gender: _selectedGender,
          bloodGroup: _selectedBloodGroup,
          riskLevel: _calculateRiskLevel(),
          conditions: List<String>.from(_selectedHistory),
        ),
      ),
    );
  }

} else {
  print("Error ❌");
}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save & continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the selectable chips for medical history
  Widget _buildHistoryChip(String item) {
    bool isSelected = _selectedHistory.contains(item);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedHistory.remove(item);
          } else {
            _selectedHistory.add(item);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border.all(color: isSelected ? Colors.white : Colors.white54),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          item,
          style: TextStyle(
            color: isSelected ? primaryBg : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Header Navigation Helper
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 18,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 6,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 24,
              height: 6,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white54,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const Text(
          'Step 2 of 3',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

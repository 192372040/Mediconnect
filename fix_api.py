import sys

file_path = r'c:\Users\asusr\flutterApps\my_project\lib\Patientdashboard\services\api_service.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

replacement = """  }

  static Future<Map<String, dynamic>> bookAppointment({
    required String patientEmail,
    required String patientName,
    required String doctorName,
    required String specialization,
    required String hospitalName,
    required String appointmentSlot,
    required String paymentMethod,
    required String consultationFee,
    required String appointmentDate,
  }) async {
    final res = await http.post(
      Uri.parse(f"$baseUrl/book-appointment"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "patient_email": patientEmail,
        "patient_name": patientName,
        "doctor_name": doctorName,
        "specialization": specialization,
        "hospital_name": hospitalName,
        "appointment_slot": appointmentSlot,
        "payment_method": paymentMethod,
        "consultation_fee": consultationFee,
        "appointment_date": appointmentDate,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future forgotAdminId({required String email}) async {
    final res = await http.post(
      Uri.parse(f"$baseUrl/forgot-admin-id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getBookedSlots({
    required String doctorName,
    required String appointmentDate,
  }) async {
    final res = await http.get(
      Uri.parse(
        f"$baseUrl/booked-slots"
        f"?doctor_name=$doctorName"
        f"&appointment_date=$appointmentDate",
      ),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      return [];
    }
  }

  static Future saveDoctorDetails({
    required String email,
    required String fullName,
    required int age,
    required String gender,
    required String phone,
    required String dob,
  }) async {
    final res = await http.post(
      Uri.parse(
        f"$baseUrl/save-doctor-details",
      ),
      headers: {""".replace('f"$baseUrl', '"$baseUrl').replace('f"?doctor_name=', '"?doctor_name=').replace('f"&appointment_date=', '"&appointment_date=').replace('f"$baseUrl/save-doctor-details"', '"$baseUrl/save-doctor-details"')

target_str = """  }

      headers: {"""

if target_str in content:
    new_content = content.replace(target_str, replacement)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Replaced successfully")
else:
    print("Target string not found")

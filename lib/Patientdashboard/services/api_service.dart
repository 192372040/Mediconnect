import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // If you run this app on the Android emulator, use 10.0.2.2 to reach the PC localhost.
  // If using a real device, replace this with your PC's actual LAN IP address.
  static const String baseUrl =
      "https://harold-penetration-teens-only.trycloudflare.com";

  static Future sendOtp(String email) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      print("SEND OTP STATUS: ${res.statusCode}");
      print("SEND OTP BODY: ${res.body}");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }

      final body = jsonDecode(res.body);
      return body;
    } catch (e) {
      print("SEND OTP ERROR: $e");
      return {"error": e.toString()};
    }
  }

  static Future verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    print("STATUS CODE: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      return {"error": "Server error: ${res.statusCode}"};
    }
  }

  static Future updateProfile(
    String email,
    String name,
    String phone,
    int age,
    String bloodGroup,
    String gender,
    List<String> medicalHistory,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/update-profile"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "name": name,
          "phone": phone,
          "age": age,
          "blood_group": bloodGroup,
          "gender": gender,
          "medical_history": medicalHistory,
        }),
      );

      print("UPDATE PROFILE STATUS: ${response.statusCode}");
      print("UPDATE PROFILE BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Server error: ${response.statusCode}"};
      }
    } catch (e) {
      print("UPDATE PROFILE ERROR: $e");

      return {"error": e.toString()};
    }
  }

  static Future<List<dynamic>> getHospitals() async {
    final res = await http.get(
      Uri.parse("$baseUrl/hospitals"),
    );

    print("HOSPITAL STATUS: ${res.statusCode}");
    print("HOSPITAL BODY: ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      return [];
    }
  }

  static Future<List<dynamic>> getDoctors(String hospitalId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/doctors/$hospitalId"),
    );

    print("DOCTORS STATUS: ${res.statusCode}");
    print("DOCTORS BODY: ${res.body}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createRazorpayOrder(String amount) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/create-razorpay-order"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": amount}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"success": false, "error": "Server error: ${res.statusCode}"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

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
      Uri.parse("$baseUrl/book-appointment"),
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
      Uri.parse("$baseUrl/forgot-admin-id"),
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
        "$baseUrl/booked-slots"
        "?doctor_name=$doctorName"
        "&appointment_date=$appointmentDate",
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
    try {
      final res = await http.post(
        Uri.parse(
          "$baseUrl/save-doctor-details",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "full_name": fullName,
          "age": age,
          "gender": gender,
          "phone": phone,
          "dob": dob,
        }),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {"error": "Server error: ${res.statusCode}"};
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }

  static Future saveHospitalDetails({
    required String doctorId,
    required String hospitalName,
    required String department,
    required List<String> workingDays,
    required String startTime,
    required String endTime,
    required String hospitalAddress,
    required List<String> consultationMode,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(
          "$baseUrl/save-hospital-details",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "doctor_id": doctorId,
          "hospital_name": hospitalName,
          "department": department,
          "working_days": workingDays,
          "start_time": startTime,
          "end_time": endTime,
          "hospital_address": hospitalAddress,
          "consultation_mode": consultationMode,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        try {
          return jsonDecode(res.body);
        } catch (_) {
          return {"error": "Server error: ${res.statusCode}"};
        }
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }

  static Future getDoctorSummary(String doctorId) async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/get-doctor-summary"
        "?doctor_id=$doctorId",
      ),
    );

    return jsonDecode(res.body);
  }

  static Future saveProfessionalDetails({
    required String doctorId,
    required String qualification,
    required String specialization,
    required String experience,
    required String licenseNumber,
    required String consultationFee,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(
          "$baseUrl/save-professional-details",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "doctor_id": doctorId,
          "qualification": qualification,
          "specialization": specialization,
          "experience": experience,
          "license_number": licenseNumber,
          "consultation_fee": consultationFee,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        try {
          return jsonDecode(res.body);
        } catch (_) {
          return {"error": "Server error: ${res.statusCode}"};
        }
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }

  static Future getDoctorProfile(
    String doctorId,
  ) async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/get-doctor-profile"
        "?doctor_id=$doctorId",
      ),
    );

    return jsonDecode(res.body);
  }

  static Future savePassword({
    required String doctorId,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(
          "$baseUrl/save-password",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "doctor_id": doctorId,
          "password": password,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        try {
          return jsonDecode(res.body);
        } catch (_) {
          return {"error": "Server error: ${res.statusCode}"};
        }
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }

  static Future doctorLogin({
    required String doctorId,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(
        "$baseUrl/doctor-login",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "doctor_id": doctorId,
        "password": password,
      }),
    );

    return jsonDecode(res.body);
  }

  static Future forgotDoctorId({
    required String email,
  }) async {
    final res = await http.post(
      Uri.parse(
        "$baseUrl/forgot-doctor-id",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
      }),
    );

    return jsonDecode(res.body);
  }

  static Future sendAdminOtp(
    String email,
  ) async {
    try {
      final res = await http.post(
        Uri.parse(
          "$baseUrl/send-admin-otp",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
        }),
      );

      print(
        "ADMIN OTP STATUS: ${res.statusCode}",
      );

      print(
        "ADMIN OTP BODY: ${res.body}",
      );

      if (res.statusCode == 200) {
        return jsonDecode(
          res.body,
        );
      }

      final body = jsonDecode(res.body);

      return body;
    } catch (e) {
      print(
        "ADMIN OTP ERROR: $e",
      );

      return {
        "error": e.toString(),
      };
    }
  }

  static Future saveAdminHospital({
    required String adminEmail,
    required String hospitalName,
    required String adminName,
    required String hospitalAddress,
    required String hospitalType,
    required String establishedYear,
    required String hospitalId,
  }) async {
    final res = await http.post(
      Uri.parse(
        "$baseUrl/save-admin-hospital",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "admin_email": adminEmail,
        "hospital_name": hospitalName,
        "admin_name": adminName,
        "hospital_address": hospitalAddress,
        "hospital_type": hospitalType,
        "established_year": establishedYear,
        "hospital_id": hospitalId,
      }),
    );

    return jsonDecode(
      res.body,
    );
  }

  static Future verifyHospitalId(
    String hospitalId,
  ) async {
    final res = await http.post(
      Uri.parse(
        "$baseUrl/verify-hospital-id",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "hospital_id": hospitalId,
      }),
    );

    return jsonDecode(
      res.body,
    );
  }

  static Future saveAdminPassword({
    required String hospitalId,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(
        "$baseUrl/save-admin-password",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "hospital_id": hospitalId,
        "password": password,
      }),
    );

    return jsonDecode(
      res.body,
    );
  }

  static Future getAdminHospitalSummary(
    String hospitalId,
  ) async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/get-admin-hospital-summary?hospital_id=$hospitalId",
      ),
    );

    return jsonDecode(
      res.body,
    );
  }

  static Future adminLogin({
    required String hospitalId,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(
        "$baseUrl/admin-login",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "hospital_id": hospitalId,
        "password": password,
      }),
    );

    return jsonDecode(
      res.body,
    );
  }

  static Future addDoctorToHospital({
    required String hospitalId,
    required String doctorId,
  }) async {
    final res = await http.post(
      Uri.parse(
        "$baseUrl/add-doctor-to-hospital",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "hospital_id": hospitalId,
        "doctor_id": doctorId,
      }),
    );

    return jsonDecode(
      res.body,
    );
  }

  static Future<List<dynamic>> getHospitalDoctors(
    String hospitalId,
  ) async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/get-hospital-doctors"
        "?hospital_id=$hospitalId",
      ),
    );

    if (res.statusCode == 200) {
      return jsonDecode(
        res.body,
      );
    }

    return [];
  }

  static Future<List<dynamic>> getDoctorAppointments(
    String doctorName,
  ) async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/get-doctor-appointments"
        "?doctor_name=$doctorName",
      ),
    );

    if (res.statusCode == 200) {
      return jsonDecode(
        res.body,
      );
    }

    return [];
  }

  static Future savePrescription({
    required String patientName,
    required String patientEmail,
    required String doctorName,
    required String diagnosis,
    required String medicines,
    required String doctorNotes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/save-prescription'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "patient_name": patientName,
        "patient_email": patientEmail,
        "doctor_name": doctorName,
        "diagnosis": diagnosis,
        "medicines": medicines,
        "doctor_notes": doctorNotes,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future getPatientProfile(
    String email,
  ) async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/get-patient-profile?email=$email",
      ),
    );

    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getPatientPrescriptions(
    String email,
  ) async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/get-patient-prescriptions?email=$email",
      ),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }

  static Future<List<dynamic>> getPatientAppointments(String email) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get-patient-appointments?patient_email=$email"),
      );

      print("GET PATIENT APPOINTMENTS STATUS: ${res.statusCode}");
      print("GET PATIENT APPOINTMENTS BODY: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          return data["appointments"] ?? [];
        }
      }
      return [];
    } catch (e) {
      print("GET PATIENT APPOINTMENTS ERROR: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> deleteAccount(String email) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/delete-account"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"success": false, "error": "Server error: ${res.statusCode}"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateAppointmentStatus(
      int appointmentId, String status) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/update-appointment-status"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "appointment_id": appointmentId,
          "status": status,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"success": false, "error": "Server error: ${res.statusCode}"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteAppointment(

      int appointmentId) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/delete-appointment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"appointment_id": appointmentId}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"success": false, "error": "Server error: ${res.statusCode}"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// Fetch all prescriptions written by a doctor (by doctor_name)

  static Future<List<dynamic>> getDoctorPrescriptions(String doctorName) async {
    try {
      final res = await http.get(
        Uri.parse(
            "$baseUrl/get-doctor-prescriptions?doctor_name=${Uri.encodeComponent(doctorName)}"),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('getDoctorPrescriptions error: $e');
    }
    return [];
  }

  /// Add a time slot for a doctor on a specific date
  static Future<Map<String, dynamic>> addDoctorSlot({
    required String doctorId,
    required String date,
    required String time,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add-doctor-slot"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"doctor_id": doctorId, "date": date, "time": time}),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      print('addDoctorSlot error: $e');
    }
    return {"success": false};
  }

  static Future<List<dynamic>> getDoctorSlots(String doctorId) async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/get-doctor-slots?doctor_id=$doctorId"));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      print('getDoctorSlots error: $e');
    }
    return [];
  }

  // Hospital Admin APIs

  static Future<List<dynamic>> getHospitalAppointments(String hospitalId,
      {String? date}) async {
    try {
      String url = "$baseUrl/get-hospital-appointments?hospital_id=$hospitalId";
      if (date != null) {
        url += "&appointment_date=$date";
      }
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          return data["appointments"] ?? [];
        }
      }
      return [];
    } catch (e) {
      print("getHospitalAppointments error: $e");
      return [];
    }
  }

  static Future<List<dynamic>> getHospitalBeds(String hospitalId) async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/get-hospital-beds?hospital_id=$hospitalId"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          return data["beds"] ?? [];
        }
      }
      return [];
    } catch (e) {
      print("getHospitalBeds error: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> updateHospitalBeds({
    required String hospitalId,
    required String wardName,
    required int availableBeds,
    required int occupiedBeds,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/update-hospital-beds"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "hospital_id": hospitalId,
          "ward_name": wardName,
          "available_beds": availableBeds,
          "occupied_beds": occupiedBeds,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"success": false, "error": "Server error: ${res.statusCode}"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getHospitalAnalytics(
      String hospitalId) async {
    try {
      final res = await http.get(
          Uri.parse("$baseUrl/get-hospital-analytics?hospital_id=$hospitalId"));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"success": false, "error": "Server error: ${res.statusCode}"};
    } catch (e) {
      print("getHospitalAnalytics error: $e");
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateDoctorDetails({
    required String doctorId,
    required String consultationFee,
    required List<String> workingDays,
    required String startTime,
    required String endTime,
    required List<String> consultationMode,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/update-doctor-details"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "doctor_id": doctorId,
          "consultation_fee": consultationFee,
          "working_days": workingDays,
          "start_time": startTime,
          "end_time": endTime,
          "consultation_mode": consultationMode,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"success": false, "error": "Server error: ${res.statusCode}"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> rateDoctor({
    required int appointmentId,
    required int rating,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/rate-doctor"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "appointment_id": appointmentId,
          "rating": rating,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"success": false, "error": "Server error: ${res.statusCode}"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}

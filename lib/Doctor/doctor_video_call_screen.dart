import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:my_project/Widgets/WebVideoCallMock.dart';
import 'package:my_project/Config/zego_config.dart';

class DoctorVideoCallScreen extends StatelessWidget {
  final String callID;
  final String doctorId;
  final String doctorName;
  final String? patientName;

  const DoctorVideoCallScreen({
    super.key,
    required this.callID,
    required this.doctorId,
    required this.doctorName,
    this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    if (ZegoConfig.useZegoCloud) {
      final safeDoctorId = doctorId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final safeCallId = callID.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

      return ZegoUIKitPrebuiltCall(
        appID: ZegoConfig.appID,
        appSign: ZegoConfig.appSign,
        userID: safeDoctorId.isNotEmpty ? safeDoctorId : 'doctor_1',
        userName: doctorName.isNotEmpty ? doctorName : 'Doctor',
        callID: safeCallId.isNotEmpty ? safeCallId : 'room_1',
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      );
    }

    return WebVideoCallMock(
      title: 'Patient Consultation',
      roomName: callID,
      peerName: (patientName != null && patientName!.isNotEmpty) ? patientName! : 'Patient',
    );
  }
}
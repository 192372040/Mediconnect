import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:my_project/Widgets/WebVideoCallMock.dart';
import 'package:my_project/Config/zego_config.dart';

class VideoCallScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String callId;
  final String? doctorName;

  const VideoCallScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.callId,
    this.doctorName,
  });
  
  @override
  Widget build(BuildContext context) {
    if (ZegoConfig.useZegoCloud) {
      // Ensure userID and callID only contain letters, numbers and underscores
      final safeUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final safeCallId = callId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

      return ZegoUIKitPrebuiltCall(
        appID: ZegoConfig.appID,
        appSign: ZegoConfig.appSign,
        userID: safeUserId.isNotEmpty ? safeUserId : 'patient_1',
        userName: userName.isNotEmpty ? userName : 'Patient',
        callID: safeCallId.isNotEmpty ? safeCallId : 'room_1',
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      );
    }

    return WebVideoCallMock(
      title: 'Doctor Consultation',
      roomName: callId,
      peerName: (doctorName != null && doctorName!.isNotEmpty) ? doctorName! : 'Doctor',
    );
  }
}

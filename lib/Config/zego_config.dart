/// ZEGOCLOUD Configuration
/// 
/// If you have an active ZEGOCLOUD project created at https://console.zegocloud.com,
/// you can paste your AppID and AppSign below and set [useZegoCloud] to true.
/// 
/// When [useZegoCloud] is false, the app uses the built-in Interactive Video Call screen
/// which connects Doctor & Patient live via the backend without SDK authentication errors (1001004).
class ZegoConfig {
  static const bool useZegoCloud = true;


  /// Replace with your actual AppID from https://console.zegocloud.com
  static const int appID = 88808333;

  /// Replace with your actual AppSign from https://console.zegocloud.com
  static const String appSign =
      'f3edc4bfa2f30ee31ac67a061d2dd6fb90b1542acc07c44565008788e8ea512b';
}

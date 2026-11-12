import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

html.MediaStream? _activeLocalStream;

void registerWebCameraView() {
  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(
    'camera-view-element',
    (int viewId) {
      final videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.borderRadius = '16px';
      
      final devices = html.window.navigator.mediaDevices;
      if (devices != null) {
        devices.getUserMedia({'video': true, 'audio': false}).then((stream) {
          _activeLocalStream = stream;
          videoElement.srcObject = stream;
        }).catchError((err) {
          print("Camera access failed: $err");
        });
      } else {
        print("MediaDevices is null (usually occurs on non-HTTPS origins).");
      }
      
      return videoElement;
    },
  );
}

void stopWebCameraVideo() {
  if (_activeLocalStream != null) {
    try {
      _activeLocalStream!.getTracks().forEach((track) {
        track.stop();
      });
    } catch (e) {
      print("Error stopping tracks: $e");
    }
    _activeLocalStream = null;
  }
}

void openRazorpayWebCheckout({
  required String fee,
  required String doctorName,
  required String orderId,
  required String patientEmail,
  required Function(dynamic, dynamic, dynamic) onSuccess,
  required Function() onDismiss,
}) {
  // Clean fee string if it has symbols like '₹' or ','
  String amountStr = fee.replaceAll('₹', '').replaceAll(',', '').trim();
  double amount = double.tryParse(amountStr) ?? 0;

  var options = {
    'key': 'rzp_test_T3R0IL2TZZC1Gl',
    'amount': (amount * 100).toInt(),
    'name': 'MediConnect',
    'description': 'Consultation with $doctorName',
    'order_id': orderId,
    'prefill': {
      'contact': '7036092357',
      'email': patientEmail
    },
    'method': {
      'upi': true,
      'card': true,
      'netbanking': true,
      'wallet': true,
    }
  };

  // Register event listeners on the window
  late html.EventListener successListener;
  late html.EventListener dismissListener;

  successListener = (event) {
    try {
      final jsonStr = (event as html.CustomEvent).detail as String;
      final map = jsonDecode(jsonStr);
      final paymentId = map['payment_id'];
      final ordId = map['order_id'];
      final signature = map['signature'];

      // Remove listeners to avoid leaks
      html.window.removeEventListener('razorpay_success', successListener);
      html.window.removeEventListener('razorpay_dismiss', dismissListener);

      onSuccess(paymentId, ordId, signature);
    } catch (e) {
      print("Error parsing payment success details: $e");
      onDismiss();
    }
  };

  dismissListener = (event) {
    // Remove listeners to avoid leaks
    html.window.removeEventListener('razorpay_success', successListener);
    html.window.removeEventListener('razorpay_dismiss', dismissListener);

    onDismiss();
  };

  html.window.addEventListener('razorpay_success', successListener);
  html.window.addEventListener('razorpay_dismiss', dismissListener);

  try {
    final triggerEvent = html.CustomEvent('trigger_razorpay', detail: jsonEncode(options));
    html.window.dispatchEvent(triggerEvent);
  } catch (e) {
    print('Error triggering Razorpay Web: $e');
    onDismiss();
  }
}

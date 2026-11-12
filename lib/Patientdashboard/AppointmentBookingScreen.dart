import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:my_project/Widgets/platform_view_registry_stub.dart'
    if (dart.library.html) 'package:my_project/Widgets/platform_view_registry_web.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String doctorName;
  final String specialization;
  final String fee;
  final String selectedSlot;
  final String hospitalName;

  const AppointmentBookingScreen({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.fee,
    required this.selectedSlot,
    required this.hospitalName,
  });

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  static const Color primary = Color(0xFF0F6E56);
  static const Color primaryBg = Color(0xFF2C2A2A);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);

  late String _selectedSlot;
  DateTime selectedDate = DateTime.now();
  String _selectedPayment = 'UPI';
  bool _bookingConfirmed = false;
  bool _isBooking = false;
  late Razorpay _razorpay;
  bool isPastSlot(String slot) {
    final now = DateTime.now();

    // Check only today
    if (selectedDate.day != now.day ||
        selectedDate.month != now.month ||
        selectedDate.year != now.year) {
      return false;
    }

    final cleaned = slot.replaceAll(" ", "");

    final isPM = cleaned.contains("PM");

    final time = cleaned.replaceAll("AM", "").replaceAll("PM", "");

    final parts = time.split(":");

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (isPM && hour != 12) {
      hour += 12;
    }

    if (!isPM && hour == 12) {
      hour = 0;
    }

    final slotTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    return slotTime.isBefore(now);
  }

  String patientEmail = "";
  String patientName = "";
  List<dynamic> bookedSlots = [];
  final List<String> _allSlots = [
    '9:00 AM',
    '10:30 AM',
    '11:00 AM',
    '2:00 PM',
    '3:30 PM',
    '4:30 PM',
    '5:00 PM',
    '6:00 PM',
  ];

  final List<String> _paymentModes = ['UPI', 'Card', 'Cash'];
  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(selectedDate);
  }

  @override
  void initState() {
    loadUserEmail();
    super.initState();
    fetchBookedSlots();
    _selectedSlot = widget.selectedSlot;
    
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Payment succeeded, now book the appointment in the backend
    final res = await ApiService.bookAppointment(
      patientEmail: patientEmail,
      patientName: patientName,
      doctorName: widget.doctorName,
      specialization: widget.specialization,
      hospitalName: widget.hospitalName,
      appointmentSlot: _selectedSlot,
      paymentMethod: _selectedPayment,
      consultationFee: widget.fee,
      appointmentDate: formattedDate,
    );

    if (!mounted) return;

    setState(() {
      _isBooking = false;
    });

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Successful"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _bookingConfirmed = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["error"] ?? "Booking failed after payment"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isBooking = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isBooking = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet Selected: ${response.walletName}"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleWebPaymentSuccess(dynamic paymentId, dynamic orderId, dynamic signature) async {
    final res = await ApiService.bookAppointment(
      patientEmail: patientEmail,
      patientName: patientName,
      doctorName: widget.doctorName,
      specialization: widget.specialization,
      hospitalName: widget.hospitalName,
      appointmentSlot: _selectedSlot,
      paymentMethod: _selectedPayment,
      consultationFee: widget.fee,
      appointmentDate: formattedDate,
    );

    if (!mounted) return;

    setState(() {
      _isBooking = false;
    });

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Successful"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _bookingConfirmed = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["error"] ?? "Booking failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleWebPaymentDismiss() {
    if (!mounted) return;
    setState(() {
      _isBooking = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment Cancelled"),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primary,
              onPrimary: Colors.white,
              surface: primaryBg,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _selectedSlot = ''; // Reset selected slot on new date
      });
      fetchBookedSlots();
    }
  }

  Future<void> fetchBookedSlots() async {
    final slots = await ApiService.getBookedSlots(
      doctorName: widget.doctorName,
      appointmentDate: formattedDate,
    );
    setState(() {
      bookedSlots = List.from(slots);
    });
  }

  // Removed duplicate pickDate() implementation (kept the earlier one with theme builder)
  Future<void> loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      patientEmail = prefs.getString("user_email") ?? "";

      patientName = prefs.getString("user_name") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: _bookingConfirmed
            ? _buildSuccessScreen(context)
            : _buildBookingScreen(context),
      ),
    );
  }

  // ── Booking screen ────────────────────────
  Widget _buildBookingScreen(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        _buildDoctorBanner(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(),
                const SizedBox(height: 20),
                _buildSlotSelector(),
                const SizedBox(height: 20),
                _buildPaymentSection(),
                const SizedBox(height: 20),
                _buildSummaryCard(),
                const SizedBox(height: 24),
                _buildConfirmButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: primaryBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: primary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Book appointment',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Doctor banner ─────────────────────────
  Widget _buildDoctorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: primary,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white38, width: 1.5),
            ),
            child: Center(
              child: Text(widget.doctorName.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          Text(widget.doctorName,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(widget.specialization,
              style: const TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text('Verified doctor',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info section ──────────────────────────
  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          _infoRow(
              Icons.local_hospital_rounded, 'Hospital', widget.hospitalName),
          _divider(),
          GestureDetector(
            onTap: pickDate,
            child: _infoRow(
              Icons.calendar_today_rounded,
              'Date',
              formattedDate,
            ),
          ),
          _divider(),
          _infoRow(Icons.payments_rounded, 'Consultation fee', widget.fee,
              valueColor: const Color(0xFF1D9E75)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 16),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.white54)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.white)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      height: 0.5,
      color: borderColor,
      margin: const EdgeInsets.symmetric(horizontal: 16));

  // ── Slot selector ─────────────────────────
  Widget _buildSlotSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select time slot',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.0,
          children: _allSlots.map((slot) {
            final isBooked = bookedSlots.contains(slot);
            final isPast = isPastSlot(slot);
            final selected = _selectedSlot == slot;
            return GestureDetector(
              onTap: () {
                if (isBooked || isPast) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isPast
                            ? "This time slot already passed"
                            : "Slot already booked",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );

                  return;
                }

                setState(() {
                  _selectedSlot = slot;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isBooked
                      ? Colors.red.withValues(alpha: 0.2)
                      : isPast
                          ? Colors.grey.withValues(alpha: 0.3)
                          : selected
                              ? primary
                              : const Color(0xFF1A2A22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isBooked
                        ? Colors.red
                        : isPast
                            ? Colors.grey
                            : selected
                                ? primary
                                : const Color(0xFF1D9E75),
                    width: selected ? 1.5 : 0.5,
                  ),
                ),
                child: Center(
                  child: Text(slot,
                      style: TextStyle(
                        fontSize: 10,
                        color: isBooked
                            ? Colors.red
                            : isPast
                                ? Colors.grey
                                : selected
                                    ? Colors.white
                                    : const Color(0xFF1D9E75),
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      )),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Payment section ───────────────────────
  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment method',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 12),
        Row(
          children: _paymentModes.map((mode) {
            final selected = _selectedPayment == mode;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPayment = mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                      right: mode != _paymentModes.last ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? primary : cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? primary : borderColor,
                      width: selected ? 1.5 : 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        mode == 'UPI'
                            ? Icons.account_balance_wallet_rounded
                            : mode == 'Card'
                                ? Icons.credit_card_rounded
                                : Icons.money_rounded,
                        color: selected ? Colors.white : Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(mode,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected ? Colors.white : Colors.white54,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1D9E75), width: 0.5),
      ),
      child: Column(
        children: [
          _summaryRow('Selected slot', _selectedSlot),
          const SizedBox(height: 8),
          _summaryRow('Payment mode', _selectedPayment),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFF1D9E75), height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total amount',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text(widget.fee,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D9E75))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white54)),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }

  // ── Confirm button ────────────────────────
  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isBooking
            ? null
            : () async {
                if (_selectedSlot.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a time slot first.")),
                  );
                  return;
                }

                setState(() {
                  _isBooking = true;
                });

                if (kIsWeb) {
                  // First create Razorpay order from our backend
                  final orderRes = await ApiService.createRazorpayOrder(widget.fee);
                  if (orderRes["success"] == true) {
                    final orderId = orderRes["order_id"];
                    openRazorpayWebCheckout(
                      fee: widget.fee,
                      doctorName: widget.doctorName,
                      orderId: orderId,
                      patientEmail: patientEmail,
                      onSuccess: (paymentId, orderId, signature) {
                        _handleWebPaymentSuccess(paymentId, orderId, signature);
                      },
                      onDismiss: () {
                        _handleWebPaymentDismiss();
                      },
                    );
                  } else {
                    setState(() {
                      _isBooking = false;
                    });
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(orderRes["error"] ?? "Failed to create order")),
                    );
                  }
                  return;
                }

                // First create Razorpay order from our backend
                final orderRes = await ApiService.createRazorpayOrder(widget.fee);
                if (orderRes["success"] == true) {
                  final orderId = orderRes["order_id"];
                  
                  // Clean fee string if it has symbols like '₹' or ','
                  String amountStr = widget.fee.replaceAll('₹', '').replaceAll(',', '').trim();
                  double amount = double.tryParse(amountStr) ?? 0;

                  var options = {
                    'key': 'rzp_test_T3R0IL2TZZC1Gl',
                    'amount': (amount * 100).toInt(),
                    'name': 'MediConnect',
                    'description': 'Consultation with ${widget.doctorName}',
                    'order_id': orderId,
                    'prefill': {
                      'contact': '7036092357', // Provide if you have phone number
                      'email': patientEmail
                    },
                    'method': {
                      'upi': true,
                      'card': true,
                      'netbanking': true,
                      'wallet': true,
                    }
                  };

                  try {
                    _razorpay.open(options);
                  } catch (e) {
                    print('Error launching Razorpay: $e');
                    setState(() {
                      _isBooking = false;
                    });
                  }
                } else {
                  setState(() {
                    _isBooking = false;
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(orderRes["error"] ?? "Failed to create order")),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isBooking
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Confirm & pay ${widget.fee}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  // ── Success screen ────────────────────────
  Widget _buildSuccessScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration:
                  const BoxDecoration(color: primary, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 42),
            ),
            const SizedBox(height: 20),
            const Text('Appointment booked!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'Your appointment with ${widget.doctorName} is confirmed.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: Colors.white54, height: 1.5),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Column(
                children: [
                  _confirmRow(
                      Icons.person_rounded, 'Doctor', widget.doctorName),
                  const SizedBox(height: 10),
                  _confirmRow(Icons.local_hospital_rounded, 'Hospital',
                      widget.hospitalName),
                  const SizedBox(height: 10),
                  _confirmRow(Icons.access_time_rounded, 'Slot', _selectedSlot),
                  const SizedBox(height: 10),
                  _confirmRow(Icons.payments_rounded, 'Amount', widget.fee),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.settings.name == '/patient_dashboard' || route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back to dashboard',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white54)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }
}

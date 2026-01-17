import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/// ===============================
/// 🔐 OTP FUNCTIONS
/// ===============================

/// SAVE OTP TO FIRESTORE
Future<void> saveOtpToFirestore(String email, String otp) async {
  try {
    await _firestore.collection('otp_requests').doc(email).set({
      'otp': otp,
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 15)),
      ),
      'createdAt': Timestamp.now(),
    });
  } catch (e) {
    throw Exception('Failed to save OTP');
  }
}

/// VERIFY OTP FROM FIRESTORE
Future<bool> verifyOtpFromFirestore(String email, String enteredOtp) async {
  try {
    final doc = await _firestore.collection('otp_requests').doc(email).get();

    if (!doc.exists) return false;

    final data = doc.data();
    if (data == null) return false;

    final storedOtp = data['otp'];
    final expiresAt = data['expiresAt'] as Timestamp?;

    if (storedOtp == null || expiresAt == null) return false;

    // CHECK EXPIRATION
    if (DateTime.now().isAfter(expiresAt.toDate())) {
      return false;
    }

    return enteredOtp == storedOtp;
  } catch (e) {
    return false;
  }
}

/// DELETE OTP AFTER SUCCESS
Future<void> deleteOtp(String email) async {
  try {
    await _firestore.collection('otp_requests').doc(email).delete();
  } catch (e) {
    // safe ignore
  }
}

/// ===============================
/// 🌊 WATER LEVEL HISTORY LOGGING
/// ===============================

/// SAVE WATER LEVEL DATA TO FIRESTORE
Future<void> logWaterHistory({
  required double current,
  required double predicted,
  required String status,
}) async {
  try {
    await _firestore.collection('water_history').add({
      'current': current,
      'predicted': predicted,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Firestore water_history error: $e');
  }
}

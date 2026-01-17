import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHistoryService {
  // Explicit type (best practice)
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> saveWaterHistory({
    required double current,
    required double predicted,
    required String status,
  }) async {
    await _db.collection('water_history').add({
      'currentLevel': current,
      'predictedLevel': predicted,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/firestore_history_service.dart';
import '../services/notification_service.dart';

class Life360Dashboard extends StatefulWidget {
  const Life360Dashboard({super.key});

  @override
  State<Life360Dashboard> createState() => _Life360DashboardState();
}

class _Life360DashboardState extends State<Life360Dashboard> {
  // 🔥 Firebase node (MATCH SA RASPBERRY PI)
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref("water_level");

  double current = 0.0;     // meters
  double predicted = 0.0;   // meters
  int eta = 5;

  String status = "NORMAL";
  String previousStatus = "NORMAL"; // ⭐ IMPORTANT (anti-spam)

  @override
  void initState() {
    super.initState();
    listenToWaterLevel();
  }

  // 📡 REAL-TIME LISTENER + PUSH NOTIFICATION TRIGGER
  void listenToWaterLevel() {
    _dbRef.onValue.listen((event) {
      if (!event.snapshot.exists) return;

      final data =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      final newStatus = (data["status"] ?? "NORMAL").toString();

      setState(() {
        // 🔁 cm → meters
        current =
            ((data["distance_cm"] ?? 0) as num).toDouble() / 100.0;

        predicted =
            ((data["predicted_distance_cm"] ?? 0) as num)
                .toDouble() /
            100.0;

        status = newStatus;
      });

      // 🔔 TRIGGER NOTIFICATION ONLY WHEN STATUS CHANGES
      if (newStatus != previousStatus &&
          (newStatus == "WARNING" ||
              newStatus == "HIGH_RISK" ||
              newStatus == "EVACUATION")) {
        NotificationService.showLocalAlert(newStatus);
      }

      previousStatus = newStatus;

      // 🔥 OPTIONAL: SAVE HISTORY TO FIRESTORE
      FirestoreHistoryService.saveWaterHistory(
        current: current,
        predicted: predicted,
        status: status,
      );
    });
  }

  // 🎨 STATUS HELPERS
  Color getStatusColor() {
    switch (status) {
      case "EVACUATION":
        return const Color(0xFFD32F2F);
      case "HIGH_RISK":
        return const Color(0xFFF57C00);
      case "WARNING":
        return const Color(0xFFFBC02D);
      default:
        return const Color(0xFF43A047);
    }
  }

  String getStatusText() {
    switch (status) {
      case "EVACUATION":
        return "Evacuation required immediately";
      case "HIGH_RISK":
        return "High risk – Prepare to evacuate";
      case "WARNING":
        return "Warning – Stay alert";
      default:
        return "Safe – Normal river condition";
    }
  }

  IconData getStatusIcon() {
    switch (status) {
      case "EVACUATION":
        return Icons.error_outline_rounded;
      case "HIGH_RISK":
        return Icons.trending_up;
      case "WARNING":
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle_outline;
    }
  }

  // 🚨 ACTION RECOMMENDATIONS
  List<String> getRecommendations() {
    switch (status) {
      case "EVACUATION":
        return [
          "Evacuate immediately to higher ground",
          "Bring emergency kit and important documents",
          "Follow barangay evacuation routes",
          "Stay updated through official alerts",
        ];
      case "HIGH_RISK":
        return [
          "Prepare emergency supplies",
          "Secure valuables and appliances",
          "Monitor water level closely",
          "Be ready for evacuation",
        ];
      case "WARNING":
        return [
          "Stay alert and monitor updates",
          "Prepare emergency kit",
          "Avoid riverbanks",
        ];
      default:
        return [
          "Normal river condition",
          "Stay informed for updates",
          "Maintain household preparedness",
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF5F7FF), Color(0xFFE7EBFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "ALERTify",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Barangay Ganado • Silang–Sta. Rosa River",
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: statusColor.withOpacity(0.15),
                    child: Icon(getStatusIcon(), color: statusColor),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // MAIN STATUS CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF928CFF)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(getStatusIcon(),
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "${current.toStringAsFixed(2)} m",
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      getStatusText(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // MINI CARDS
              Row(
                children: [
                  Expanded(
                    child: _miniCard(
                      icon: Icons.show_chart,
                      title: "Predicted level",
                      value: "${predicted.toStringAsFixed(2)} m",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _miniCard(
                      icon: Icons.schedule,
                      title: "ETA to peak",
                      value: "$eta min",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ACTION RECOMMENDATIONS
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Action Recommendations",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...getRecommendations().map(
                        (item) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.circle,
                                  size: 8, color: statusColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style:
                                      const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MINI CARD
  Widget _miniCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigo.withOpacity(0.1),
              child: Icon(icon, color: Colors.indigo),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

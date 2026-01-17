import 'package:flutter/material.dart';
import '../widgets/dashboard_content.dart';
import 'user_account_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: const SizedBox(), // no back button
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserAccountScreen()),
              );
            },
          ),
        ],
      ),
      body: const Life360Dashboard(),
    );
  }
}

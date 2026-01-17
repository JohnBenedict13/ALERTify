import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool isLoading = false;
  String error = '';

  Future<void> createPassword() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password.length < 6) {
      setState(() => error = 'Password must be at least 6 characters');
      return;
    }

    if (password != confirm) {
      setState(() => error = 'Passwords do not match');
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final email = user.email!;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // 🔗 LINK PASSWORD TO GOOGLE ACCOUNT
      await user.linkWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      setState(() => error = 'Failed to create password');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Set a password for your account',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'New password'),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Confirm password'),
            ),

            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error, style: const TextStyle(color: Colors.red)),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : createPassword,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Password'),
            ),
          ],
        ),
      ),
    );
  }
}

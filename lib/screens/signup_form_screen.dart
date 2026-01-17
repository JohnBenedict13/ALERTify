import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_form_screen.dart';

class SignUpFormScreen extends StatefulWidget {
  const SignUpFormScreen({super.key});

  @override
  State<SignUpFormScreen> createState() => _SignUpFormScreenState();
}

class _SignUpFormScreenState extends State<SignUpFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  String message = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // BASIC VALIDATION
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _setMessage('Please fill in all fields', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _setMessage('Passwords do not match', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      // CREATE ACCOUNT
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // SEND EMAIL VERIFICATION
      await userCredential.user!.sendEmailVerification();

      // SAVE USER TO FIRESTORE
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'fullName': name,
            'email': email,
            'createdAt': Timestamp.now(),
            'emailVerified': false,
          });

      // SIGN OUT (IMPORTANT)
      await FirebaseAuth.instance.signOut();

      _setMessage('Account created successfully.', isError: false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _setMessage('This email is already registered.', isError: true);
      } else if (e.code == 'invalid-email') {
        _setMessage('Invalid email address.', isError: true);
      } else if (e.code == 'weak-password') {
        _setMessage('Password must be at least 6 characters.', isError: true);
      } else {
        _setMessage(
          'Failed to create account. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _setMessage(String text, {required bool isError}) {
    setState(() {
      message = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = message.contains('successfully');

    return Scaffold(
      backgroundColor: const Color(0xFF9C8CF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C8CF2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              _buildInputField(controller: _nameController, hint: 'Full name'),
              const SizedBox(height: 12),

              _buildInputField(controller: _emailController, hint: 'Email'),
              const SizedBox(height: 12),

              _buildInputField(
                controller: _passwordController,
                hint: 'Password',
                obscure: true,
              ),
              const SizedBox(height: 12),

              _buildInputField(
                controller: _confirmPasswordController,
                hint: 'Confirm password',
                obscure: true,
              ),

              const SizedBox(height: 18),

              if (message.isNotEmpty)
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSuccess ? Colors.black : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: isLoading ? null : signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Sign Up'),
                ),
              ),

              const SizedBox(height: 25),

              // ✅ Only "Sign In" is clickable & red
              RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Sign In here',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginFormScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

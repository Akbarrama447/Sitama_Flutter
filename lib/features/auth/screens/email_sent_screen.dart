import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'reset_password_screen.dart';

class EmailSentScreen extends StatelessWidget {
  final String email;
  const EmailSentScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logo.png", width: 120),
                const SizedBox(height: 10),
                const Text(
                  "S I T A M A",
                  style: TextStyle(
                    fontSize: 22,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  "Link untuk melakukan reset password telah\ndikirim ke email:",
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                Text(email),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ResetPasswordScreen()),
                    );
                  },
                  child: const Text("Lanjut"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

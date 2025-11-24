import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'email_sent_screen.dart';

class ForgotNimScreen extends StatefulWidget {
  const ForgotNimScreen({super.key});

  @override
  State<ForgotNimScreen> createState() => _ForgotNimScreenState();
}

class _ForgotNimScreenState extends State<ForgotNimScreen> {
  final TextEditingController nimController = TextEditingController();

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

                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("NIM (tanpa titik)")),
                const SizedBox(height: 4),
                TextField(
                  controller: nimController,
                  decoration: InputDecoration(
                    hintText: "Masukkan NIM",
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmailSentScreen(
                            email: "suk***asp@gmail.com", // dari backend nanti
                          ),
                        ),
                      );
                    },
                    child: const Text("Konfirmasi"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

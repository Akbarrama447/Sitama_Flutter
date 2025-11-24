import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'reset_success_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool hide1 = true;
  bool hide2 = true;

  final pass = TextEditingController();
  final confirm = TextEditingController();

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
                    child: Text("Password")),
                const SizedBox(height: 4),
                TextField(
                  obscureText: hide1,
                  controller: pass,
                  decoration: InputDecoration(
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon:
                          Icon(hide1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => hide1 = !hide1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Konfirmasi Password")),
                const SizedBox(height: 4),
                TextField(
                  obscureText: hide2,
                  controller: confirm,
                  decoration: InputDecoration(
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon:
                          Icon(hide2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => hide2 = !hide2),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (pass.text == confirm.text) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ResetSuccessScreen()),
                        );
                      }
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

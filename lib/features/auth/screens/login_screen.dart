import 'package:flutter/material.dart';

// 1. COLORS (Sudah Benar & Terbukti Jalan)
import 'package:sitama/core/theme/colors.dart';

// 2. DASHBOARD (INI YANG BIKIN ERROR TADI)
// Penjelasan Perbaikan:
// Posisi file ini: lib/features/auth/screens/login_screen.dart
// Mundur 1 (../)  => masuk ke folder 'auth'
// Mundur 2 (../../) => masuk ke folder 'features'
// Di dalam folder 'features' inilah ada folder 'dashboard'.
// Jadi cukup mundur 2 kali saja.
import '../../dashboard/screens/dashboard_screen.dart';

// 3. GRADIENT BACKGROUND (Sudah Benar)
import '../widgets/gradient_background.dart';

// 4. FORGOT PASSWORD (Sudah Benar)
import 'forgot_nim_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset("assets/logo.png", width: 120),
                  const SizedBox(height: 10),
                  const Text(
                    "S I T A M A",
                    style: TextStyle(
                      fontSize: 22,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      // Menggunakan AppColors dari colors.dart
                      color: AppColors.primary, 
                    ),
                  ),
                  const SizedBox(height: 40),

                  // EMAIL
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Alamat Email")),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Alamat Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PASSWORD
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Password")),
                  const SizedBox(height: 4),
                  TextField(
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      hintText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                            hidePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  // REMEMBER + FORGET
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (val) {
                              setState(() => rememberMe = val!);
                            },
                          ),
                          const Text("Ingat Saya"),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotNimScreen()),
                          );
                        },
                        child: const Text("Lupa password?"),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // BUTTON LOGIN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DashboardScreen()),
                        );
                      },
                      child: const Text("Masuk"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
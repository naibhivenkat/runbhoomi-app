import 'dart:async';
import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';
import '../services/session_service.dart'; 
import '../widgets/auth_button.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool loading = false;
  bool obscure = true;
  bool _disposed = false;

  int step = 0;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  int seconds = 30;
  Timer? timer;

void startTimer() {
  timer?.cancel();

  if (!mounted || _disposed) return;

  setState(() => seconds = 30);

  timer = Timer.periodic(const Duration(seconds: 1), (t) {
    if (!mounted || _disposed) {
      t.cancel();
      return;
    }

    if (seconds <= 1) {
      t.cancel();
      setState(() => seconds = 0);
    } else {
      setState(() => seconds--);
    }
  });
}

  String getOtp() {
    return otpControllers.map((e) => e.text).join();
  }



  Future login() async {
  if (!mounted || _disposed) return;

  setState(() => loading = true);

  try {
    final res = await ApiService.login(
      emailController.text,
      passwordController.text,
    );

    await SessionService.saveUser(
      emailController.text.trim(),
      res["token"],
      userId: res["user_id"],
    );

    if (!mounted || _disposed) return;

    ApiService.token = res["token"];

    Navigator.pushReplacementNamed(context, "/home");

  } catch (e) {
    if (!mounted || _disposed) return;
    showError("Invalid email or password");

  } finally {
    if (!mounted || _disposed) return;
    setState(() => loading = false);
  }
}



  Future sendOtp() async {
  if (emailController.text.isEmpty) {
    showError("Enter email");
    return;
  }

  if (!mounted || _disposed) return;

  setState(() => loading = true);

  try {
    await ApiService.loginOtp(emailController.text);

    if (!mounted || _disposed) return;

    setState(() => step = 1);

    startTimer();

    showError("OTP sent");

  } catch (e) {
    if (!mounted || _disposed) return;
    showError("Failed to send OTP");

  } finally {
    if (!mounted || _disposed) return;
    setState(() => loading = false);
  }
}

  // ================= VERIFY OTP =================
  Future verifyOtp() async {
  if (!mounted || _disposed) return;

  setState(() => loading = true);

  try {
    final res = await ApiService.verifyLoginOtp(
      emailController.text,
      getOtp(),
    );

    await SessionService.saveUser(
      emailController.text.trim(),
      res["token"],
      userId: res["user_id"],
    );

    if (!mounted || _disposed) return;

    ApiService.token = res["token"];

    Navigator.pushReplacementNamed(context, "/home");

  } catch (e) {
    if (!mounted || _disposed) return;
    showError("Invalid OTP");
    clearOtp();

  } finally {
    if (!mounted || _disposed) return;
    setState(() => loading = false);
  }
}

  void clearOtp() {
    for (var c in otpControllers) {
      c.clear();
    }
    otpFocusNodes[0].requestFocus();
  }

  // ================= GOOGLE LOGIN =================
//   Future googleLogin() async {
//   if (!mounted || _disposed) return;

//   setState(() => loading = true);

//   try {
//     final idToken = await GoogleAuthService.signIn();

//     if (!mounted || _disposed) return;

//     final res = await ApiService.googleLogin(idToken!);

//     if (!mounted || _disposed) return;

//     final email = res["user"]["email"];

//     if (email == null || email.toString().isEmpty) {
//       showError("Email not returned from Google login");
//       return;
//     }

//     await SessionService.saveUser(
//       email,
//       res["token"],
//       userId: res["user"]["id"],
//     );

//     if (!mounted || _disposed) return;

//     ApiService.token = res["token"];

//     Navigator.pushReplacementNamed(context, "/home");

//   } catch (e) {
//     if (!mounted || _disposed) return;
//     showError("Google login failed");

//   } finally {
//     if (!mounted || _disposed) return;
//     setState(() => loading = false);
//   }
// }



// ================= GOOGLE LOGIN =================
  Future googleLogin() async {
    if (!mounted || _disposed) return;

    setState(() => loading = true);

    try {
      final idToken = await GoogleAuthService.signIn();

      if (idToken == null) {
        setState(() => loading = false);
        return; // User canceled the login dialog
      }

      if (!mounted || _disposed) return;

      final res = await ApiService.googleLogin(idToken);

      if (!mounted || _disposed) return;

      // 🔥 DEBUG PRINT: See exactly what the backend returned
      debugPrint("✅ Google Login API Response: $res");

      // 🔥 FAIL-SAFE PARSING: Handles both nested {"user": {"email": "..."}} and flat {"email": "..."} responses
      final email = res["user"]?["email"] ?? res["email"];
      final userId = res["user"]?["id"] ?? res["user_id"] ?? res["id"];
      final token = res["token"] ?? res["access_token"];

      if (email == null || email.toString().isEmpty) {
        showError("Email not returned from backend");
        return;
      }

      if (token == null) {
        showError("Token not returned from backend");
        return;
      }

      await SessionService.saveUser(
        email.toString().trim(),
        token.toString(),
        userId: userId?.toString() ?? "",
      );

      if (!mounted || _disposed) return;

      ApiService.token = token.toString();

      Navigator.pushReplacementNamed(context, "/home");

    } catch (e, stacktrace) {
      if (!mounted || _disposed) return;
      
      // 🔥 PRINT THE ACTUAL ERROR TO THE CONSOLE
      debugPrint("❌ Google Login Crash: $e");
      debugPrint("❌ Stacktrace: $stacktrace");
      
      showError("Google login failed. Check console.");

    } finally {
      if (!mounted || _disposed) return;
      setState(() => loading = false);
    }
  }




  void showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: ListView(
            children: [

              const SizedBox(height: 40),

              Column(
                children: const [
                  Icon(Icons.sports_cricket, size: 60),
                  SizedBox(height: 10),
                  Text(
                    "RunBhoomi",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Cricket Starts Here"),
                ],
              ),

              const SizedBox(height: 40),

              if (step == 0) ...[

                AuthTextField(
                  controller: emailController,
                  hint: "Email",
                  icon: Icons.email,
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() => obscure = !obscure);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/forgot");
                    },
                    child: const Text("Forgot Password?"),
                  ),
                ),

                const SizedBox(height: 10),

                AuthButton(
                  text: loading ? "Loading..." : "Login",
                  onPressed: loading ? () {} : login,
                ),

                const SizedBox(height: 16),

                AuthButton(
                  text: "Login with OTP",
                  color: Colors.white,
                  textColor: AppColors.primary,
                  border: true,
                  onPressed: loading ? () {} : sendOtp,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (step == 1) ...[

                AuthTextField(
                  controller: emailController,
                  hint: "Email",
                  icon: Icons.email,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {

                    return SizedBox(
                      width: 45,

                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: otpFocusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,

                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        onChanged: (value) {

                          if (value.isNotEmpty && index < 5) {
                            otpFocusNodes[index + 1].requestFocus();
                          }

                          if (value.isEmpty && index > 0) {
                            otpFocusNodes[index - 1].requestFocus();
                          }

                          if (getOtp().length == 6) {
                            verifyOtp();
                          }
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                AuthButton(
                  text: loading ? "Verifying..." : "Verify OTP",
                  onPressed: loading ? () {} : verifyOtp,
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: seconds == 0 ? sendOtp : null,
                  child: Text(
                    seconds == 0
                        ? "Resend OTP"
                        : "Resend in $seconds s",
                  ),
                ),

                TextButton(
                  onPressed: () {
                    setState(() => step = 0);
                  },
                  child: const Text("Back to Login"),
                ),
              ],

              const SizedBox(height: 30),

              if (step == 0) ...[
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 30),

                SocialLoginButton(
                  icon: Icons.g_mobiledata,
                  text: "Continue with Google",
                  onPressed: googleLogin,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
void dispose() {
  _disposed = true;
  timer?.cancel();
  super.dispose();
  for (var c in otpControllers) {
  c.dispose();
}

for (var f in otpFocusNodes) {
  f.dispose();
}
}

}



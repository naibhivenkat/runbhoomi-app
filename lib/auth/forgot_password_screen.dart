import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../core/colors.dart';
import '../services/api_service.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_textfield.dart';

/// ================= OTP TIMER =================
class OtpTimer extends StatelessWidget {
  final int seconds;
  final int total;
  final VoidCallback onResend;

  const OtpTimer({
    super.key,
    required this.seconds,
    required this.total,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    double progress = seconds / total;

    return Column(
      children: [
        SizedBox(
          height: 70,
          width: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  Color.lerp(Colors.red, Colors.blue, progress)!,
                ),
              ),
              Text(
                "$seconds",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: seconds == 0 ? onResend : null,
          child: Text(
            seconds == 0 ? "Resend OTP" : "Wait to resend",
            style: TextStyle(
              color: seconds == 0 ? Colors.blue : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// ================= SCREEN =================
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {

  int step = 0;
  bool loading = false;
  bool obscure = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final otpControllers =
      List.generate(6, (_) => TextEditingController());

  final focusNodes =
      List.generate(6, (_) => FocusNode());

  int seconds = 30;
  Timer? timer;

  late AnimationController shakeController;

  @override
  void initState() {
    super.initState();

    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    listenOtp(); // 🔥 auto OTP
  }

  /// ================= AUTO OTP =================
  void listenOtp() async {
    await SmsAutoFill().listenForCode;

    SmsAutoFill().code.listen((code) {
      if (code.length == 6) {
        fillOtp(code);
      }
    });
  }

  void fillOtp(String code) {
    for (int i = 0; i < 6; i++) {
      otpControllers[i].text = code[i];
    }

    FocusScope.of(context).unfocus();
    verifyOtp();
  }

  /// ================= TIMER =================
  void startTimer() {
    timer?.cancel();

    setState(() => seconds = 30);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds <= 1) {
        t.cancel();
        setState(() => seconds = 0);
      } else {
        setState(() => seconds--);
      }
    });
  }

  String getOtp() =>
      otpControllers.map((e) => e.text).join();

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /// ================= SEND OTP =================
  Future sendOtp() async {
    setState(() => loading = true);

    try {
      await ApiService.forgotOtp(emailController.text);
      setState(() => step = 1);
      startTimer();
      showMsg("OTP sent");
    } catch (e) {
      showMsg("Failed");
    } finally {
      setState(() => loading = false);
    }
  }

  /// ================= VERIFY OTP =================
  Future verifyOtp() async {
    setState(() => loading = true);

    try {
      await ApiService.verifyForgotOtp(
        emailController.text,
        getOtp(),
      );

      setState(() => step = 2);
    } catch (e) {
      HapticFeedback.mediumImpact(); // 🔥 vibration
      shakeController.forward(from: 0);
      showMsg("Invalid OTP");
      clearOtp();
    } finally {
      setState(() => loading = false);
    }
  }

  void clearOtp() {
    for (var c in otpControllers) {
      c.clear();
    }
    focusNodes[0].requestFocus();
  }

  /// ================= PASSWORD =================
  int passwordStrength() {
    String p = passwordController.text;

    if (p.length < 6) return 0;
    if (p.length < 8) return 1;
    if (RegExp(r'[A-Z]').hasMatch(p) &&
        RegExp(r'[0-9]').hasMatch(p)) return 3;

    return 2;
  }

  Color strengthColor() {
    switch (passwordStrength()) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String strengthText() {
    switch (passwordStrength()) {
      case 0:
        return "Weak";
      case 1:
        return "Okay";
      case 2:
        return "Good";
      case 3:
        return "Strong";
      default:
        return "";
    }
  }

  /// ================= RESET =================
  Future resetPassword() async {
    setState(() => loading = true);

    try {
      await ApiService.resetPassword(
        emailController.text,
        passwordController.text,
      );

      showMsg("Password reset successful");
      Navigator.pop(context);

    } catch (e) {
      showMsg("Failed");
    } finally {
      setState(() => loading = false);
    }
  }

  /// ================= OTP BOX =================
  Widget otpBox(int i) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focusNodes[i].hasFocus
              ? Colors.blue
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: TextField(
        controller: otpControllers[i],
        focusNode: focusNodes[i],
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),

        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],

        onChanged: (v) {
          // 🔥 paste full OTP
          if (v.length > 1) {
            fillOtp(v);
            return;
          }

          if (v.isNotEmpty && i < 5) {
            focusNodes[i + 1].requestFocus();
          }

          if (v.isEmpty && i > 0) {
            focusNodes[i - 1].requestFocus();
          }

          if (getOtp().length == 6) {
            verifyOtp();
          }
        },
      ),
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Reset Password"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),

          child: Column(
            key: ValueKey(step),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              const Center(
                child: Icon(Icons.lock_reset, size: 60),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "Forgot Password",
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              if (step == 0) ...[
                AuthTextField(
                  controller: emailController,
                  hint: "Email",
                  icon: Icons.email,
                ),
                const SizedBox(height: 25),
                AuthButton(
                  text: "Send OTP",
                  loading: loading,
                  onPressed: sendOtp,
                ),
              ],

              if (step == 1) ...[
                const Text("Enter OTP"),
                const SizedBox(height: 20),

                AnimatedBuilder(
                  animation: shakeController,
                  builder: (context, child) {
                    double offset =
                        (shakeController.value - 0.5) * 20;
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children:
                        List.generate(6, (i) => otpBox(i)),
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: OtpTimer(
                    seconds: seconds,
                    total: 30,
                    onResend: sendOtp,
                  ),
                ),
              ],

              if (step == 2) ...[
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "New Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscure
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() => obscure = !obscure);
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: passwordStrength() / 3,
                        color: strengthColor(),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      strengthText(),
                      style: TextStyle(color: strengthColor()),
                    )
                  ],
                ),

                const SizedBox(height: 25),

                AuthButton(
                  text: "Reset Password",
                  loading: loading,
                  onPressed: resetPassword,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// ================= DISPOSE =================
  @override
  void dispose() {
    timer?.cancel();
    shakeController.dispose();
    SmsAutoFill().unregisterListener(); // 🔥 important
    super.dispose();
  }
}
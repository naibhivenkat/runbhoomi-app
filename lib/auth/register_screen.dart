import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../services/api_service.dart';
import '../screens/home/map_picker_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class RegisterFlow extends StatefulWidget {
  const RegisterFlow({super.key});

  @override
  State<RegisterFlow> createState() => _RegisterFlowState();
}

class _RegisterFlowState extends State<RegisterFlow> {
  int step = 0;

  /// DATA
  String email = "";
  String gender = "";
  DateTime? dob;

  final nameController = TextEditingController();
  final cityController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  bool obscurePass = true;
  bool obscureConfirm = true;

  String? role;
  String? battingStyle;
  String? bowlingStyle;
  bool _disposed = false;

  final List<Timer> _delayedTimers = [];

  double? lat;
  double? lng;
  File? imageFile;

  /// VALIDATION
  bool showErrors = false;

  /// OTP
  List<TextEditingController> otp =
      List.generate(6, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  int timer = 30;
  Timer? otpTimer;

  /// ================= TIMER =================
void startTimer() {
  otpTimer?.cancel();

  if (!mounted || _disposed) return;

  setState(() => timer = 30);

  otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
    if (!mounted || _disposed) {
      t.cancel();
      return;
    }

    if (timer <= 1) {
      t.cancel();
      setState(() => timer = 0);
    } else {
      setState(() => timer--);
    }
  });
}
  String getOtp() => otp.map((e) => e.text).join();

  /// ================= IMAGE =================
  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final compressed = await FlutterImageCompress.compressWithFile(
      picked.path,
      quality: 60,
    );

    setState(() {
      imageFile = File(picked.path)
        ..writeAsBytesSync(compressed!);
    });
  }

  /// ================= LOCATION =================
  Future pickLocation() async {
    await Permission.location.request();
    if (!mounted) return;

    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        cityController.text = result["address"];
        lat = result["lat"];
        lng = result["lng"];
      });
    }
  }

  /// ================= API =================
  Future sendOtp() async {
    var res = await ApiService.sendOtp(email);
    showMsg(res["message"]);

    if (res["status"] == "success") {
      startTimer();
      next();
    }
  }

  Future verifyOtp() async {
    var res = await ApiService.verifyOtp(email, getOtp());
    if (!mounted) return;

    if (res["status"] == "success") {
      next();
    } else {
      showMsg(res["message"]);
    }
  }

  Future register() async {
    setState(() => showErrors = true);

    if (nameController.text.isEmpty ||
        cityController.text.isEmpty ||
        role == null ||
        battingStyle == null ||
        bowlingStyle == null) {
      showMsg("Please complete all required fields");
      return;
    }

    var res = await ApiService.registerPlayer({
      "email": email,
      "name": nameController.text,
      "city": cityController.text,
      "lat": lat,
      "lng": lng,
      "phone": phoneController.text,
      "gender": gender,
      "password": passwordController.text,
      "dob": dob?.toIso8601String(),
      "role": role,
      "batting_style": battingStyle,
      "bowling_style": bowlingStyle,
      "profile_photo": imageFile?.path
    });
    if (!mounted) return;

    showMsg(res["message"]);

    if (res["status"] == "success") {
      Navigator.pop(context);
    }
  }

  void showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void next() => setState(() => step++);

  /// ================= UI BASE =================
  Widget screenWrapper(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff0f2027), Color(0xff203a43), Color(0xff2c5364)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// ================= STEPS =================

  Widget emailStep() {
    final controller = TextEditingController();

    return screenWrapper(Column(
      children: [
        title("Welcome to RunBhoomi"),
        input(controller, "Enter Email"),

        button("Send OTP", () {
          email = controller.text;
          sendOtp();
        })
      ],
    ));
  }



Widget otpStep() {
  bool isComplete = getOtp().length == 6;

  return screenWrapper(Column(
    children: [
      title("Verify OTP"),

      const SizedBox(height: 10),

      Text(
        "Sent to $email",
        style: const TextStyle(color: Colors.white70),
      ),

      const SizedBox(height: 20),

      /// COUNTDOWN
      LinearProgressIndicator(
        value: timer / 30,
        minHeight: 4,
        backgroundColor: Colors.white10,
        valueColor: AlwaysStoppedAnimation<Color>(
          timer < 10 ? Colors.red : Colors.orange,
        ),
      ),

      const SizedBox(height: 25),

      /// OTP BOXES
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 12,
        children: List.generate(6, (i) {
          bool isFocused = focusNodes[i].hasFocus;

          return SizedBox(
            width: 45,
            child: Container( 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.6),
                          blurRadius: 10,
                        )
                      ]
                    : [],
              ),
              child: TextField(
                controller: otp[i],
                focusNode: focusNodes[i],
                keyboardType: TextInputType.number,
                textInputAction:
                    i == 5 ? TextInputAction.done : TextInputAction.next,

                onChanged: (v) {
                  if (!mounted) return; // ✅ SAFE

                  setState(() {});

                  if (v.isNotEmpty) {
                    if (i < 5) {
                      FocusScope.of(context)
                          .requestFocus(focusNodes[i + 1]);
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                  } else {
                    if (i > 0) {
                      FocusScope.of(context)
                          .requestFocus(focusNodes[i - 1]);
                    }
                  }
                },

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),

                textAlign: TextAlign.center,
                maxLength: 1,

                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white10,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Colors.orange, width: 2),
                  ),
                ),
              ),
            ),
          );
        }),
      ),

      const SizedBox(height: 20),

      /// RESEND
      GestureDetector(
        onTap: timer == 0 ? sendOtp : null,
        child: Text(
          timer > 0 ? "Resend in $timer s" : "Resend OTP",
          style: TextStyle(
            color: timer > 0 ? Colors.white54 : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      const SizedBox(height: 25),

      /// VERIFY BUTTON
      Container( 
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isComplete ? Colors.orange : Colors.grey.shade700,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: isComplete
              ? () {
                  verifyOtp();
                }
              : null,
          child: const Text("Verify"),
        ),
      ),
    ],
  ));
}




void nextStep() {
  if (step < 10) { 
    setState(() {
      step++;
    });
  }
}

String selectedGender = "";



Widget genderCard(String label, IconData icon) {
  final isSelected = selectedGender == label;

  return GestureDetector(
    onTap: () {
      if (!mounted) return; // ✅ safety

      setState(() {
        selectedGender = label;
        gender = label;
      });
    },
    child: Container( 
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF64DD17)],
              )
            : null,
        color: isSelected ? null : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: Transform.scale( 
        scale: isSelected ? 1.05 : 1.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget genderStep() {
  return screenWrapper(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Select Gender"),
        const SizedBox(height: 20),

        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            genderCard("Male", Icons.male),
            genderCard("Female", Icons.female),
            genderCard("Other", Icons.transgender),
          ],
        ),

        const SizedBox(height: 30),

        // 🔴 ERROR MESSAGE (important UX)
        if (showErrors && selectedGender.isEmpty)
          const Text(
            "Please select gender",
            style: TextStyle(color: Colors.red),
          ),

        const SizedBox(height: 10),

        // ✅ CONTINUE BUTTON
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedGender.isNotEmpty
                  ? Colors.orange
                  : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: selectedGender.isNotEmpty
                ? () {
                    nextStep();
                  }
                : () {
                    setState(() => showErrors = true);
                  },
            child: const Text("Continue"),
          ),
        ),
      ],
    ),
  );
}
  Widget dobStep() {
    return screenWrapper(Column(
      children: [
        title("Select DOB"),
        button("Pick Date", () async {
          var d = await showDatePicker(
            context: context,
            firstDate: DateTime(1960),
            lastDate: DateTime.now(),
            initialDate: DateTime(2000),
          );

          if (d != null) {
            dob = d;
            next();
          }
        })
      ],
    ));
  }

  Widget profileStep() {
    return screenWrapper(Column(
      children: [
        title("Basic Profile"),

        GestureDetector(
          onTap: pickImage,
          child: CircleAvatar(
            radius: 45,
            backgroundImage:
                imageFile != null ? FileImage(imageFile!) : null,
            child: imageFile == null
                ? const Icon(Icons.camera_alt, color: Colors.white)
                : null,
          ),
        ),

        input(nameController, "Full Name",
            isError: showErrors && nameController.text.isEmpty),

        TextField(
          controller: cityController,
          readOnly: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Location",
            hintStyle: const TextStyle(color: Colors.white54),
            errorText:
                showErrors && cityController.text.isEmpty ? "Required" : null,
            suffixIcon: IconButton(
              icon: const Icon(Icons.map, color: Colors.white),
              onPressed: pickLocation,
            ),
          ),
        ),

        input(phoneController, "Phone Number",
    isError: showErrors && phoneController.text.isEmpty),

        button("Next", () {
          setState(() => showErrors = true);

          if (nameController.text.isEmpty ||
              cityController.text.isEmpty) {
            showMsg("Fill required fields");
            return;
          }

          next();
        })
      ],
    ));
  }

Widget passwordStep() {
  String password = passwordController.text;
  String confirm = confirmPasswordController.text;

  bool hasUpper = password.contains(RegExp(r'[A-Z]'));
  bool hasLower = password.contains(RegExp(r'[a-z]'));
  bool hasNumber = password.contains(RegExp(r'[0-9]'));
  bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool hasLength = password.length >= 8;

  bool isStrong =
      hasUpper && hasLower && hasNumber && hasSpecial && hasLength;

  bool match = password == confirm && confirm.isNotEmpty;

  return screenWrapper(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Create Password"),

        const SizedBox(height: 20),

        /// 🔐 PASSWORD FIELD
        TextField(
          controller: passwordController,
          obscureText: obscurePass,
          style: const TextStyle(color: Colors.white),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: "Enter Password",
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePass ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() => obscurePass = !obscurePass);
              },
            ),
          ),
        ),

        const SizedBox(height: 15),

        /// 🔐 CONFIRM PASSWORD
        TextField(
          controller: confirmPasswordController,
          obscureText: obscureConfirm,
          style: const TextStyle(color: Colors.white),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: "Confirm Password",
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirm
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() => obscureConfirm = !obscureConfirm);
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// 🔍 PASSWORD RULES UI
        buildRule("At least 8 characters", hasLength),
        buildRule("Uppercase letter", hasUpper),
        buildRule("Lowercase letter", hasLower),
        buildRule("Number", hasNumber),
        buildRule("Special character", hasSpecial),

        const SizedBox(height: 10),

        if (confirm.isNotEmpty)
          buildRule("Passwords match", match),

        const SizedBox(height: 25),

        /// ✅ BUTTON
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (isStrong && match) ? Colors.orange : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: (isStrong && match)
                ? () {
                    nextStep();
                  }
                : null,
            child: const Text("Continue"),
          ),
        ),
      ],
    ),
  );
}


 
Widget playerStep() {
  bool isBatsman = role == "Batsman";
  bool isBowler = role == "Bowler";
  bool isAllRounder = role == "All-Rounder";
  bool isWK = role == "Wicket Keeper";

  bool battingRequired = isBatsman || isAllRounder || isWK;
  bool bowlingRequired = isBowler || isAllRounder;

  bool isValid =
      role != null &&
      battingStyle != null &&
      (bowlingRequired ? bowlingStyle != null : true);

  return screenWrapper(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Player Details"),
        const SizedBox(height: 20),

        /// ROLE
        const Text("Select Role",
            style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 10),

        wrap([
          roleChip("Batsman"),
          roleChip("Bowler"),
          roleChip("All-Rounder"),
          roleChip("Wicket Keeper"),
        ]),

        if (showErrors && role == null)
          const Text("Select role",
              style: TextStyle(color: Colors.red)),

        const SizedBox(height: 20),

        /// BATTING STYLE (ALWAYS SHOWN)
        dropdown(
          "Batting Style",
          ["Right Hand", "Left Hand"],
          (v) => setState(() => battingStyle = v),
        ),

        if (showErrors && battingRequired && battingStyle == null)
          const Text("Select batting style",
              style: TextStyle(color: Colors.red)),

        const SizedBox(height: 20),

        /// BOWLING STYLE (ALWAYS SHOWN BUT CONDITIONAL REQUIRED)
        dropdown(
          "Bowling Style",
          ["Fast", "Spin", "Medium", "None"],
          (v) => setState(() => bowlingStyle = v),
        ),

        if (showErrors && bowlingRequired && bowlingStyle == null)
          const Text("Select bowling style",
              style: TextStyle(color: Colors.red)),

        const SizedBox(height: 30),

        /// FINISH BUTTON
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isValid
                ? register
                : () {
                    setState(() => showErrors = true);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? Colors.orange : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Finish"),
          ),
        ),
      ],
    ),
  );
}

  /// ================= COMPONENTS =================

  Widget title(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
      );

  Widget input(TextEditingController c, String hint,
      {bool isError = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: c,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: isError ? Colors.red : Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: isError ? Colors.red : Colors.orange),
            ),
          ),
        ),
        if (isError)
          const Text("Required", style: TextStyle(color: Colors.red))
      ],
    );
  }

  Widget button(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Widget chip(String text) {
    return GestureDetector(
      onTap: () {
        gender = text;
        next();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget roleChip(String text) {
    bool active = role == text;

    return GestureDetector(
      onTap: () => setState(() => role = text),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.orange : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(color: active ? Colors.white : Colors.white70)),
      ),
    );
  }

  Widget wrap(List<Widget> children) {
    return Wrap(spacing: 10, runSpacing: 10, children: children);
  }

  Widget dropdown(
      String hint, List<String> items, Function(String) onChanged) {
    return DropdownButtonFormField(
      dropdownColor: Colors.black87,
      style: const TextStyle(color: Colors.white),
      hint: Text(hint, style: const TextStyle(color: Colors.white54)),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => onChanged(v.toString()),
    );
  }

  /// ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    Widget screen;

    switch (step) {
      case 0:
        screen = emailStep();
        break;
      case 1:
        screen = otpStep();
        break;
      case 2:
        screen = genderStep();
        break;
      case 3:
        screen = dobStep();
        break;
      case 4:
        screen = profileStep();
        break;
        case 5:
        screen = passwordStep();
        break;
      default:
        screen = playerStep();
    
    }


return Scaffold(
  body: Container(
    key: ValueKey(step),
    child: screen,
  ),
);
  }





@override
void dispose() {
  _disposed = true;

  otpTimer?.cancel();

  for (var c in otp) {
    c.dispose();
  }

  for (var f in focusNodes) {
    f.dispose();
  }

  for (var t in _delayedTimers) {
    t.cancel();
  }

  // ✅ Dispose all controllers BEFORE super
  nameController.dispose();
  cityController.dispose();
  passwordController.dispose();
  confirmPasswordController.dispose();
  phoneController.dispose();

  super.dispose(); // ✅ ONLY ONCE, ALWAYS LAST
}
  
  Widget buildRule(String text, bool valid) {
  return Row(
    children: [
      Icon(
        valid ? Icons.check_circle : Icons.cancel,
        color: valid ? Colors.green : Colors.red,
        size: 18,
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          color: valid ? Colors.green : Colors.white70,
        ),
      ),
    ],
  );
}


}
import 'package:flutter/material.dart';


class OtpScreen extends StatelessWidget {

  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("OTP Verification")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const Text("Enter OTP sent to your phone"),

            const SizedBox(height: 20),

            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter OTP",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Verify"),
            )

          ],
        ),
      ),
    );
  }
}
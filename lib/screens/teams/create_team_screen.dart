import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreateTeamScreen extends StatefulWidget {
  final int captainId;

  const CreateTeamScreen({super.key, required this.captainId});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final TextEditingController ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  Future<void> create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final res = await ApiService.createTeam(
        ctrl.text.trim(),
        widget.captainId,
      );

      if (!mounted) return;

      // ✅ SUCCESS POPUP
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Team Created"),
          content: const Text("✅ Your team has been created successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context, res["id"]); // return teamId
              },
              child: const Text("OK"),
            )
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;

      String message = "❌ Failed to create team";

      if (e.toString().contains("exists")) {
        message = "⚠️ Team name already exists";
      }

      // ❌ ERROR POPUP
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Team"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: ctrl,
                decoration: InputDecoration(
                  labelText: "Team Name",
                  hintText: "Enter your team name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.group),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Team name is required";
                  }
                  if (value.length < 3) {
                    return "Minimum 3 characters required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : create,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Create Team",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BallDetailsScreen extends StatefulWidget {
  final int matchId;
  final int initialRuns;

  const BallDetailsScreen({
    super.key,
    required this.matchId,
    required this.initialRuns,
  });

  @override
  State<BallDetailsScreen> createState() => _BallDetailsScreenState();
}

class _BallDetailsScreenState extends State<BallDetailsScreen> {

  late int runs;
  String extraType = "none";
  int extraRuns = 0;
  bool wicket = false;

  String wicketType = "bowled";
  String? fielder;

  @override
  void initState() {
    super.initState();
    runs = widget.initialRuns;
  }

  int _calcExtras() {
    if (extraType == "wide") return 1 + extraRuns;
    if (extraType == "no_ball") return 1;
    if (extraType == "bye" || extraType == "leg_bye") return runs;
    return 0;
  }

  Future<void> _submit() async {

    int batRuns = runs;

    if (extraType == "bye" || extraType == "leg_bye") {
      batRuns = 0;
    }

    await ApiService.addBall({
      "match_id": widget.matchId,
      "runs": batRuns,
      "extra_type": extraType == "none" ? null : extraType,
      "extra_runs": _calcExtras(),
      "wicket": wicket,

      /// 🔥 NEW FIELDS (BACKWARD SAFE)
      "wicket_type": wicket ? wicketType : null,
      "fielder": wicket && wicketType == "caught" ? fielder : null,
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              Text("Ball Details ($runs runs)",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              /// RUNS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0,1,2,3,4,6].map((r) {
                  return ChoiceChip(
                    label: Text("$r"),
                    selected: runs == r,
                    onSelected: (_) => setState(() => runs = r),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              /// EXTRAS
              Row(
                children: ["WD","NB","B","LB"].map((e) {
                  final map = {
                    "WD":"wide",
                    "NB":"no_ball",
                    "B":"bye",
                    "LB":"leg_bye"
                  };
                  final type = map[e]!;

                  return Expanded(
                    child: ChoiceChip(
                      label: Text(e),
                      selected: extraType == type,
                      onSelected: (_) => setState(() {
                        extraType = type;
                      }),
                    ),
                  );
                }).toList(),
              ),

              if (extraType == "wide")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [0,1,2,3,4].map((r) {
                    return ChoiceChip(
                      label: Text("+$r"),
                      selected: extraRuns == r,
                      onSelected: (_) => setState(() => extraRuns = r),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 12),

              /// WICKET
              SwitchListTile(
                title: const Text("Wicket"),
                value: wicket,
                onChanged: (v) => setState(() => wicket = v),
              ),

              if (wicket) ...[
                DropdownButtonFormField(
                  value: wicketType,
                  items: [
                    "bowled",
                    "caught",
                    "lbw",
                    "run_out",
                    "stumped"
                  ].map((w) {
                    return DropdownMenuItem(value: w, child: Text(w));
                  }).toList(),
                  onChanged: (v) => setState(() => wicketType = v.toString()),
                  decoration: const InputDecoration(labelText: "Wicket Type"),
                ),

                if (wicketType == "caught")
                  TextField(
                    decoration: const InputDecoration(labelText: "Fielder Name"),
                    onChanged: (v) => fielder = v,
                  ),
              ],

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _submit,
                child: const Text("Save Ball"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
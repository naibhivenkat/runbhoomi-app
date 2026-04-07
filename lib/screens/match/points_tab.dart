import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class PointsTab extends StatefulWidget {
  final int tournamentId;

  const PointsTab({required this.tournamentId});

  @override
  State<PointsTab> createState() => _PointsTabState();
}

class _PointsTabState extends State<PointsTab> {
  List points = [];

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  void loadPoints() async {
    final data = await ApiService.getPoints(widget.tournamentId);
    setState(() => points = data);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Team")),
          DataColumn(label: Text("P")),
          DataColumn(label: Text("W")),
          DataColumn(label: Text("Pts")),
          DataColumn(label: Text("NRR")),
        ],
        rows: points.map<DataRow>((p) {
          return DataRow(cells: [
            DataCell(Text(p["team"])),
            DataCell(Text(p["played"].toString())),
            DataCell(Text(p["wins"].toString())),
            DataCell(Text(p["points"].toString())),
            DataCell(Text(p["nrr"].toString())),
          ]);
        }).toList(),
      ),
    );
  }
}
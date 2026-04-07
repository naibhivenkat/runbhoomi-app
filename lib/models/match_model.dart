class MatchModel {
  final int id;
  final String team1;
  final String team2;
  final String score1;
  final String score2;
  final String status;

  MatchModel({
    required this.id,
    required this.team1,
    required this.team2,
    required this.score1,
    required this.score2,
    required this.status,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      team1: json['team1'],
      team2: json['team2'],
      score1: json['score1'] ?? "",
      score2: json['score2'] ?? "",
      status: json['status'] ?? "",
    );
  }
}
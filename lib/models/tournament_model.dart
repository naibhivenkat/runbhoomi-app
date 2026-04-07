class Tournament {
  final int id;
  final String name;
  final String location;
  final String type;

  final String? logoUrl;
  final String? bannerUrl;

  final int? totalTeams;
  final String? startDate;
  final String? endDate;

  Tournament({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    this.logoUrl,
    this.bannerUrl,
    this.totalTeams,
    this.startDate,
    this.endDate,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['city'] ?? '',
      type: json['match_type'] ?? '',
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
      totalTeams: json['total_teams'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}
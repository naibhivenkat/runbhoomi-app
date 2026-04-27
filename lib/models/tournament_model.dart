// class Tournament {
//   final int id;
//   final String name;
//   final String location;
//   final String type;

//   final String? logoUrl;
//   final String? bannerUrl;

//   final int? totalTeams;
//   final String? startDate;
//   final String? endDate;

//   Tournament({
//     required this.id,
//     required this.name,
//     required this.location,
//     required this.type,
//     this.logoUrl,
//     this.bannerUrl,
//     this.totalTeams,
//     this.startDate,
//     this.endDate,
//   });

//   factory Tournament.fromJson(Map<String, dynamic> json) {
//     return Tournament(
//       id: json['id'],
//       name: json['name'] ?? '',
//       location: json['city'] ?? '',
//       type: json['match_type'] ?? '',
//       logoUrl: json['logo_url'],
//       bannerUrl: json['banner_url'],
//       totalTeams: json['total_teams'],
//       startDate: json['start_date'],
//       endDate: json['end_date'],
//     );
//   }
// }





import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

// This line is required for Isar to generate the local database code
part 'tournament_model.g.dart';

const _uuid = Uuid();

@collection
class Tournament {
  // 1. ISAR REQUIREMENT: Extremely fast local integer ID
  Id id = Isar.autoIncrement; 

  // 2. BACKEND LINK: This generates the String UUID instantly when offline
  @Index(unique: true, replace: true)
  String backendId = _uuid.v4(); 

  String name = '';
  String location = '';
  String type = '';

  String? logoUrl;
  String? bannerUrl;

  int? totalTeams;
  String? startDate;
  String? endDate;

  // Helper to map data from your FastAPI server into the local database
  void fromJson(Map<String, dynamic> json) {
    backendId = json['id'].toString(); // Accepts the new String UUID from Python
    name = json['name'] ?? '';
    location = json['city'] ?? '';
    type = json['match_type'] ?? '';
    logoUrl = json['logo_url'];
    bannerUrl = json['banner_url'];
    totalTeams = json['total_teams'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  // Helper to package data to send to the FastAPI server
  Map<String, dynamic> toJson() {
    return {
      'id': backendId,
      'name': name,
      'city': location,
      'match_type': type,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'total_teams': totalTeams,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}
class UserModel {

  final String id;
  final String name;
  final String phone;
  final String city;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {

    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      city: json['city'],
    );

  }
}
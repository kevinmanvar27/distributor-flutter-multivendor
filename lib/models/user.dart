// To parse this JSON data, do
//
//     final userprofile = userprofileFromJson(jsonString);

import 'dart:convert';

Userprofile userprofileFromJson(String str) => Userprofile.fromJson(json.decode(str));

String userprofileToJson(Userprofile data) => json.encode(data.toJson());

class Userprofile {
  bool success;
  User data;
  String message;

  Userprofile({
    required this.success,
    required this.data,
    required this.message,
  });

  factory Userprofile.fromJson(Map<String, dynamic> json) => Userprofile(
    success: json["success"],
    data: User.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class User {
  int id;
  String name;
  String email;
  dynamic deviceToken;
  DateTime? dateOfBirth;
  dynamic avatar;
  String? address;
  String? mobileNumber;
  dynamic emailVerifiedAt;
  String userRole;
  DateTime createdAt;
  DateTime updatedAt;
  int isApproved;
  String discountPercentage;
  dynamic avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.deviceToken,
    this.dateOfBirth,
    required this.avatar,
    this.address,
    this.mobileNumber,
    required this.emailVerifiedAt,
    required this.userRole,
    required this.createdAt,
    required this.updatedAt,
    required this.isApproved,
    required this.discountPercentage,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    deviceToken: json["device_token"],
    dateOfBirth: json["date_of_birth"] == null ? null : DateTime.parse(json["date_of_birth"]),
    avatar: json["avatar"],
    address: json["address"],
    mobileNumber: json["mobile_number"],
    emailVerifiedAt: json["email_verified_at"],
    userRole: json["user_role"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    isApproved: json["is_approved"],
    discountPercentage: json["discount_percentage"],
    avatarUrl: json["avatar_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "device_token": deviceToken,
    "date_of_birth": dateOfBirth?.toIso8601String(),
    "avatar": avatar,
    "address": address,
    "mobile_number": mobileNumber,
    "email_verified_at": emailVerifiedAt,
    "user_role": userRole,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "is_approved": isApproved,
    "discount_percentage": discountPercentage,
    "avatar_url": avatarUrl,
  };
}

// To parse this JSON data, do
//
//     final avatar = avatarFromJson(jsonString);

import 'dart:convert';

Avatar avatarFromJson(String str) => Avatar.fromJson(json.decode(str));

String avatarToJson(Avatar data) => json.encode(data.toJson());

class Avatar {
  bool success;
  AvatarData data;
  String message;

  Avatar({
    required this.success,
    required this.data,
    required this.message,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
    success: json["success"],
    data: AvatarData.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class AvatarData {
  String avatar;
  String avatarUrl;

  AvatarData({
    required this.avatar,
    required this.avatarUrl,
  });

  factory AvatarData.fromJson(Map<String, dynamic> json) => AvatarData(
    avatar: json["avatar"],
    avatarUrl: json["avatar_url"],
  );

  Map<String, dynamic> toJson() => {
    "avatar": avatar,
    "avatar_url": avatarUrl,
  };
}

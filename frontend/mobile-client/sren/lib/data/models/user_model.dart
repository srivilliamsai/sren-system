import '../../domain/entities/user.dart';
import '../dto/login_response.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  factory UserModel.fromProfile(ProfileDto dto) {
    return UserModel(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      avatarUrl: dto.avatarUrl,
    );
  }

  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ??
          json['userId']?.toString() ??
          json['user_id']?.toString() ??
          json['profileId']?.toString() ??
          json['profile_id']?.toString() ??
          '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}

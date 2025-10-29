class LoginResponseDto {
  LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.profile,
  });

  final String accessToken;
  final String refreshToken;
  final ProfileDto profile;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      profile: ProfileDto.fromJson(
        (json['profile'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }
}

class ProfileDto {
  ProfileDto({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
      };
}

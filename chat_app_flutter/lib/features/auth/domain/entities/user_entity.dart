class UserEntity {
  final String id;
  final String username;
  final String email;
  final String accessToken;
  final String refreshToken;
  final String profileImage;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.profileImage,
  });
}
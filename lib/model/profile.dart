class Profile {
  final int id;
  final String username;
  final String email;
  final String avatar;

  Profile({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }
}

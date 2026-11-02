class UserProfile {
  final String name;
  final String email;
  final String role;
  final bool notificationsEnabled;
  final DateTime joinedDate;

  const UserProfile({
    this.name = 'Jeet Dodiya',
    this.email = 'jeet.dodiya@taskflow.dev',
    this.role = 'Productivity Architect',
    this.notificationsEnabled = true,
    required this.joinedDate,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? role,
    bool? notificationsEnabled,
    DateTime? joinedDate,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

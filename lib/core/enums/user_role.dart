enum UserRole {
  admin,
  student,
}

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.student:
        return 'USER';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.student:
        return 'USER';
    }
  }

  static UserRole fromString(String role) {
    final upper = role.toUpperCase().trim();
    if (upper == 'ADMIN' || upper == 'ROLE_ADMIN') {
      return UserRole.admin;
    }
    return UserRole.student;
  }
}

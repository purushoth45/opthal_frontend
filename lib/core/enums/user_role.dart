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
        return 'STUDENT';
    }
  }

  

  static UserRole fromString(String role) {
    if (role.toUpperCase() == 'ADMIN') {
      return UserRole.admin;
    }
    return UserRole.student;
  }
}

import 'package:ophthal_vivaedge/core/enums/user_role.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? medicalCollege;
  final String? mbbsYear;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.medicalCollege,
    this.mbbsYear,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isStudent => role == UserRole.student;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String?,
      medicalCollege: json['medicalCollege'] as String? ?? json['college'] as String?,
      mbbsYear: json['mbbsYear'] as String? ?? json['year'] as String?,
      role: UserRoleX.fromString(json['role'] as String? ?? 'USER'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (phoneNumber != null) 'phone': phoneNumber,
      if (medicalCollege != null) 'medicalCollege': medicalCollege,
      if (mbbsYear != null) 'mbbsYear': mbbsYear,
      'role': role.value,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? medicalCollege,
    String? mbbsYear,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      medicalCollege: medicalCollege ?? this.medicalCollege,
      mbbsYear: mbbsYear ?? this.mbbsYear,
      role: role ?? this.role,
    );
  }
}

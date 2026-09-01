import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophthal_vivaedge/models/user_model.dart';
import 'package:ophthal_vivaedge/repositories/admin_user_repository.dart';

enum AdminUserFilter { all, admin, user }

class AdminUserState {
  final List<UserModel> users;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final AdminUserFilter roleFilter;
  final bool isSubmitting;

  const AdminUserState({
    this.users = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.roleFilter = AdminUserFilter.all,
    this.isSubmitting = false,
  });

  List<UserModel> get filteredUsers {
    return users.where((user) {
      final query = searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.phoneNumber != null && user.phoneNumber!.toLowerCase().contains(query));

      final matchesRole = switch (roleFilter) {
        AdminUserFilter.all => true,
        AdminUserFilter.admin => user.isAdmin,
        AdminUserFilter.user => !user.isAdmin,
      };

      return matchesSearch && matchesRole;
    }).toList();
  }

  int get totalUsersCount => users.length;
  int get adminUsersCount => users.where((u) => u.isAdmin).length;
  int get standardUsersCount => users.where((u) => !u.isAdmin).length;

  AdminUserState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    AdminUserFilter? roleFilter,
    bool? isSubmitting,
  }) {
    return AdminUserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter ?? this.roleFilter,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AdminUserViewModel extends StateNotifier<AdminUserState> {
  final AdminUserRepository _repository;

  AdminUserViewModel({AdminUserRepository? repository})
      : _repository = repository ?? AdminUserRepository(),
        super(const AdminUserState(isLoading: true)) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final users = await _repository.getAllUsers();
      state = state.copyWith(
        users: users,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async {
    try {
      final users = await _repository.getAllUsers();
      state = state.copyWith(
        users: users,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setRoleFilter(AdminUserFilter filter) {
    state = state.copyWith(roleFilter: filter);
  }

  Future<UserModel> updateUser(
    int id, {
    required String name,
    required String phone,
    required String role,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final updated = await _repository.updateUser(
        id,
        name: name,
        phone: phone,
        role: role,
      );
      final updatedList = state.users.map((u) => u.id == id ? updated : u).toList();
      state = state.copyWith(
        users: updatedList,
        isSubmitting: false,
      );
      return updated;
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  Future<UserModel> updateUserRole(
    int id, {
    required String role,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final updated = await _repository.updateUserRole(id, role: role);
      final updatedList = state.users.map((u) => u.id == id ? updated : u).toList();
      state = state.copyWith(
        users: updatedList,
        isSubmitting: false,
      );
      return updated;
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.deleteUser(id);
      final updatedList = state.users.where((u) => u.id != id).toList();
      state = state.copyWith(
        users: updatedList,
        isSubmitting: false,
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }
}

final adminUserViewModelProvider =
    StateNotifierProvider.autoDispose<AdminUserViewModel, AdminUserState>((ref) {
  final repository = ref.watch(adminUserRepositoryProvider);
  return AdminUserViewModel(repository: repository);
});

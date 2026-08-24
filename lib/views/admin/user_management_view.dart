import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ophthal_vivaedge/core/constants/app_colors.dart';
import 'package:ophthal_vivaedge/models/user_model.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_shimmer.dart';
import 'package:ophthal_vivaedge/shared/widgets/app_snack_bar.dart';
import 'package:ophthal_vivaedge/shared/widgets/confirmation_dialog.dart';
import 'package:ophthal_vivaedge/shared/widgets/empty_view.dart';
import 'package:ophthal_vivaedge/shared/widgets/error_view.dart';
import 'package:ophthal_vivaedge/viewmodels/admin_user_viewmodel.dart';
import 'package:ophthal_vivaedge/views/admin/widgets/edit_user_dialog.dart';

class UserManagementView extends ConsumerStatefulWidget {
  const UserManagementView({super.key});

  @override
  ConsumerState<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends ConsumerState<UserManagementView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleChangeRole(UserModel user) async {
    final newRole = user.isAdmin ? 'USER' : 'ADMIN';
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Change User Role?',
      content:
          'Are you sure you want to change the role for "${user.name}" from ${user.isAdmin ? "ADMIN" : "USER"} to $newRole?',
      confirmText: 'CONFIRM',
      confirmColor: AppColors.accentBlue,
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(adminUserViewModelProvider.notifier)
            .updateUserRole(user.id, role: newRole);
        if (mounted) {
          AppSnackBar.showSuccess(
              context, 'Role updated to $newRole for ${user.name}');
        }
      } catch (e) {
        if (mounted) {
          final err = e.toString().replaceAll('Exception: ', '');
          AppSnackBar.showError(context, err);
        }
      }
    }
  }

  Future<void> _handleDeleteUser(UserModel user) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete User?',
      content:
          'Are you sure you want to delete this user?\nThis action cannot be undone.',
      confirmText: 'DELETE',
      confirmColor: AppColors.error,
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(adminUserViewModelProvider.notifier).deleteUser(user.id);
        if (mounted) {
          AppSnackBar.showSuccess(context, 'User deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          final err = e.toString().replaceAll('Exception: ', '');
          AppSnackBar.showError(context, err);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(adminUserViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol =
        isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final primaryText = isDark ? Colors.white : AppColors.primaryNavy;
    final secondaryText = isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor:
            isDark ? const Color(0xFF1E293B) : AppColors.primaryNavy,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(adminUserViewModelProvider.notifier).refresh(),
          color: AppColors.accentBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TOP STATS CARDS
                    _buildStatsRow(userState, cardBg, borderCol, primaryText,
                        secondaryText, isDark),
                    const SizedBox(height: 20),

                    // SEARCH & FILTER BAR
                    _buildSearchAndFilterBar(userState, cardBg, borderCol,
                        primaryText, secondaryText, isDark),
                    const SizedBox(height: 20),

                    // MAIN CONTENT STATE
                    _buildContent(userState, cardBg, borderCol, primaryText,
                        secondaryText, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    AdminUserState state,
    Color cardBg,
    Color borderCol,
    Color primaryText,
    Color secondaryText,
    bool isDark,
  ) {
    if (state.isLoading && state.users.isEmpty) {
      return const AppShimmer(
        child: Row(
          children: [
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 74, borderRadius: 12)),
            SizedBox(width: 10),
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 74, borderRadius: 12)),
            SizedBox(width: 10),
            Expanded(
                child: ShimmerBox(
                    width: double.infinity, height: 74, borderRadius: 12)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 540;

        Widget buildStatCard(
            String title, int count, Color accentColor, IconData icon) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderCol),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: secondaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final totalCard = buildStatCard(
          'Total Users',
          state.totalUsersCount,
          AppColors.accentBlue,
          Icons.people_alt_rounded,
        );

        final adminCard = buildStatCard(
          'Admins',
          state.adminUsersCount,
          const Color(0xFF8B5CF6),
          Icons.admin_panel_settings_rounded,
        );

        final standardCard = buildStatCard(
          'Standard Users',
          state.standardUsersCount,
          AppColors.success,
          Icons.person_rounded,
        );

        if (isNarrow) {
          return Column(
            children: [
              totalCard,
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: adminCard),
                  const SizedBox(width: 8),
                  Expanded(child: standardCard),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: totalCard),
            const SizedBox(width: 10),
            Expanded(child: adminCard),
            const SizedBox(width: 10),
            Expanded(child: standardCard),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilterBar(
    AdminUserState state,
    Color cardBg,
    Color borderCol,
    Color primaryText,
    Color secondaryText,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;

        final searchField = TextField(
          controller: _searchController,
          style: TextStyle(color: primaryText, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search by name, email, or phone...',
            hintStyle:
                TextStyle(color: isDark ? Colors.white54 : AppColors.textMuted),
            prefixIcon: Icon(Icons.search_rounded, color: secondaryText),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded,
                        color: secondaryText, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      ref
                          .read(adminUserViewModelProvider.notifier)
                          .setSearchQuery('');
                    },
                  )
                : null,
            filled: true,
            fillColor: cardBg,
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderCol),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.accentBlue, width: 2),
            ),
          ),
          onChanged: (val) {
            ref.read(adminUserViewModelProvider.notifier).setSearchQuery(val);
          },
        );

        final filterDropdown = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderCol),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AdminUserFilter>(
              value: state.roleFilter,
              dropdownColor: cardBg,
              style: TextStyle(
                  color: primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              items: const [
                DropdownMenuItem(
                  value: AdminUserFilter.all,
                  child: Text('All Roles'),
                ),
                DropdownMenuItem(
                  value: AdminUserFilter.admin,
                  child: Text('Admins Only'),
                ),
                DropdownMenuItem(
                  value: AdminUserFilter.user,
                  child: Text('Standard Users Only'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref
                      .read(adminUserViewModelProvider.notifier)
                      .setRoleFilter(val);
                }
              },
            ),
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              filterDropdown,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 12),
            filterDropdown,
          ],
        );
      },
    );
  }

  Widget _buildContent(
    AdminUserState state,
    Color cardBg,
    Color borderCol,
    Color primaryText,
    Color secondaryText,
    bool isDark,
  ) {
    if (state.isLoading && state.users.isEmpty) {
      return AppShimmer(
        child: Column(
          children: List.generate(
            4,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: ShimmerBox(
                  width: double.infinity, height: 96, borderRadius: 14),
            ),
          ),
        ),
      );
    }

    if (state.errorMessage != null && state.users.isEmpty) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(adminUserViewModelProvider.notifier).loadUsers(),
      );
    }

    final filteredUsers = state.filteredUsers;

    if (filteredUsers.isEmpty) {
      final isSearching = state.searchQuery.isNotEmpty ||
          state.roleFilter != AdminUserFilter.all;
      return EmptyView(
        title: isSearching ? 'No Matching Users' : 'No Users Found',
        message: isSearching
            ? 'Try adjusting your search query or role filter.'
            : 'No user accounts are currently registered.',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(
            user, cardBg, borderCol, primaryText, secondaryText, isDark);
      },
    );
  }

  Widget _buildUserCard(
    UserModel user,
    Color cardBg,
    Color borderCol,
    Color primaryText,
    Color secondaryText,
    bool isDark,
  ) {
    final isAdmin = user.isAdmin;
    final roleBadgeBg = isAdmin
        ? const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.25 : 0.12)
        : AppColors.accentBlue.withValues(alpha: isDark ? 0.25 : 0.12);
    final roleBadgeText =
        isAdmin ? const Color(0xFFA78BFA) : AppColors.accentBlue;

    return Card(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderCol, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: LayoutBuilder(
          builder: (context, itemConstraints) {
            final isMobile = itemConstraints.maxWidth < 520;

            final userAvatar = CircleAvatar(
              radius: 20,
              backgroundColor: isAdmin
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                  : AppColors.accentBlue.withValues(alpha: 0.15),
              child: Text(
                user.name.isNotEmpty
                    ? user.name.substring(0, 1).toUpperCase()
                    : 'U',
                style: TextStyle(
                  color: isAdmin
                      ? const Color(0xFF8B5CF6)
                      : AppColors.accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );

            final userInfo = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name.isNotEmpty ? user.name : 'Unknown User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: roleBadgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAdmin ? 'ADMIN' : 'USER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: roleBadgeText,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 14, color: secondaryText),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user.email,
                        style: TextStyle(fontSize: 13, color: secondaryText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (user.phoneNumber != null &&
                    user.phoneNumber!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          size: 14, color: secondaryText),
                      const SizedBox(width: 6),
                      Text(
                        'Phone: ${user.phoneNumber}',
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),
                    ],
                  ),
                ],
              ],
            );

            final actionButtons = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: AppColors.accentBlue),
                  tooltip: 'View / Edit User',
                  onPressed: () => EditUserDialog.show(context, user),
                ),
                IconButton(
                  icon: Icon(
                    Icons.swap_horiz_rounded,
                    size: 20,
                    color: isAdmin
                        ? const Color(0xFF8B5CF6)
                        : AppColors.accentBlue,
                  ),
                  tooltip: isAdmin ? 'Demote to USER' : 'Promote to ADMIN',
                  onPressed: () => _handleChangeRole(user),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 20, color: AppColors.error),
                  tooltip: 'Delete User',
                  onPressed: () => _handleDeleteUser(user),
                ),
              ],
            );

            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userAvatar,
                      const SizedBox(width: 12),
                      Expanded(child: userInfo),
                    ],
                  ),
                  Divider(height: 16, color: borderCol),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      actionButtons,
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                userAvatar,
                const SizedBox(width: 14),
                Expanded(child: userInfo),
                actionButtons,
              ],
            );
          },
        ),
      ),
    );
  }
}

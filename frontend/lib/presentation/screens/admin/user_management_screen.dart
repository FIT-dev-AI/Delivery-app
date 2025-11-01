import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/admin_provider.dart';
import '../../widgets/admin/user_admin_card.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String? _selectedRole; // null = all, 'customer', 'shipper'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load users when screen opens
    Future.microtask(() => _loadUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.fetchAllUsers(
      role: _selectedRole,
      search: _searchController.text.isEmpty ? null : _searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Người Dùng'),
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadUsers,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          _buildSearchAndFilter(),

          // Stats Summary
          _buildStatsSection(),

          const Divider(height: 1),

          // Users List
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryOrange,
                    ),
                  );
                }

                if (adminProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: errorRed.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          adminProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: errorRed),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadUsers,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (adminProvider.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: textLight.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không tìm thấy user',
                          style: TextStyle(
                            fontSize: 16,
                            color: textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadUsers,
                  color: primaryOrange,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: adminProvider.users.length,
                    itemBuilder: (context, index) {
                      final user = adminProvider.users[index];
                      return UserAdminCard(user: user);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD METHODS ====================

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên hoặc email...',
              prefixIcon: const Icon(Icons.search, color: textLight),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: textLight),
                      onPressed: () {
                        _searchController.clear();
                        _loadUsers();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withAlpha(76)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withAlpha(76)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryOrange, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: (_) => _loadUsers(),
          ),
          const SizedBox(height: 12),

          // Role Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', null),
                const SizedBox(width: 8),
                _buildFilterChip('Khách Hàng', 'customer'),
                const SizedBox(width: 8),
                _buildFilterChip('Tài Xế', 'shipper'),
                const SizedBox(width: 8),
                _buildFilterChip('Admin', 'admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? role) {
    final isSelected = _selectedRole == role;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRole = selected ? role : null;
        });
        _loadUsers();
      },
      backgroundColor: Colors.white,
      selectedColor: primaryOrange.withAlpha(51),
      checkmarkColor: primaryOrange,
      labelStyle: TextStyle(
        color: isSelected ? primaryOrange : textDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? primaryOrange : Colors.grey.withAlpha(76),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildStatsSection() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final totalUsers = adminProvider.users.length;
        final activeUsers = adminProvider.users.where((u) => u.isActive).length;
        final inactiveUsers = totalUsers - activeUsers;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  label: 'Tổng',
                  value: totalUsers.toString(),
                  color: infoBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Hoạt động',
                  value: activeUsers.toString(),
                  color: successGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.block,
                  label: 'Khóa',
                  value: inactiveUsers.toString(),
                  color: errorRed,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(76),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: textLight,
            ),
          ),
        ],
      ),
    );
  }
}
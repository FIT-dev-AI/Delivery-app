// frontend/lib/presentation/screens/main_navigation_screen.dart
// ✅ UPDATED: Compact Orange Online Status Bar

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import 'map_screen.dart';
import 'order_list_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationScreen({
    super.key,
    this.initialIndex = -1,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleOnlineToggle(bool value, AuthProvider authProvider) async {
    setState(() => _isUpdatingStatus = true);

    try {
      await authProvider.updateOnlineStatus(value);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? '✅ Bạn đang online - Có thể nhận đơn' : '⚠️ Bạn đang offline - Không nhận đơn mới',
          ),
          backgroundColor: value ? successGreen : warningOrange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi: ${e.toString()}'),
          backgroundColor: errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: primaryOrange),
        ),
      );
    }

    if (_selectedIndex == -1) {
      _selectedIndex = 0;
    }

    final List<Widget> screens;
    final List<BottomNavigationBarItem> navItems;

    if (user.isShipper) {
      screens = [
        const MapScreen(),
        const OrderListScreen(isMainScreen: false),
        const StatsScreen(),
        const ProfileScreen(),
      ];

      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Bản đồ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_outlined),
          activeIcon: Icon(Icons.receipt),
          label: 'Đơn hàng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Thống kê',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Hồ sơ',
        ),
      ];
    } else {
      screens = [
        const OrderListScreen(isMainScreen: true),
        const StatsScreen(),
        const ProfileScreen(),
      ];

      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_outlined),
          activeIcon: Icon(Icons.receipt),
          label: 'Đơn hàng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Thống kê',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Hồ sơ',
        ),
      ];
    }

    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // ✅ NEW: Compact Orange Status Bar (Shipper only)
      appBar: user.isShipper ? _buildCompactStatusBar(user, authProvider) : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: navItems,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: primaryOrange,
          unselectedItemColor: textLight,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
        ),
      ),
    );
  }

  // ✅ NEW: Compact Orange Status Bar
  PreferredSizeWidget _buildCompactStatusBar(user, AuthProvider authProvider) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48), // ✅ COMPACT: 48px (was 56px)
      child: Container(
        decoration: BoxDecoration(
          gradient: user.isOnline
              ? const LinearGradient(
                  colors: [primaryOrange, accentOrange],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : LinearGradient(
                  colors: [Colors.grey[400]!, Colors.grey[500]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          boxShadow: [
            BoxShadow(
              color: (user.isOnline ? primaryOrange : Colors.grey[400]!).withAlpha(76),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // ✅ Animated Status Dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: user.isOnline
                        ? [
                            BoxShadow(
                              color: Colors.white.withAlpha(127),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                ),
                const SizedBox(width: 10),
                
                // ✅ Status Text - Compact
                Expanded(
                  child: Text(
                    user.isOnline ? 'Đang Online' : 'Đang Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                
                // ✅ Loading Indicator (when updating)
                if (_isUpdatingStatus)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                
                // ✅ Compact Toggle Switch
                Transform.scale(
                  scale: 0.85, // ✅ SMALLER switch
                  child: Switch(
                    value: user.isOnline,
                    onChanged: _isUpdatingStatus 
                        ? null 
                        : (value) => _handleOnlineToggle(value, authProvider),
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.white.withAlpha(127),
                    inactiveThumbColor: Colors.white.withAlpha(178),
                    inactiveTrackColor: Colors.white.withAlpha(51),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/loading_widget.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _newMessages = true;
  bool _systemNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final settings = await authProvider.getSettings();
      
      if (mounted && settings['success']) {
        final notifications = settings['data']['settings']['notifications'];
        setState(() {
          _orderUpdates = notifications['orderUpdates'] ?? true;
          _promotions = notifications['promotions'] ?? true;
          _newMessages = notifications['newMessages'] ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải cài đặt: ${e.toString()}'),
            backgroundColor: errorRed,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.updateSettings(
        notifications: {
          'orderUpdates': _orderUpdates,
          'promotions': _promotions,
          'newMessages': _newMessages,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cài đặt đã được lưu!'),
            backgroundColor: successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu cài đặt: ${e.toString()}'),
            backgroundColor: errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt thông báo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textDark,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Lưu',
              style: TextStyle(
                color: primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Đang tải cài đặt...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryOrange.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: primaryOrange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quản lý thông báo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tùy chỉnh các loại thông báo bạn muốn nhận',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Notifications Section
                  _buildSectionHeader('Thông báo ứng dụng'),
                  _buildNotificationTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Cập nhật đơn hàng',
                    subtitle: 'Thông báo về trạng thái đơn hàng',
                    value: _orderUpdates,
                    onChanged: (value) {
                      setState(() => _orderUpdates = value);
                    },
                  ),
                  _buildNotificationTile(
                    icon: Icons.local_offer_outlined,
                    title: 'Khuyến mãi',
                    subtitle: 'Thông báo về ưu đãi và khuyến mãi',
                    value: _promotions,
                    onChanged: (value) {
                      setState(() => _promotions = value);
                    },
                  ),
                  _buildNotificationTile(
                    icon: Icons.message_outlined,
                    title: 'Tin nhắn mới',
                    subtitle: 'Thông báo khi có tin nhắn mới',
                    value: _newMessages,
                    onChanged: (value) {
                      setState(() => _newMessages = value);
                    },
                  ),
                  _buildNotificationTile(
                    icon: Icons.info_outline,
                    title: 'Thông báo hệ thống',
                    subtitle: 'Cập nhật và thông báo quan trọng',
                    value: _systemNotifications,
                    onChanged: (value) {
                      setState(() => _systemNotifications = value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Other Notifications Section
                  _buildSectionHeader('Thông báo khác'),
                  _buildNotificationTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: 'Nhận thông báo qua email',
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() => _emailNotifications = value);
                    },
                  ),
                  _buildNotificationTile(
                    icon: Icons.sms_outlined,
                    title: 'SMS',
                    subtitle: 'Nhận thông báo qua tin nhắn',
                    value: _smsNotifications,
                    onChanged: (value) {
                      setState(() => _smsNotifications = value);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withAlpha(76),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lưu ý',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Một số thông báo quan trọng về bảo mật và giao dịch sẽ vẫn được gửi ngay cả khi bạn tắt thông báo.',
                          style: TextStyle(
                            fontSize: 12,
                            color: textDark,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primaryOrange,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryOrange.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryOrange, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: textLight,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: primaryOrange,
      ),
    );
  }
}
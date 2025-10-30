import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Về ứng dụng'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo & Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'DeliveryFlow',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ứng dụng quản lý giao hàng thông minh',
                      style: TextStyle(
                        fontSize: 14,
                        color: textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryOrange.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Phiên bản 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Description
            _buildInfoSection(
              'Giới thiệu',
              'DeliveryFlow là ứng dụng quản lý giao hàng hiện đại, giúp kết nối khách hàng và tài xế một cách nhanh chóng và hiệu quả. Với giao diện thân thiện và tính năng theo dõi thời gian thực, chúng tôi cam kết mang đến trải nghiệm giao hàng tốt nhất.',
            ),

            const SizedBox(height: 16),

            // Key Features
            _buildInfoSection(
              'Tính năng chính',
              '• Theo dõi đơn hàng thời gian thực\n'
              '• Tính toán tuyến đường tối ưu\n'
              '• Thông báo cập nhật trạng thái\n'
              '• Quản lý lịch sử giao dịch\n'
              '• Hỗ trợ khách hàng 24/7\n'
              '• Thanh toán đa dạng và bảo mật',
            ),

            const SizedBox(height: 24),

            // Company Info
            _buildSectionHeader('Thông tin công ty'),
            _buildInfoTile(
              Icons.business_outlined,
              'Công ty',
              'DeliveryFlow Technologies',
            ),
            _buildInfoTile(
              Icons.location_on_outlined,
              'Địa chỉ',
              '123 Đường ABC, Quận 1, TP.HCM',
            ),
            _buildInfoTile(
              Icons.email_outlined,
              'Email',
              'info@deliveryflow.com',
              onTap: () => _sendEmail('info@deliveryflow.com'),
            ),
            _buildInfoTile(
              Icons.phone_outlined,
              'Hotline',
              '1900-1234',
              onTap: () => _makePhoneCall('19001234'),
            ),
            _buildInfoTile(
              Icons.language_outlined,
              'Website',
              'www.deliveryflow.com',
              onTap: () => _openWebsite('https://deliveryflow.com'),
            ),

            const SizedBox(height: 24),

            // Legal & Privacy
            _buildSectionHeader('Pháp lý & Bảo mật'),
            _buildInfoTile(
              Icons.description_outlined,
              'Điều khoản sử dụng',
              'Xem chi tiết',
              onTap: () => _openTerms(),
            ),
            _buildInfoTile(
              Icons.privacy_tip_outlined,
              'Chính sách bảo mật',
              'Xem chi tiết',
              onTap: () => _openPrivacy(),
            ),
            _buildInfoTile(
              Icons.security_outlined,
              'Bảo mật dữ liệu',
              'Xem chi tiết',
              onTap: () => _openSecurity(),
            ),

            const SizedBox(height: 24),

            // Social Media
            _buildSectionHeader('Kết nối với chúng tôi'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  Icons.facebook,
                  'Facebook',
                  () => _openSocial('facebook'),
                ),
                _buildSocialButton(
                  Icons.alternate_email,
                  'Twitter',
                  () => _openSocial('twitter'),
                ),
                _buildSocialButton(
                  Icons.camera_alt,
                  'Instagram',
                  () => _openSocial('instagram'),
                ),
                _buildSocialButton(
                  Icons.play_arrow,
                  'YouTube',
                  () => _openSocial('youtube'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Credits
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'Được phát triển với ❤️ tại Việt Nam',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '© 2024 DeliveryFlow Technologies. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: textLight,
                    ),
                    textAlign: TextAlign.center,
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
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryOrange,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: textLight,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
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
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: textLight,
          ),
        ),
        trailing: onTap != null ? const Icon(Icons.chevron_right, color: textLight) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryOrange.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryOrange.withAlpha(76),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Icon(
              icon,
              color: primaryOrange,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: textLight,
          ),
        ),
      ],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Liên hệ DeliveryFlow',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _openWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openTerms() {
    // Open terms of service
  }

  void _openPrivacy() {
    // Open privacy policy
  }

  void _openSecurity() {
    // Open security information
  }

  void _openSocial(String platform) {
    // Open social media links
    switch (platform) {
      case 'facebook':
        _openWebsite('https://facebook.com/deliveryflow');
        break;
      case 'twitter':
        _openWebsite('https://twitter.com/deliveryflow');
        break;
      case 'instagram':
        _openWebsite('https://instagram.com/deliveryflow');
        break;
      case 'youtube':
        _openWebsite('https://youtube.com/deliveryflow');
        break;
    }
  }
}
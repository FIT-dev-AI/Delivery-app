import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textDark,
      ),
      body: SingleChildScrollView(
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
                        Icons.help_outline,
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
                            'Chúng tôi có thể giúp gì?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tìm câu trả lời cho các câu hỏi thường gặp',
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

            // Quick Actions
            _buildSectionHeader('Liên hệ nhanh'),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.phone,
                    title: 'Gọi hotline',
                    subtitle: '1900-1234',
                    onTap: () => _makePhoneCall('19001234'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.chat,
                    title: 'Chat hỗ trợ',
                    subtitle: 'Trực tuyến 24/7',
                    onTap: () => _openChat(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // FAQ Section
            _buildSectionHeader('Câu hỏi thường gặp'),
            _buildFAQItem(
              'Làm thế nào để tạo đơn hàng?',
              'Bạn có thể tạo đơn hàng bằng cách nhấn nút "Tạo đơn" trên màn hình chính, sau đó điền thông tin địa chỉ lấy hàng và giao hàng.',
            ),
            _buildFAQItem(
              'Tôi có thể theo dõi đơn hàng như thế nào?',
              'Vào mục "Đơn hàng" để xem tất cả đơn hàng của bạn. Nhấn vào đơn hàng cụ thể để xem chi tiết và theo dõi trên bản đồ.',
            ),
            _buildFAQItem(
              'Phí giao hàng được tính như thế nào?',
              'Phí giao hàng được tính dựa trên khoảng cách giữa địa điểm lấy hàng và giao hàng, cùng với loại hàng hóa.',
            ),
            _buildFAQItem(
              'Tôi có thể hủy đơn hàng không?',
              'Bạn có thể hủy đơn hàng khi đơn hàng đang ở trạng thái "Chờ xử lý" hoặc "Đã xác nhận". Sau khi shipper đã lấy hàng thì không thể hủy.',
            ),
            _buildFAQItem(
              'Làm thế nào để thay đổi thông tin cá nhân?',
              'Vào mục "Hồ sơ" > "Chỉnh sửa thông tin" để cập nhật tên, số điện thoại và các thông tin khác.',
            ),

            const SizedBox(height: 24),

            // Contact Section
            _buildSectionHeader('Thông tin liên hệ'),
            _buildContactItem(
              Icons.location_on_outlined,
              'Địa chỉ',
              '123 Đường ABC, Quận 1, TP.HCM',
              () {},
            ),
            _buildContactItem(
              Icons.email_outlined,
              'Email',
              'support@deliveryflow.com',
              () => _sendEmail('support@deliveryflow.com'),
            ),
            _buildContactItem(
              Icons.language_outlined,
              'Website',
              'www.deliveryflow.com',
              () => _openWebsite('https://deliveryflow.com'),
            ),
            _buildContactItem(
              Icons.schedule_outlined,
              'Giờ làm việc',
              'Thứ 2 - Chủ nhật: 6:00 - 22:00',
              () {},
            ),

            const SizedBox(height: 24),

            // Feedback Section
            _buildSectionHeader('Góp ý & Phản hồi'),
            Card(
              elevation: 1,
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
                  child: const Icon(Icons.feedback_outlined, color: primaryOrange),
                ),
                title: const Text(
                  'Gửi phản hồi',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                subtitle: const Text(
                  'Chia sẻ ý kiến để chúng tôi cải thiện dịch vụ',
                  style: TextStyle(
                    fontSize: 12,
                    color: textLight,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: textLight),
                onTap: () => _sendFeedback(),
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

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryOrange.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryOrange, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: textDark,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                color: textLight,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
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
        trailing: onTap != () {} ? const Icon(Icons.chevron_right, color: textLight) : null,
        onTap: onTap != () {} ? onTap : null,
      ),
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
      query: 'subject=Hỗ trợ DeliveryFlow',
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

  void _openChat() {
    // Implement chat functionality
    // This could open a chat widget or navigate to a chat screen
  }

  void _sendFeedback() {
    // Implement feedback functionality
    // This could open a feedback form or navigate to a feedback screen
  }
}
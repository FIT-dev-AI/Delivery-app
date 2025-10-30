// lib/presentation/screens/stats_screen.dart (THAY THẾ HOÀN TOÀN)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/stats_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/modern_stat_card.dart';
import '../widgets/revenue_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    // Trì hoãn việc gọi hàm load data cho đến khi frame đầu tiên được vẽ xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  Future<void> _loadStats() async {
    if (!mounted) return; // Kiểm tra mounted trước khi thực hiện
    
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final isShipper = user?.role == 'shipper';
      
      final statsProvider = Provider.of<StatsProvider>(context, listen: false);
      await statsProvider.fetchStats(isShipper);
    } catch (e) {
      // Xử lý lỗi một cách an toàn
      if (mounted) {
        // Có thể thêm error handling ở đây nếu cần
        debugPrint('Error loading stats: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê & Báo Cáo'),
        automaticallyImplyLeading: true,
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Consumer<StatsProvider>(
        builder: (context, statsProvider, child) {
          if (statsProvider.isLoading) {
            return const LoadingWidget(message: 'Đang tải thống kê...');
          }

          if (statsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: errorRed),
                  const SizedBox(height: 16),
                  Text(
                    statsProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: textLight),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadStats,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (statsProvider.stats == null) {
            return const EmptyState(
              title: 'Chưa có dữ liệu',
              message: 'Không có thống kê để hiển thị',
              icon: Icons.analytics_outlined,
            );
          }

          final stats = statsProvider.stats!;
          final user = Provider.of<AuthProvider>(context, listen: false).user;
          final isShipper = user?.role == 'shipper';

          return RefreshIndicator(
            onRefresh: _loadStats,
            color: primaryOrange,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid 2x2 - Role-based
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15, // Tỷ lệ tốt hơn
                    children: [
                      ModernStatCard(
                        title: 'Tổng đơn hàng',
                        value: (stats['totalOrders'] ?? 0).toString(),
                        icon: Icons.shopping_bag_rounded,
                        color: primaryOrange,
                      ),
                      ModernStatCard(
                        title: isShipper ? 'Đã giao' : 'Đã nhận',
                        value: (stats['completedOrders'] ?? 0).toString(),
                        icon: Icons.check_circle_rounded,
                        color: successGreen,
                      ),
                      ModernStatCard(
                        title: isShipper ? 'Đang giao' : 'Đang vận chuyển',
                        value: (stats['inProgressOrders'] ?? 0).toString(),
                        icon: isShipper ? Icons.local_shipping_rounded : Icons.delivery_dining,
                        color: accentOrange,
                      ),
                      ModernStatCard(
                        title: isShipper ? 'Đã hủy' : 'Đang chờ',
                        value: (isShipper ? stats['cancelledOrders'] : stats['pendingOrders'] ?? 0).toString(),
                        icon: isShipper ? Icons.cancel_rounded : Icons.hourglass_empty,
                        color: isShipper ? errorRed : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Revenue Card
                  RevenueCard(
                    title: isShipper ? 'Doanh thu' : 'Tổng chi tiêu',
                    amount: _formatRevenue(isShipper ? (stats['revenue'] ?? 0) : (stats['totalSpent'] ?? 0)),
                    period: 'THÁNG NÀY',
                    percentage: (stats['revenueGrowth'] ?? 0).toDouble(),
                    isPositive: (stats['revenueGrowth'] ?? 0) >= 0,
                    isShipper: isShipper,
                  ),
                  const SizedBox(height: 28),

                  // Bar Chart Section
                  _buildSectionHeader('Hiệu Suất 7 Ngày Qua', Icons.bar_chart_rounded, primaryOrange),
                  const SizedBox(height: 16),

                  _buildBarChartCard(),
                  const SizedBox(height: 28),

                  // Insights Section
                  _buildSectionHeader('Nhận Xét & Xu Hướng', Icons.lightbulb_rounded, successGreen),
                  const SizedBox(height: 16),

                  _buildInsightCard(
                    '📈 Đơn hàng tăng 15% so với tuần trước',
                    'Hiệu suất giao hàng đang cải thiện',
                    successGreen,
                  ),
                  const SizedBox(height: 12),
                  _buildInsightCard(
                    '⏱️ Thời gian giao trung bình: 25 phút',
                    'Nhanh hơn 5 phút so với tháng trước',
                    infoBlue,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatRevenue(dynamic revenue) {
    final amount = (revenue ?? 0).toDouble();
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} Tr';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} K';
    }
    return amount.toStringAsFixed(0);
  }

  List<BarChartGroupData> _buildBarGroups() {
    final data = [15, 20, 25, 18, 22, 28, 30];
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index].toDouble(),
            gradient: primaryGradient,
            width: 18,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBarChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 35,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.max) return Container();
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: textLight,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                    final index = value.toInt();
                    if (index < 0 || index >= days.length) {
                      return Container();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        days[index],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textLight,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 10,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withAlpha(38),
                  strokeWidth: 1,
                );
              },
            ),
            barGroups: _buildBarGroups(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInsightCard(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_upward_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
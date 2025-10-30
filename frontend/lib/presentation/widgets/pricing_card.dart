import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/pricing_constants.dart';

/// Main pricing card - shows distance and total amount
class PricingCard extends StatelessWidget {
  final double distanceKm;
  final double totalAmount;
  final bool showBreakdown;
  final VoidCallback? onTap;

  const PricingCard({
    super.key,
    required this.distanceKm,
    required this.totalAmount,
    this.showBreakdown = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryOrange.withAlpha(26),
            accentOrange.withAlpha(13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryOrange.withAlpha(76),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Distance row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryOrange.withAlpha(38),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.straighten,
                        color: primaryOrange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PricingText.distanceLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.formatDistance(distanceKm),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Divider
                Divider(color: Colors.grey[300], height: 1),
                
                const SizedBox(height: 12),
                
                // Total amount row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: successGreen.withAlpha(38),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: successGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PricingText.totalLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.format(totalAmount),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: successGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showBreakdown)
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact pricing chip - for order lists
class PricingChip extends StatelessWidget {
  final double amount;
  final IconData icon;
  final Color color;

  const PricingChip({
    super.key,
    required this.amount,
    this.icon = Icons.payments,
    this.color = primaryOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(76),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pricing breakdown (detailed view)
class PricingBreakdown extends StatelessWidget {
  final PricingResult pricing;

  const PricingBreakdown({
    super.key,
    required this.pricing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                PricingText.breakdownLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Distance
          _buildRow(
            '${CurrencyFormatter.formatDistance(pricing.distanceKm)} × ${CurrencyFormatter.format(PricingConfig.pricePerKm)}',
            pricing.totalAmount,
          ),
          
          const SizedBox(height: 8),
          Divider(color: Colors.grey[300], height: 1),
          const SizedBox(height: 8),
          
          // Shipper amount
          _buildRow(
            '${PricingText.shipperLabel} (70%)',
            pricing.shipperAmount,
            color: successGreen,
          ),
          
          const SizedBox(height: 8),
          Divider(color: Colors.grey[300], height: 1, thickness: 2),
          const SizedBox(height: 8),
          
          // Total
          _buildRow(
            PricingText.totalLabel,
            pricing.totalAmount,
            isBold: true,
            color: primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.grey[700],
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? textDark,
          ),
        ),
      ],
    );
  }
}

/// Loading shimmer for pricing
class PricingLoadingShimmer extends StatelessWidget {
  const PricingLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Đang tính giá...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
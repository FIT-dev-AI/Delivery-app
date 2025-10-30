// lib/presentation/widgets/weight_selector.dart
// ✅ NEW: Weight selector widget with slider (0-30kg)

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class WeightSelector extends StatelessWidget {
  final double weight;
  final ValueChanged<double> onWeightChanged;
  final bool showHelperText;

  const WeightSelector({
    super.key,
    required this.weight,
    required this.onWeightChanged,
    this.showHelperText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with icon
        Row(
          children: [
            Icon(
              _getWeightIcon(weight),
              size: 20,
              color: _getWeightColor(weight),
            ),
            const SizedBox(width: 8),
            Text(
              'Cân Nặng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getWeightColor(weight).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getWeightColor(weight).withAlpha(51),
                  width: 1,
                ),
              ),
              child: Text(
                '${weight.toStringAsFixed(1)} kg',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _getWeightColor(weight),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Slider with custom styling
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _getWeightColor(weight),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: _getWeightColor(weight),
            overlayColor: _getWeightColor(weight).withAlpha(51),
            trackHeight: 6.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
          ),
          child: Slider(
            value: weight,
            min: 0,
            max: 30,
            divisions: 60, // 0.5kg steps
            label: '${weight.toStringAsFixed(1)} kg',
            onChanged: onWeightChanged,
          ),
        ),

        // Quick select buttons
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickSelectButton(
                label: '1kg',
                weight: 1.0,
                isSelected: weight == 1.0,
                onTap: () => onWeightChanged(1.0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickSelectButton(
                label: '5kg',
                weight: 5.0,
                isSelected: weight == 5.0,
                onTap: () => onWeightChanged(5.0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickSelectButton(
                label: '10kg',
                weight: 10.0,
                isSelected: weight == 10.0,
                onTap: () => onWeightChanged(10.0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickSelectButton(
                label: '20kg',
                weight: 20.0,
                isSelected: weight == 20.0,
                onTap: () => onWeightChanged(20.0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickSelectButton(
                label: '30kg',
                weight: 30.0,
                isSelected: weight == 30.0,
                onTap: () => onWeightChanged(30.0),
              ),
            ),
          ],
        ),

        // Helper text
        if (showHelperText) ...[
          const SizedBox(height: 12),
          _WeightHelperText(weight: weight),
        ],
      ],
    );
  }

  IconData _getWeightIcon(double weight) {
    if (weight <= 5) return Icons.shopping_bag;
    if (weight <= 15) return Icons.work;
    return Icons.inbox;
  }

  Color _getWeightColor(double weight) {
    if (weight <= 5) return Colors.green;
    if (weight <= 15) return Colors.orange;
    if (weight <= 25) return Colors.deepOrange;
    return Colors.red;
  }
}

/// Quick select button for common weights
class _QuickSelectButton extends StatelessWidget {
  final String label;
  final double weight;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickSelectButton({
    required this.label,
    required this.weight,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getWeightColor(weight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(25) : Colors.grey.withAlpha(13),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withAlpha(51),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getWeightColor(double weight) {
    if (weight <= 5) return Colors.green;
    if (weight <= 15) return Colors.orange;
    if (weight <= 25) return Colors.deepOrange;
    return Colors.red;
  }
}

/// Helper text based on weight range
class _WeightHelperText extends StatelessWidget {
  final double weight;

  const _WeightHelperText({required this.weight});

  @override
  Widget build(BuildContext context) {
    final color = _getWeightColor(weight);
    final icon = _getIcon();
    final text = _getText();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: textDark.withAlpha(204),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getWeightColor(double weight) {
    if (weight <= 5) return Colors.green;
    if (weight <= 15) return Colors.orange;
    if (weight <= 25) return Colors.deepOrange;
    return Colors.red;
  }

  IconData _getIcon() {
    if (weight <= 5) return Icons.check_circle;
    if (weight <= 15) return Icons.info_outline;
    if (weight <= 25) return Icons.warning_amber;
    return Icons.error_outline;
  }

  String _getText() {
    if (weight <= 5) {
      return 'Gói nhẹ - Dễ vận chuyển, phù hợp với xe máy';
    } else if (weight <= 15) {
      return 'Gói trung bình - Cần chú ý khi vận chuyển';
    } else if (weight <= 25) {
      return 'Gói nặng - Cần shipper có kinh nghiệm';
    } else {
      return 'Gói rất nặng - Gần giới hạn tối đa (30kg)';
    }
  }
}
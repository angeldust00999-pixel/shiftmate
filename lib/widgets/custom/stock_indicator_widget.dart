import 'package:flutter/material.dart';

/// StockIndicatorWidget — Custom widget visual indikator level stok.
/// Menampilkan bar berwarna sesuai persentase stok (Orang 2).
class StockIndicatorWidget extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final String unit;

  const StockIndicatorWidget({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.unit,
  });

  double get _ratio =>
      maxQuantity > 0 ? (quantity / maxQuantity).clamp(0.0, 1.0) : 0.0;

  Color get _barColor {
    if (_ratio <= 0.0) return Colors.red.shade600;
    if (_ratio <= 0.2) return Colors.red.shade400;
    if (_ratio <= 0.5) return Colors.orange.shade400;
    return const Color(0xFF2ECC71);
  }

  String get _statusLabel {
    if (_ratio <= 0.0) return 'Habis';
    if (_ratio <= 0.2) return 'Kritis';
    if (_ratio <= 0.5) return 'Rendah';
    return 'Aman';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$quantity $unit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _barColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _barColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _barColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: _ratio,
            minHeight: 7,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(_barColor),
          ),
        ),
      ],
    );
  }
}

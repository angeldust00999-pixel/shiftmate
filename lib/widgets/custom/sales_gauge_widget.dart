import 'dart:math';
import 'package:flutter/material.dart';

class SalesGaugeWidget extends StatefulWidget {
  final double initialProgress;
  final String title;
  final String valueText;
  final String goalText;
  final String badgeText;
  final ValueChanged<double>? onChanged;

  const SalesGaugeWidget({
    super.key,
    this.initialProgress = 0.78,
    this.title = 'Weekly Target',
    this.valueText = '\$14,280',
    this.goalText = 'of \$18,300 goal',
    this.badgeText = 'On track ↑',
    this.onChanged,
  });

  @override
  State<SalesGaugeWidget> createState() => _SalesGaugeWidgetState();
}

class _SalesGaugeWidgetState extends State<SalesGaugeWidget> {
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress.clamp(0.0, 1.0);
  }

  void _updateProgress(DragUpdateDetails details) {
    setState(() {
      _progress = (_progress + details.delta.dx / 260).clamp(0.0, 1.0);
    });
    widget.onChanged?.call(_progress);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _updateProgress,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0x0CFFFFFF),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0x16FFFFFF)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: SalesGaugePainter(progress: _progress),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_progress * 100).round()}%',
                        style: const TextStyle(
                          color: Color(0xFFF8F6F2),
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'TARGET',
                        style: TextStyle(
                          color: Color(0xFF7B92BB),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xFF9AAED0),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.valueText,
                    style: const TextStyle(
                      color: Color(0xFFF8F6F2),
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.goalText,
                    style: const TextStyle(
                      color: Color(0xFF9AAED0),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x262ECC71),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      widget.badgeText,
                      style: const TextStyle(
                        color: Color(0xFF2ECC71),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Geser untuk ubah target',
                    style: TextStyle(
                      color: Color(0x997B92BB),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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
}

class SalesGaugePainter extends CustomPainter {
  final double progress;

  SalesGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = 135 * pi / 180;
    const sweepAngle = 270 * pi / 180;

    final backgroundPaint = Paint()
      ..color = const Color(0x253E5177)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0x552ECC71)
      ..strokeWidth = 19
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = const Color(0xFF2ECC71)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, glowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant SalesGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

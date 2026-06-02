import 'package:flutter/material.dart';
import '../../models/shift_model.dart';
import 'report_widgets.dart';

class ShiftCardWidget extends StatelessWidget {
  final ShiftModel shift;
  final VoidCallback onEdit;

  const ShiftCardWidget({
    super.key,
    required this.shift,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onEdit,
      child: ReportGlassCard(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: ReportColors.brown.withOpacity(0.28),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.badge_outlined,
                color: ReportColors.brownLight,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift.baristaName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ReportColors.cream,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${shift.date} • ${shift.startTime} - ${shift.endTime}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ReportColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ReportColors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                shift.position,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ReportColors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: ReportColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

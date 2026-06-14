import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/services/cycle_engine.dart';

/// A premium circular indicator representing the user's cycle.
///
/// Feeds an inner circle of colored dots representing the 5 phases,
/// and an outer progress bar filling white day by day.
class IrmaCycleCircularIndicator extends StatelessWidget {
  final double progress;
  final int currentDay;
  final int totalDays;
  final int periodDuration;
  final String phaseName;

  const IrmaCycleCircularIndicator({
    super.key,
    required this.progress,
    required this.currentDay,
    required this.totalDays,
    required this.periodDuration,
    required this.phaseName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 312,
      height: 312,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(312, 312),
            painter: CycleCircularIndicatorPainter(
              progress: progress,
              currentDay: currentDay,
              totalDays: totalDays,
              periodDuration: periodDuration,
            ),
          ),
          // Center Labels
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Day $currentDay',
                style: IrmaTextStyles.headingLgBold.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phaseName,
                style: IrmaTextStyles.paragraphXsMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CycleCircularIndicatorPainter extends CustomPainter {
  final double progress;
  final int currentDay;
  final int totalDays;
  final int periodDuration;

  CycleCircularIndicatorPainter({
    required this.progress,
    required this.currentDay,
    required this.totalDays,
    required this.periodDuration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double barRadius = 143.0; // Radius of outer circular progress bar (scaled 30%)
    final double dotsRadius = 110.5; // Radius of inner circle of dots (scaled 30%)

    // 1. Draw outer progress track (thin transparent white)
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(center, barRadius, trackPaint);

    // 2. Draw filled progress arc (white) day by day
    final progressPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0;

    double sweepAngle = 2 * math.pi * (currentDay - 1) / totalDays;
    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: barRadius),
        -math.pi / 2,
        sweepAngle.clamp(0.0, 2 * math.pi),
        false,
        progressPaint,
      );
    }

    // Draw Today marker (white circle) at the current day's position (aligns with current day dot)
    final double todayAngle = -math.pi / 2 + sweepAngle;
    final double todayX = center.dx + barRadius * math.cos(todayAngle);
    final double todayY = center.dy + barRadius * math.sin(todayAngle);

    final markerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Draw white circle with shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(Offset(todayX, todayY) + const Offset(0, 1), 7.0, shadowPaint);
    canvas.drawCircle(Offset(todayX, todayY), 7.0, markerPaint);

    // 3. Draw inner circle of dots representing the 5 phases of the cycle
    for (int i = 0; i < totalDays; i++) {
      final double angle = -math.pi / 2 + (2 * math.pi * i / totalDays);
      final double dotX = center.dx + dotsRadius * math.cos(angle);
      final double dotY = center.dy + dotsRadius * math.sin(angle);
      final dotOffset = Offset(dotX, dotY);

      // Determine the phase of day i + 1
      final String phase = CycleEngine.getPhaseForDay(i + 1, totalDays, periodDuration);
      
      // Map phase to its corresponding color
      final Color dotColor = switch (phase) {
        'Menstruation' => IrmaColors.orange40,
        'Follicular Phase' => IrmaColors.green50,
        'Ovulation' => IrmaColors.purple40,
        'Luteal Phase' => IrmaColors.brown60,
        _ => IrmaColors.yellow40, // Pre-menstrual Phase
      };

      final dotPaint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotOffset, 5.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CycleCircularIndicatorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currentDay != currentDay ||
        oldDelegate.totalDays != totalDays ||
        oldDelegate.periodDuration != periodDuration;
  }
}

/// A horizontal weekly strip calendar centered around today (±3 days).
class IrmaHorizontalWeekCalendar extends StatelessWidget {
  final Color themeColor;
  final Color tintColor;

  const IrmaHorizontalWeekCalendar({
    super.key,
    required this.themeColor,
    required this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final offset = index - 3;
        final date = now.add(Duration(days: offset));
        final isToday = offset == 0;
        final weekdayStr = weekdays[date.weekday - 1];

        if (isToday) {
          // Highlight capsule for today
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: tintColor,
              borderRadius: BorderRadius.circular(IrmaRadius.pill),
              border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${date.day}',
                  style: IrmaTextStyles.paragraphXsMedium.copyWith(color: themeColor),
                ),
                const SizedBox(height: 2),
                Text(
                  weekdayStr,
                  style: IrmaTextStyles.paragraphXsMedium.copyWith(color: themeColor),
                ),
              ],
            ),
          );
        } else {
          // Default styling for other days
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${date.day}',
                  style: IrmaTextStyles.paragraphXsMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  weekdayStr,
                  style: IrmaTextStyles.paragraphXsMedium.copyWith(color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}

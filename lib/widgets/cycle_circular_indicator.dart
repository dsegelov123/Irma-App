import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:irma/widgets/theme.dart';

/// A premium, animated circular indicator representing the user's cycle.
///
/// Feeds an outer track, an arc of progress, cycle day dots, Today highlight bubble,
/// and a dual-sine-wave animated liquid effect inside the center.
class IrmaCycleCircularIndicator extends StatefulWidget {
  final double progress;
  final int currentDay;
  final int totalDays;
  final Color themeColor;
  final Color tintColor;
  final String phaseName;

  const IrmaCycleCircularIndicator({
    super.key,
    required this.progress,
    required this.currentDay,
    required this.totalDays,
    required this.themeColor,
    required this.tintColor,
    required this.phaseName,
  });

  @override
  State<IrmaCycleCircularIndicator> createState() => _IrmaCycleCircularIndicatorState();
}

class _IrmaCycleCircularIndicatorState extends State<IrmaCycleCircularIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Repeating animation for the wave oscillation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(240, 240),
                painter: CycleCircularIndicatorPainter(
                  progress: widget.progress,
                  currentDay: widget.currentDay,
                  totalDays: widget.totalDays,
                  themeColor: widget.themeColor,
                  tintColor: widget.tintColor,
                  wavePhase: _animationController.value * 2 * math.pi,
                ),
              ),
              // Center Labels
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Day ${widget.currentDay}',
                    style: IrmaTextStyles.headingLgBold.copyWith(
                      color: IrmaColors.brown100,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.phaseName,
                    style: IrmaTextStyles.labelXs.copyWith(
                      color: IrmaColors.gray60,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CycleCircularIndicatorPainter extends CustomPainter {
  final double progress;
  final int currentDay;
  final int totalDays;
  final Color themeColor;
  final Color tintColor;
  final double wavePhase;

  CycleCircularIndicatorPainter({
    required this.progress,
    required this.currentDay,
    required this.totalDays,
    required this.themeColor,
    required this.tintColor,
    required this.wavePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = 112.0; // Radius of outer ring
    final double innerRadius = 80.0; // Radius of inner wave circle

    // 1. Draw background outer track ring
    final trackPaint = Paint()
      ..color = themeColor.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw active progress arc along track
    final progressPaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16.0;

    // Draw arc from top (-pi / 2) to the current progress
    double sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // 3. Draw inner wave-liquid circle
    final innerBgPaint = Paint()
      ..color = tintColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, innerBgPaint);

    // Clip to the inner circle for wave drawing
    canvas.save();
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.clipPath(clipPath);

    // Liquid height calculation based on progress (clamped to prevent empty/full flat lines)
    final double clampedProgress = progress.clamp(0.08, 0.92);
    final double waveHeight = center.dy + innerRadius * (1.0 - 2.0 * clampedProgress);
    final double waveAmplitude = 6.0;
    final double waveLength = innerRadius * 2.0;

    // Draw first wave (back wave)
    final backWavePaint = Paint()
      ..color = themeColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final backWavePath = Path();
    backWavePath.moveTo(center.dx - innerRadius, center.dy + innerRadius);
    backWavePath.lineTo(center.dx - innerRadius, waveHeight);
    
    for (double x = center.dx - innerRadius; x <= center.dx + innerRadius; x++) {
      final double relativeX = x - (center.dx - innerRadius);
      final double y = waveHeight + waveAmplitude * math.sin(wavePhase + (2 * math.pi * relativeX / waveLength));
      backWavePath.lineTo(x, y);
    }
    backWavePath.lineTo(center.dx + innerRadius, center.dy + innerRadius);
    backWavePath.close();
    canvas.drawPath(backWavePath, backWavePaint);

    // Draw second wave (front wave)
    final frontWavePaint = Paint()
      ..color = themeColor.withOpacity(0.35)
      ..style = PaintingStyle.fill;
    final frontWavePath = Path();
    frontWavePath.moveTo(center.dx - innerRadius, center.dy + innerRadius);
    frontWavePath.lineTo(center.dx - innerRadius, waveHeight);
    
    for (double x = center.dx - innerRadius; x <= center.dx + innerRadius; x++) {
      final double relativeX = x - (center.dx - innerRadius);
      // Offset phase by pi for overlapping wave depth
      final double y = waveHeight + waveAmplitude * math.sin(wavePhase + math.pi + (2 * math.pi * relativeX / waveLength));
      frontWavePath.lineTo(x, y);
    }
    frontWavePath.lineTo(center.dx + innerRadius, center.dy + innerRadius);
    frontWavePath.close();
    canvas.drawPath(frontWavePath, frontWavePaint);

    canvas.restore(); // Remove clipping

    // Thin inner border stroke
    final innerBorderPaint = Paint()
      ..color = themeColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, innerRadius, innerBorderPaint);

    // 4. Draw cycle day dots along outer track
    for (int i = 0; i < totalDays; i++) {
      final double angle = -math.pi / 2 + (2 * math.pi * i / totalDays);
      final double dotX = center.dx + radius * math.cos(angle);
      final double dotY = center.dy + radius * math.sin(angle);
      final dotOffset = Offset(dotX, dotY);

      if (i + 1 == currentDay) {
        // Today dot: draw a custom white bubble with a shadow and the day number
        
        // Shadow
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
        canvas.drawCircle(dotOffset + const Offset(0, 1.5), 13.0, shadowPaint);

        // White Bubble Fill
        final bubblePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(dotOffset, 13.0, bubblePaint);

        // Bubble Border (matching active color)
        final bubbleBorderPaint = Paint()
          ..color = themeColor.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(dotOffset, 13.0, bubbleBorderPaint);

        // Draw today day number inside bubble
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$currentDay',
            style: IrmaTextStyles.labelXs.copyWith(
              color: themeColor,
              fontWeight: FontWeight.w700,
              fontSize: 10.0,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          dotOffset - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      } else {
        // Normal dot
        final dotPaint = Paint()
          ..style = PaintingStyle.fill;

        if (i + 1 < currentDay) {
          // Visited past day
          dotPaint.color = themeColor;
        } else {
          // Future day
          dotPaint.color = themeColor.withOpacity(0.25);
        }

        canvas.drawCircle(dotOffset, 3.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CycleCircularIndicatorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currentDay != currentDay ||
        oldDelegate.totalDays != totalDays ||
        oldDelegate.themeColor != themeColor ||
        oldDelegate.tintColor != tintColor ||
        oldDelegate.wavePhase != wavePhase;
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
              border: Border.all(color: themeColor.withOpacity(0.3), width: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${date.day}',
                  style: IrmaTextStyles.labelMd.copyWith(color: themeColor),
                ),
                const SizedBox(height: 2),
                Text(
                  weekdayStr,
                  style: IrmaTextStyles.labelXs.copyWith(color: themeColor, fontSize: 10),
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
                  style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100),
                ),
                const SizedBox(height: 2),
                Text(
                  weekdayStr,
                  style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}

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
  final Color phaseColor;

  const IrmaCycleCircularIndicator({
    super.key,
    required this.progress,
    required this.currentDay,
    required this.totalDays,
    required this.periodDuration,
    required this.phaseName,
    required this.phaseColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 376,
      height: 376,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(376, 376),
            painter: CycleCircularIndicatorPainter(
              progress: progress,
              currentDay: currentDay,
              totalDays: totalDays,
              periodDuration: periodDuration,
            ),
          ),
          // Animated wave graphic behind the text
          _WaveGraphic(color: phaseColor),
          // Center Labels
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Day $currentDay',
                style: IrmaTextStyles.headingLgBold.copyWith(
                  color: IrmaColors.brown100,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phaseName,
                style: IrmaTextStyles.paragraphXsMedium.copyWith(
                  color: IrmaColors.brown80.withValues(alpha: 0.7),
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

// ─── Animated wave graphic ────────────────────────────────────────────────────

class _WaveGraphic extends StatefulWidget {
  final Color color;
  const _WaveGraphic({required this.color});

  @override
  State<_WaveGraphic> createState() => _WaveGraphicState();
}

class _WaveGraphicState extends State<_WaveGraphic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        size: const Size(212, 212),
        painter: _WaveGraphicPainter(
          color: widget.color,
          animValue: _controller.value,
        ),
      ),
    );
  }
}

class _WaveGraphicPainter extends CustomPainter {
  final Color color;
  final double animValue;

  _WaveGraphicPainter({required this.color, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    // Clip everything to the circle
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // White background
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);

    // Draw 3 wave layers — each at a different height and phase offset
    final List<_WaveLayer> layers = [
      _WaveLayer(heightFraction: 0.52, phaseShift: 0.0,               opacity: 0.22, amplitude: 9),
      _WaveLayer(heightFraction: 0.60, phaseShift: 2 * math.pi / 3,   opacity: 0.18, amplitude: 11),
      _WaveLayer(heightFraction: 0.68, phaseShift: 4 * math.pi / 3,   opacity: 0.15, amplitude: 8),
    ];

    for (final layer in layers) {
      final double baseY = size.height * layer.heightFraction;
      final double phase = animValue * 2 * math.pi + layer.phaseShift;

      final path = Path();
      path.moveTo(0, size.height);
      path.lineTo(0, baseY);

      for (double x = 0; x <= size.width; x += 1.5) {
        final double y = baseY +
            math.sin(x / size.width * 2.5 * math.pi + phase) * layer.amplitude +
            math.sin(x / size.width * 1.2 * math.pi + phase * 0.7) * (layer.amplitude * 0.4);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: layer.opacity)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_WaveGraphicPainter old) =>
      old.animValue != animValue || old.color != color;
}

class _WaveLayer {
  final double heightFraction;
  final double phaseShift;
  final double opacity;
  final double amplitude;
  const _WaveLayer({
    required this.heightFraction,
    required this.phaseShift,
    required this.opacity,
    required this.amplitude,
  });
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
    final double barRadius = 157.0; // Radius of outer circular progress bar
    final double dotsRadius = 132.5; // Radius of inner circle of dots

    // 1. Draw outer progress track (thin green with low opacity)
    final trackPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(center, barRadius, trackPaint);

    // 2. Draw filled progress arc (green50) day by day
    final progressPaint = Paint()
      ..color = IrmaColors.green50
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
      ..color = IrmaColors.green50
      ..style = PaintingStyle.fill;
    
    // Draw white circle with shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(Offset(todayX, todayY) + const Offset(0, 1), 7.0, shadowPaint);
    canvas.drawCircle(Offset(todayX, todayY), 7.0, markerPaint);

    // 3a. Draw menstruation arc (joined bar) for periodDuration days
    final menstruationPaint = Paint()
      ..color = IrmaColors.orange50
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: dotsRadius),
      -math.pi / 2,
      2 * math.pi * (periodDuration - 1) / totalDays,
      false,
      menstruationPaint,
    );

    // 3b. Draw pre-menstrual arc (last 5 days of cycle)
    // Replicate the phase boundary logic from CycleEngine.getPhaseForDay
    int ovulationDay = totalDays - 14;
    if (ovulationDay <= periodDuration) ovulationDay = periodDuration + 2;
    int preMenstrualStart = totalDays - 4;
    if (preMenstrualStart <= ovulationDay) preMenstrualStart = totalDays - 2;

    final double preMenstrualStartAngle =
        -math.pi / 2 + 2 * math.pi * (preMenstrualStart - 1) / totalDays;
    final double preMenstrualSweep =
        2 * math.pi * (totalDays - preMenstrualStart) / totalDays;

    final preMenstrualPaint = Paint()
      ..color = IrmaColors.yellow50
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: dotsRadius),
      preMenstrualStartAngle,
      preMenstrualSweep,
      false,
      preMenstrualPaint,
    );

    // 3c. Draw individual dots for all other phases
    for (int i = 0; i < totalDays; i++) {
      final String phase = CycleEngine.getPhaseForDay(i + 1, totalDays, periodDuration);
      if (phase == 'Menstruation') continue;       // covered by menstruation arc
      if (phase == 'Pre-menstrual Phase') continue; // covered by pre-menstrual arc

      final double angle = -math.pi / 2 + (2 * math.pi * i / totalDays);
      final double dotX = center.dx + dotsRadius * math.cos(angle);
      final double dotY = center.dy + dotsRadius * math.sin(angle);

      final Color dotColor = switch (phase) {
        'Follicular Phase' => IrmaColors.green50,
        'Ovulation'        => IrmaColors.purple50,
        'Luteal Phase'     => IrmaColors.yellow50,
        _                  => IrmaColors.yellow50,
      };

      canvas.drawCircle(Offset(dotX, dotY), 5.0, Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill);
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
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  const IrmaHorizontalWeekCalendar({
    super.key,
    required this.themeColor,
    required this.tintColor,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<String> weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Row(
      children: List.generate(7, (index) {
        final offset = index - 3;
        final date = now.add(Duration(days: offset));
        final isToday = date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
        final isSelected = date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
        final isHighlighted = isToday || isSelected;
        final weekdayStr = weekdays[date.weekday - 1];

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () => onDateSelected(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? themeColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isToday && !isSelected
                      ? Border.all(color: themeColor, width: 1.5)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weekdayStr,
                      style: IrmaTextStyles.labelSm.copyWith(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : IrmaColors.brown60,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: IrmaTextStyles.labelXl.copyWith(
                        color: isSelected ? Colors.white : IrmaColors.brown100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}


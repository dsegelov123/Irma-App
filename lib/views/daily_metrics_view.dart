import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:irma/services/tri_metric_engine.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/widgets/irma_top_bar.dart';

class DailyMetricsView extends StatefulWidget {
  final VoidCallback onBackPressed;
  const DailyMetricsView({super.key, required this.onBackPressed});

  @override
  State<DailyMetricsView> createState() => _DailyMetricsViewState();
}

class _DailyMetricsViewState extends State<DailyMetricsView> {
  late Map<String, dynamic> _metrics;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _metrics = TriMetricEngine.calculateMetricsForDate(DateTime.now());
    });
  }

  String _getBackgroundImage(int body, int mind, int soul) {
    // Dynamically change image depending on body/mind/soul scores in the future.
    // For now, use the quarantine home image.
    return 'assets/images/young-woman-being-quarantined-home.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final int body = _metrics['body'] as int? ?? 80;
    final int mind = _metrics['mind'] as int? ?? 80;
    final int soul = _metrics['soul'] as int? ?? 80;
    final imageAsset = _getBackgroundImage(body, mind, soul);

    // Mock variations for trend display (with index 5 matching today's actual scores)
    final List<int> bodyMock = [55, 75, 48, 82, 62, body, 70];
    final List<int> mindMock = [85, 50, 72, 58, 88, mind, 65];
    final List<int> soulMock = [42, 68, 52, 80, 60, soul, 78];

    // Calculate metrics history for 7 days (today is the 6th day, index 5)
    final today = DateTime.now();
    final List<Map<String, dynamic>> metricsHistory = [];
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i - 5));
      metricsHistory.add({
        'date': date,
        'body': bodyMock[i],
        'mind': mindMock[i],
        'soul': soulMock[i],
      });
    }

    return Scaffold(
      backgroundColor: IrmaColors.brown10,
      body: Stack(
        children: [
          // Background image with 75% black overlay: full width of screen, from top of screen to bottom of container
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + 80.0 + IrmaSpacing.lg + 376.0,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imageAsset),
                  alignment: Alignment.topCenter,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.75),
                    BlendMode.srcOver,
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 80.0),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 0.0,
                    right: 0.0,
                    top: IrmaSpacing.lg,
                    bottom: IrmaSpacing.lg + 80.0 + 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ThreeConcentricRadialBars(
                          bodyScore: body,
                          mindScore: mind,
                          soulScore: soul,
                        ),
                      ),
                      SmoothedLineChart(metricsHistory: metricsHistory),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IrmaTopBar(
              title: 'Wellness',
              onBackPressed: widget.onBackPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class ThreeConcentricRadialBars extends StatefulWidget {
  final int bodyScore;
  final int mindScore;
  final int soulScore;

  const ThreeConcentricRadialBars({
    super.key,
    required this.bodyScore,
    required this.mindScore,
    required this.soulScore,
  });

  @override
  State<ThreeConcentricRadialBars> createState() => _ThreeConcentricRadialBarsState();
}

class _ThreeConcentricRadialBarsState extends State<ThreeConcentricRadialBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bodyAnimation;
  late Animation<double> _mindAnimation;
  late Animation<double> _soulAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _bodyAnimation = Tween<double>(begin: 0, end: widget.bodyScore / 100.0).animate(curve);
    _mindAnimation = Tween<double>(begin: 0, end: widget.mindScore / 100.0).animate(curve);
    _soulAnimation = Tween<double>(begin: 0, end: widget.soulScore / 100.0).animate(curve);

    _controller.forward();
  }

  @override
  void didUpdateWidget(ThreeConcentricRadialBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bodyScore != widget.bodyScore ||
        oldWidget.mindScore != widget.mindScore ||
        oldWidget.soulScore != widget.soulScore) {
      _bodyAnimation = Tween<double>(
        begin: _bodyAnimation.value,
        end: widget.bodyScore / 100.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _mindAnimation = Tween<double>(
        begin: _mindAnimation.value,
        end: widget.mindScore / 100.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _soulAnimation = Tween<double>(
        begin: _soulAnimation.value,
        end: widget.soulScore / 100.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 376,
      height: 376,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(376, 376),
            painter: _ConcentricRadialBarsPainter(
              bodyProgress: _bodyAnimation.value,
              mindProgress: _mindAnimation.value,
              soulProgress: _soulAnimation.value,
            ),
          );
        },
      ),
    );
  }
}

class _ConcentricRadialBarsPainter extends CustomPainter {
  final double bodyProgress;
  final double mindProgress;
  final double soulProgress;

  _ConcentricRadialBarsPainter({
    required this.bodyProgress,
    required this.mindProgress,
    required this.soulProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 6.0;
    
    // Radii: outer (Body), middle (Mind), inner (Soul)
    const rBody = 150.0;
    const rMind = 126.0;
    const rSoul = 102.0;

    const startAngle = math.pi / 2; // 6 o'clock position (downwards)
    const maxSweepAngle = 3 * math.pi / 2; // 270 degrees clockwise to 3 o'clock position

    void drawSegmentedBar(double progress, double radius, Color progressColor) {
      final double intervalAngle = maxSweepAngle / 5;
      final double gapAngle = 12.0 / radius; // Visual gap width normalized for radius

      // 1. Draw track background segments (White)
      final trackPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 5; i++) {
        final double segStart = (i == 0)
            ? startAngle
            : startAngle + i * intervalAngle + gapAngle / 2;
        final double segEnd = (i == 4)
            ? startAngle + maxSweepAngle
            : startAngle + (i + 1) * intervalAngle - gapAngle / 2;
        final double segSweep = segEnd - segStart;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          segStart,
          segSweep,
          false,
          trackPaint,
        );
      }

      // 2. Draw progress segments and track end dot position
      double progressEndAngle = startAngle;
      bool hasProgress = false;

      if (progress > 0) {
        final progressPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        for (int i = 0; i < 5; i++) {
          double filledFraction = 0.0;
          if (progress >= (i + 1) * 0.2) {
            filledFraction = 1.0;
          } else if (progress > i * 0.2) {
            filledFraction = (progress - i * 0.2) / 0.2;
          }

          if (filledFraction > 0.0) {
            hasProgress = true;
            final double segStart = (i == 0)
                ? startAngle
                : startAngle + i * intervalAngle + gapAngle / 2;
            final double segEnd = (i == 4)
                ? startAngle + maxSweepAngle
                : startAngle + (i + 1) * intervalAngle - gapAngle / 2;
            final double segSweep = segEnd - segStart;

            final double drawSweep = segSweep * filledFraction;

            canvas.drawArc(
              Rect.fromCircle(center: center, radius: radius),
              segStart,
              drawSweep,
              false,
              progressPaint,
            );

            progressEndAngle = segStart + drawSweep;
          }
        }
      }

      // 3. Draw indicator dot at the end of progress
      if (hasProgress) {
        final dotX = center.dx + radius * math.cos(progressEndAngle);
        final double dotY = center.dy + radius * math.sin(progressEndAngle);

        final dotPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.fill;
        
        final shadowPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

        canvas.drawCircle(Offset(dotX, dotY) + const Offset(0, 1), 7.0, shadowPaint);
        canvas.drawCircle(Offset(dotX, dotY), 7.0, dotPaint);
      }
    }

    void drawLabel(String text, double radius) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: IrmaTextStyles.headingXsBold.copyWith(
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Position the label immediately to the right of the 6 o'clock position (x = center.dx, y = center.dy + radius)
      // Left coordinate of text is center.dx + 16.0 (to clear the 3.0px round cap and leave spacing)
      final x = center.dx + 16.0;
      final y = center.dy + radius - (textPainter.height / 2);

      textPainter.paint(canvas, Offset(x, y));
    }

    // Draw Soul (innermost)
    drawSegmentedBar(soulProgress, rSoul, IrmaColors.purple40);
    drawLabel('Soul', rSoul);

    // Draw Mind (middle)
    drawSegmentedBar(mindProgress, rMind, IrmaColors.green50);
    drawLabel('Mind', rMind);

    // Draw Body (outermost)
    drawSegmentedBar(bodyProgress, rBody, IrmaColors.orange50);
    drawLabel('Body', rBody);
  }

  @override
  bool shouldRepaint(covariant _ConcentricRadialBarsPainter oldDelegate) {
    return oldDelegate.bodyProgress != bodyProgress ||
        oldDelegate.mindProgress != mindProgress ||
        oldDelegate.soulProgress != soulProgress;
  }
}

class SmoothedLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> metricsHistory;

  const SmoothedLineChart({super.key, required this.metricsHistory});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: IrmaSpacing.lg,
      ),
      child: SizedBox(
        height: 260,
        child: CustomPaint(
          size: const Size(double.infinity, 260),
          painter: _SmoothedLineChartPainter(metricsHistory: metricsHistory),
        ),
      ),
    );
  }
}

class _SmoothedLineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> metricsHistory;

  _SmoothedLineChartPainter({required this.metricsHistory});

  @override
  void paint(Canvas canvas, Size size) {
    const double paddingLeft = 0.0;
    const double paddingRight = 0.0;
    const double paddingTop = 16.0;
    const double paddingBottom = 32.0;

    final double chartWidth = size.width;
    final double chartHeight = size.height - paddingTop - paddingBottom;
    final double stepX = chartWidth / 8.0;

    double getY(double val) => size.height - paddingBottom - (val / 100.0) * chartHeight;
    double getX(int i) => (i + 1) * stepX;

    // 1. Draw horizontal grid lines (from 0 to W, without numbers)
    final gridPaint = Paint()
      ..color = IrmaColors.brown20.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int percent in [0, 25, 50, 75, 100]) {
      final y = getY(percent.toDouble());
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw vertical today line highlight and X-axis labels
    final List<String> weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    for (int i = 0; i < 7; i++) {
      final x = getX(i);
      final item = metricsHistory[i];
      final DateTime date = item['date'] as DateTime;
      final String label = weekdays[date.weekday - 1];
      final isToday = (i == 5); // 6th day is today

      if (isToday) {
        final todayLinePaint = Paint()
          ..color = IrmaColors.brown30.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        
        // Draw dashed vertical line
        double currentY = paddingTop;
        const double dashLength = 4.0;
        const double gapLength = 4.0;
        while (currentY < size.height - paddingBottom) {
          canvas.drawLine(
            Offset(x, currentY),
            Offset(x, math.min(currentY + dashLength, size.height - paddingBottom)),
            todayLinePaint,
          );
          currentY += dashLength + gapLength;
        }

        // Draw "Today" label below the weekday
        final todayTextPainter = TextPainter(
          text: TextSpan(
            text: 'Today',
            style: IrmaTextStyles.labelXs.copyWith(
              color: IrmaColors.orange50,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        todayTextPainter.paint(canvas, Offset(x - todayTextPainter.width / 2, size.height - paddingBottom + 18));
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: IrmaTextStyles.labelSm.copyWith(
            color: isToday ? IrmaColors.orange50 : IrmaColors.brown60,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - paddingBottom + 6));
    }

    // 3. Draw smoothed lines
    void drawSmoothLine(List<double> values, Color color) {
      final linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;

      // Extrapolate values for edge points (virtual point at i=-1 is index 0, actual days are 1..7, virtual at i=7 is index 8)
      final List<double> allValues = List.filled(9, 0.0);
      for (int i = 0; i < 7; i++) {
        allValues[i + 1] = values[i];
      }
      // Linear extrapolation for left edge (index 0)
      allValues[0] = (2 * allValues[1] - allValues[2]).clamp(0.0, 100.0);
      // Linear extrapolation for right edge (index 8)
      allValues[8] = (2 * allValues[7] - allValues[6]).clamp(0.0, 100.0);

      final path = Path();
      // Start exactly at the left edge x = 0
      final double x0 = 0.0;
      final double y0 = getY(allValues[0]);
      path.moveTo(x0, y0);

      for (int i = 0; i < 8; i++) {
        final double xStart = i * stepX;
        final double yStart = getY(allValues[i]);
        final double xEnd = (i + 1) * stepX;
        final double yEnd = getY(allValues[i + 1]);

        final double controlX1 = xStart + stepX / 3;
        final double controlY1 = yStart;
        final double controlX2 = xEnd - stepX / 3;
        final double controlY2 = yEnd;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, xEnd, yEnd);
      }

      canvas.drawPath(path, linePaint);

    }

    final bodyValues = metricsHistory.map((m) => (m['body'] as int).toDouble()).toList();
    drawSmoothLine(bodyValues, IrmaColors.orange50);

    final mindValues = metricsHistory.map((m) => (m['mind'] as int).toDouble()).toList();
    drawSmoothLine(mindValues, IrmaColors.green50);

    final soulValues = metricsHistory.map((m) => (m['soul'] as int).toDouble()).toList();
    drawSmoothLine(soulValues, IrmaColors.purple40);
  }

  @override
  bool shouldRepaint(covariant _SmoothedLineChartPainter oldDelegate) {
    return oldDelegate.metricsHistory != metricsHistory;
  }
}

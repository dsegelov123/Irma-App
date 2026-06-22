import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/widgets/irma_top_bar.dart';
import 'package:irma/views/main_shell.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  void _goToPrevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  List<DateTime> _generateCalendarDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    // weekday: 1 = Monday, ..., 7 = Sunday
    final int prevMonthDaysCount = firstDay.weekday - 1;
    final int totalCellsNeeded = prevMonthDaysCount + lastDay.day;
    final int gridCellCount = totalCellsNeeded > 35 ? 42 : 35;

    final List<DateTime> days = [];

    // Previous month days
    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final prevMonthLastDay = DateTime(month.year, month.month, 0).day;
    for (int i = prevMonthDaysCount - 1; i >= 0; i--) {
      days.add(DateTime(prevMonth.year, prevMonth.month, prevMonthLastDay - i));
    }

    // Current month days
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    // Next month days (pad to dynamic cell count)
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final int remaining = gridCellCount - days.length;
    for (int i = 1; i <= remaining; i++) {
      days.add(DateTime(nextMonth.year, nextMonth.month, i));
    }

    return days;
  }

  String _formatMonthName(DateTime date) {
    final List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IrmaColors.brown10,
      body: Stack(
        children: [
          // ── Scrollable Content ─────────────────────────────────────
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full-width white background section containing Top Bar clearance and Calendar
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 100), // Clearance for Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
                        child: _buildMonthCalendar(context),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24), // Gap
                
                // Score Section (transparent background, showing brown10 underneath)
                _buildScoreSection(context),
                
                const SizedBox(height: 120), // Bottom nav bar clearance
              ],
            ),
          ),

          // ── Top Bar ────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IrmaTopBar(
              title: 'Calendar',
              onBackPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: IrmaBottomTabBar(
        activeTab: 0, // Belongs under the Home/Dashboard tab (index 0)
        onTap: (index) {
          // Pass the selected tab index back to the main shell so it can switch tabs
          Navigator.pop(context, index);
        },
        onLogSymptomsPressed: () {
          // Pass -1 back to trigger the "Log Symptoms" view in the main shell
          Navigator.pop(context, -1);
        },
      ),
    );
  }

  Widget _buildMonthCalendar(BuildContext context) {
    final List<String> weekdays = ['mo', 'tu', 'we', 'th', 'fr', 'sa', 'su'];
    final List<DateTime> gridDays = _generateCalendarDays(_currentMonth);
    final int rowCount = gridDays.length ~/ 7;

    final List<Widget> rows = [];
    for (int week = 0; week < rowCount; week++) {
      final List<Widget> weekDays = [];
      for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
        final DateTime date = gridDays[week * 7 + dayIndex];
        weekDays.add(
          Expanded(
            child: _buildDayCell(date),
          ),
        );
      }
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays,
        ),
      );
      if (week < rowCount - 1) {
        rows.add(const SizedBox(height: 4)); // 4px vertical gap between rows (matching SVG)
      }
    }

    return Center(
      child: Container(
        width: 314, // Exact width of the SVG
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // ── Navigation Header ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Month Button
                GestureDetector(
                  onTap: _goToPrevMonth,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: IrmaColors.brown20, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: IrmaColors.brown80,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                // Month Title
                Text(
                  _formatMonthName(_currentMonth),
                  style: IrmaTextStyles.headingSmBold.copyWith(
                    color: IrmaColors.brown100,
                  ),
                ),
                // Next Month Button
                GestureDetector(
                  onTap: _goToNextMonth,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: IrmaColors.brown20, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: IrmaColors.brown80,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Weekdays Labels Row ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekdays.map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: IrmaTextStyles.labelXsBold.copyWith(
                        color: IrmaColors.gray60,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16), // Spacing between weekdays and grid (matching SVG)

            // ── Days Grid ──────────────────────────────────────────────
            Column(
              children: rows,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final bool isCurrentMonth = date.month == _currentMonth.month && date.year == _currentMonth.year;
    
    // Cycle predictions for the date
    final cycleState = CycleEngine.getCurrentCycleState(targetDate: date);
    final bool isMenstruation = cycleState['phase'] == 'Menstruation';

    final bool isSelected = date.year == _selectedDate.year &&
                           date.month == _selectedDate.month &&
                           date.day == _selectedDate.day;

    final bool isToday = DateTime.now().year == date.year &&
                         DateTime.now().month == date.month &&
                         DateTime.now().day == date.day;

    // Apply decoration based on state
    BoxDecoration? decoration;
    if (isCurrentMonth && isMenstruation) {
      decoration = BoxDecoration(
        color: IrmaColors.orange10,
        borderRadius: BorderRadius.circular(8),
      );
    }

    if (isSelected) {
      decoration = BoxDecoration(
        color: isCurrentMonth && isMenstruation ? IrmaColors.orange10 : Colors.transparent,
        border: Border.all(color: IrmaColors.brown80, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      );
    }

    // Apply text style
    TextStyle textStyle;
    if (!isCurrentMonth) {
      // Days from other months
      textStyle = IrmaTextStyles.labelMd.copyWith(color: IrmaColors.gray30);
    } else if (isMenstruation) {
      textStyle = IrmaTextStyles.labelMdBold.copyWith(color: IrmaColors.orange50);
    } else {
      textStyle = IrmaTextStyles.labelMdBold.copyWith(color: IrmaColors.brown100);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          if (date.month != _currentMonth.month || date.year != _currentMonth.year) {
            _currentMonth = DateTime(date.year, date.month, 1);
          }
        });
      },
      child: Center(
        child: Container(
          width: 41.4, // Matches SVG cell width
          height: 40.3, // Matches SVG cell height
          decoration: decoration,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: textStyle,
              ),
              if (isToday) ...[
                const SizedBox(height: 2),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isMenstruation ? IrmaColors.orange50 : IrmaColors.brown80,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: 24),
      child: Row(
        children: [
          // Card 1: Body Score
          Expanded(
            child: _buildScoreCard(
              title: 'Body Score',
              backgroundColor: IrmaColors.green50,
              trackColor: IrmaColors.green40,
              activeColor: IrmaColors.green10,
              statusColor: IrmaColors.green20,
              shadowColor: IrmaColors.green50,
            ),
          ),
          const SizedBox(width: 16),
          // Card 2: Mind Score
          Expanded(
            child: _buildScoreCard(
              title: 'Mind Score',
              backgroundColor: IrmaColors.orange40,
              trackColor: IrmaColors.orange30,
              activeColor: IrmaColors.orange10,
              statusColor: IrmaColors.orange20,
              shadowColor: IrmaColors.orange40,
            ),
          ),
          const SizedBox(width: 16),
          // Card 3: Soul Score
          Expanded(
            child: _buildScoreCard(
              title: 'Soul Score',
              backgroundColor: IrmaColors.purple30,
              trackColor: IrmaColors.purple20,
              activeColor: IrmaColors.purple10,
              statusColor: IrmaColors.purple20,
              shadowColor: IrmaColors.purple30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard({
    required String title,
    required Color backgroundColor,
    required Color trackColor,
    required Color activeColor,
    required Color statusColor,
    required Color shadowColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth;
        final double scale = cardWidth / 163.0;
        final double cardHeight = 200.0 * scale;

        // Scaled layout dimensions
        final double heartWidth = 17.0 * scale;
        final double heartHeight = 16.0 * scale;
        final double labelFontSize = 11.2 * scale;
        final double labelGap = 12.0 * scale;

        final double circleSize = 120.0 * scale;
        final double strokeWidth = 10.0 * scale;
        final double radius = 55.0 * scale;

        final double scoreFontSize = 17.5 * scale;
        final double scoreGap = 8.2 * scale;
        final double statusFontSize = 10.5 * scale;

        final double shadowBlur = 32.0 * scale;
        final double shadowOffsetY = 16.0 * scale;
        final double cornerRadius = 32.0 * scale;

        final double paddingLeft = 20.5 * scale;
        final double paddingTop = 20.5 * scale;
        final double circleLeft = 21.5 * scale;
        final double circleTop = 64.0 * scale;

        return Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(cornerRadius),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(0.15),
                blurRadius: shadowBlur,
                offset: Offset(0, shadowOffsetY),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Heart icon & label
              Positioned(
                left: paddingLeft,
                top: paddingTop,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: heartWidth,
                      height: heartHeight,
                      child: CustomPaint(
                        painter: _HeartPainter(scale: scale),
                      ),
                    ),
                    SizedBox(width: labelGap),
                    Text(
                      title,
                      style: IrmaTextStyles.labelXsBold.copyWith(
                        color: Colors.white,
                        fontSize: labelFontSize,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              // Segmented score progress ring & content
              Positioned(
                left: circleLeft,
                top: circleTop,
                child: SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(circleSize, circleSize),
                        painter: _SegmentedScorePainter(
                          progress: 0.80,
                          radius: radius,
                          strokeWidth: strokeWidth,
                          trackColor: trackColor,
                          progressColor: activeColor,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '80',
                              style: IrmaTextStyles.headingSmBold.copyWith(
                                color: activeColor,
                                fontSize: scoreFontSize,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: scoreGap),
                            Text(
                              'Healthy',
                              style: IrmaTextStyles.labelXsBold.copyWith(
                                color: statusColor,
                                fontSize: statusFontSize,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeartPainter extends CustomPainter {
  final double scale;

  _HeartPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale
      ..strokeJoin = StrokeJoin.round;

    final heartPath = Path()
      ..moveTo(15.0 * scale, 9.0 * scale)
      ..lineTo(8.1471 * scale, 15.8529 * scale)
      ..cubicTo(7.7897 * scale, 16.2103 * scale, 7.2103 * scale, 16.2103 * scale, 6.8529 * scale, 15.8529 * scale)
      ..lineTo(0.0 * scale, 9.0 * scale)
      ..cubicTo(-1.933 * scale, 7.067 * scale, -1.933 * scale, 3.933 * scale, 0.0 * scale, 2.0 * scale)
      ..cubicTo(1.933 * scale, 0.067 * scale, 5.067 * scale, 0.067 * scale, 7.0 * scale, 2.0 * scale)
      ..lineTo(7.5 * scale, 2.5 * scale)
      ..lineTo(8.0 * scale, 2.0 * scale)
      ..cubicTo(9.933 * scale, 0.067 * scale, 13.067 * scale, 0.067 * scale, 15.0 * scale, 2.0 * scale)
      ..cubicTo(16.933 * scale, 3.933 * scale, 16.933 * scale, 7.067 * scale, 15.0 * scale, 9.0 * scale)
      ..close();

    canvas.translate((size.width - 17.0 * scale) / 2, (size.height - 16.0 * scale) / 2);
    canvas.drawPath(heartPath, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) => oldDelegate.scale != scale;
}

class _SegmentedScorePainter extends CustomPainter {
  final double progress;
  final double radius;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  _SegmentedScorePainter({
    required this.progress,
    required this.radius,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final activePaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final inactivePaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const double degToRad = math.pi / 180.0;
    const double segmentSweep = 60.0 * degToRad; // 60 degrees sweep
    const double gapSweep = 12.0 * degToRad;    // 12 degrees gap
    const double totalSegmentAngle = segmentSweep + gapSweep; // 72 degrees total step

    final int totalSegments = 5;
    final int activeSegments = (progress * totalSegments).round();

    for (int i = 0; i < totalSegments; i++) {
      final double startAngle = -90.0 * degToRad + i * totalSegmentAngle;
      final Paint paint = (i < activeSegments) ? activePaint : inactivePaint;
      canvas.drawArc(rect, startAngle, segmentSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedScorePainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

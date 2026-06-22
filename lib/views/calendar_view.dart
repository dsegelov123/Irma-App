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
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IrmaColors.brown10,
      body: Stack(
        children: [
          // ── Scrollable Content ─────────────────────────────────────
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100), // Clearance for Top Bar
                  
                  // Month Calendar Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
                    child: _buildMonthCalendar(context),
                  ),
                  
                  const SizedBox(height: 24), // Gap
                  
                  // Score Section (full width container with white background)
                  _buildScoreSection(context),
                  
                  const SizedBox(height: 120), // Bottom nav bar clearance
                ],
              ),
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
    final List<String> weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
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
          const SizedBox(height: 12),
          const Divider(color: IrmaColors.brown20, height: 1),
          const SizedBox(height: 12),

          // ── Days Grid ──────────────────────────────────────────────
          Column(
            children: rows,
          ),
        ],
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

    // Apply color & text rules based on state
    BoxDecoration? decoration;
    TextStyle textStyle;

    if (!isCurrentMonth) {
      // Days from other months
      textStyle = IrmaTextStyles.labelMd.copyWith(color: IrmaColors.gray30);
    } else if (isMenstruation) {
      // Menstrual phase highlights: orange10 bg, orange50 text
      decoration = BoxDecoration(
        color: IrmaColors.orange10,
        borderRadius: BorderRadius.circular(8),
      );
      textStyle = IrmaTextStyles.labelMdBold.copyWith(color: IrmaColors.orange50);
    } else if (isSelected) {
      // Selected day border outline
      decoration = BoxDecoration(
        border: Border.all(color: IrmaColors.brown80, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      );
      textStyle = IrmaTextStyles.labelMdBold.copyWith(color: IrmaColors.brown100);
    } else {
      // Normal day in current month
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
          width: 40,
          height: 40,
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
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
        child: Row(
          children: [
            _buildScoreCard(),
            const SizedBox(width: 8),
            _buildScoreCard(),
            const SizedBox(width: 8),
            _buildScoreCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: 163,
      height: 200,
      decoration: BoxDecoration(
        color: IrmaColors.green50,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: IrmaColors.green50.withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Heart icon & label "Freud Score"
          Positioned(
            left: 20.5,
            top: 20.5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 17,
                  height: 16,
                  child: CustomPaint(
                    painter: _HeartPainter(),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Freud Score',
                  style: IrmaTextStyles.labelXsBold.copyWith(
                    color: Colors.white,
                    fontSize: 11.2,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Segmented score progress ring & content
          Positioned(
            left: 21.5,
            top: 64.0,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: _SegmentedScorePainter(
                      trackColor: IrmaColors.green40,
                      progressColor: IrmaColors.green10,
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
                            color: IrmaColors.green10,
                            fontSize: 17.5,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8.2),
                        Text(
                          'Healthy',
                          style: IrmaTextStyles.labelXsBold.copyWith(
                            color: IrmaColors.green20,
                            fontSize: 10.5,
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
  }
}

class _HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;

    final heartPath = Path()
      ..moveTo(15.0, 9.0)
      ..lineTo(8.1471, 15.8529)
      ..cubicTo(7.7897, 16.2103, 7.2103, 16.2103, 6.8529, 15.8529)
      ..lineTo(0.0, 9.0)
      ..cubicTo(-1.933, 7.067, -1.933, 3.933, 0.0, 2.0)
      ..cubicTo(1.933, 0.067, 5.067, 0.067, 7.0, 2.0)
      ..lineTo(7.5, 2.5)
      ..lineTo(8.0, 2.0)
      ..cubicTo(9.933, 0.067, 13.067, 0.067, 15.0, 2.0)
      ..cubicTo(16.933, 3.933, 16.933, 7.067, 15.0, 9.0)
      ..close();

    canvas.translate((size.width - 17) / 2, (size.height - 16) / 2);
    canvas.drawPath(heartPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SegmentedScorePainter extends CustomPainter {
  final Color trackColor;
  final Color progressColor;

  _SegmentedScorePainter({
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 10.0;
    final double radius = 55.0;
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

    // Arc 1 (active)
    canvas.drawArc(rect, -90 * degToRad, 135 * degToRad, false, activePaint);
    // Arc 2 (active)
    canvas.drawArc(rect, 60 * degToRad, 60 * degToRad, false, activePaint);
    // Arc 3 (inactive)
    canvas.drawArc(rect, 135 * degToRad, 75 * degToRad, false, inactivePaint);
    // Arc 4 (inactive)
    canvas.drawArc(rect, 225 * degToRad, 30 * degToRad, false, inactivePaint);
  }

  @override
  bool shouldRepaint(covariant _SegmentedScorePainter oldDelegate) {
    return oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

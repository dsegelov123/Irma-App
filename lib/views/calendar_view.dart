import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/services/tri_metric_engine.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/widgets/irma_top_bar.dart';
import 'package:irma/views/main_shell.dart';
import 'package:irma/views/add_log_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
                // Top Bar clearance (brown10 background shows here)
                SizedBox(height: MediaQuery.of(context).padding.top + 100),

                // Contained white calendar card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(IrmaRadius.stat),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: IrmaSpacing.md),
                    child: _buildMonthCalendar(context),
                  ),
                ),
                
                const SizedBox(height: 24), // Gap
                
                // Score Section (transparent background, showing brown10 underneath)
                _buildScoreSection(context),
                
                const SizedBox(height: 24), // Gap
                
                // Daily Roundup Section (contained white card)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(IrmaRadius.stat),
                    ),
                    child: _buildDailyRoundupSection(context),
                  ),
                ),
                
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double scale = availableWidth / 314.0;

        final List<String> weekdays = ['mo', 'tu', 'we', 'th', 'fr', 'sa', 'su'];
        final List<DateTime> gridDays = _generateCalendarDays(_currentMonth);
        final int rowCount = gridDays.length ~/ 7;

        final double cellGap = 4.0 * scale;

        final List<Widget> rows = [];
        for (int week = 0; week < rowCount; week++) {
          final List<Widget> weekDays = [];
          for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
            final DateTime date = gridDays[week * 7 + dayIndex];
            weekDays.add(
              _buildDayCell(date, scale),
            );
            if (dayIndex < 6) {
              weekDays.add(SizedBox(width: cellGap));
            }
          }
          rows.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: weekDays,
            ),
          );
          if (week < rowCount - 1) {
            rows.add(SizedBox(height: cellGap));
          }
        }

        final double chevronSize = 32.0 * scale;
        final double iconSize = 18.0 * scale;
        final double titleFontSize = 20.0 * scale;
        final double headerGap = 20.0 * scale;
        final double weekdayFontSize = 10.0 * scale;
        final double weekdayGap = 16.0 * scale;

        return Container(
          width: availableWidth,
          padding: EdgeInsets.symmetric(vertical: 16 * scale),
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
                      width: chevronSize,
                      height: chevronSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8 * scale),
                        border: Border.all(color: IrmaColors.brown20, width: 1.5 * scale),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: IrmaColors.brown80,
                          size: iconSize,
                        ),
                      ),
                    ),
                  ),
                  // Month Title
                  Text(
                    _formatMonthName(_currentMonth),
                    style: IrmaTextStyles.headingSmBold.copyWith(
                      color: IrmaColors.brown100,
                      fontSize: titleFontSize,
                    ),
                  ),
                  // Next Month Button
                  GestureDetector(
                    onTap: _goToNextMonth,
                    child: Container(
                      width: chevronSize,
                      height: chevronSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8 * scale),
                        border: Border.all(color: IrmaColors.brown20, width: 1.5 * scale),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: IrmaColors.brown80,
                          size: iconSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: headerGap),

              // ── Weekdays Labels Row ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (index) {
                  final String day = weekdays[index];
                  final double cellWidth = 41.428 * scale;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: cellWidth,
                        child: Center(
                          child: Text(
                            day,
                            style: IrmaTextStyles.labelXsBold.copyWith(
                              color: IrmaColors.gray60,
                              fontSize: weekdayFontSize,
                            ),
                          ),
                        ),
                      ),
                      if (index < 6) SizedBox(width: cellGap),
                    ],
                  );
                }),
              ),
              SizedBox(height: weekdayGap),

              // ── Days Grid ──────────────────────────────────────────────
              Column(
                children: rows,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayCell(DateTime date, double scale) {
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

    // Check if a log entry exists for this date
    final String logKey = 'log_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final bool hasLog = isCurrentMonth && StorageService.settingsBox.get(logKey) != null;

    final double cornerRadius = 8.0 * scale;

    // Apply decoration based on state
    BoxDecoration? decoration;
    if (isCurrentMonth && isMenstruation) {
      decoration = BoxDecoration(
        color: IrmaColors.orange30,
        borderRadius: BorderRadius.circular(cornerRadius),
      );
    }

    if (isSelected) {
      decoration = BoxDecoration(
        color: isCurrentMonth && isMenstruation ? IrmaColors.orange30 : Colors.transparent,
        border: Border.all(color: IrmaColors.brown80, width: 1.5 * scale),
        borderRadius: BorderRadius.circular(cornerRadius),
      );
    }

    // Apply text style
    TextStyle textStyle;
    if (!isCurrentMonth) {
      // Days from other months
      textStyle = IrmaTextStyles.labelMd.copyWith(
        color: IrmaColors.gray30,
        fontSize: 11.0 * scale,
      );
    } else if (isMenstruation) {
      textStyle = IrmaTextStyles.labelMdBold.copyWith(
        color: IrmaColors.orange70,
        fontSize: 11.0 * scale,
      );
    } else {
      textStyle = IrmaTextStyles.labelMdBold.copyWith(
        color: IrmaColors.brown100,
        fontSize: 11.0 * scale,
      );
    }

    final double cellWidth = 41.428 * scale;
    final double cellHeight = 40.3 * scale;
    final double todayDotSize = 4.0 * scale;
    final double todayDotGap = 2.0 * scale;
    final double logDotSize = 4.0 * scale;

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
          width: cellWidth,
          height: cellHeight,
          decoration: decoration,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Date number — always perfectly centred
              Text(
                '${date.day}',
                style: textStyle,
              ),
              // Green log dot — pinned near top
              if (hasLog)
                Positioned(
                  top: 3 * scale,
                  child: Container(
                    width: logDotSize,
                    height: logDotSize,
                    decoration: const BoxDecoration(
                      color: IrmaColors.green50,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              // Today dot — pinned near bottom
              if (isToday)
                Positioned(
                  bottom: 3 * scale,
                  child: Container(
                    width: todayDotSize,
                    height: todayDotSize,
                    decoration: BoxDecoration(
                      color: isMenstruation ? IrmaColors.orange70 : IrmaColors.brown80,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    final metrics = TriMetricEngine.calculateMetricsForDate(_selectedDate);
    final body = metrics['body'] as int? ?? 80;
    final mind = metrics['mind'] as int? ?? 80;
    final soul = metrics['soul'] as int? ?? 80;
    final bodyTier = metrics['body_tier'] as String? ?? 'Moderate';
    final mindTier = metrics['mind_tier'] as String? ?? 'Moderate';
    final soulTier = metrics['soul_tier'] as String? ?? 'Moderate';

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
              score: body,
              status: bodyTier,
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
              score: mind,
              status: mindTier,
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
              score: soul,
              status: soulTier,
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
    required int score,
    required String status,
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
                          progress: score / 100.0,
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
                              '$score',
                              style: IrmaTextStyles.headingSmBold.copyWith(
                                color: activeColor,
                                fontSize: scoreFontSize,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: scoreGap),
                            Text(
                              status,
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

  void _openLogEntryEditor() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddLogView(
          initialDate: _selectedDate,
          onLogSaved: () => Navigator.pop(context),
          onBackPressed: () => Navigator.pop(context),
        ),
      ),
    );
    setState(() {});
  }

  String _formatDateWithOrdinal(DateTime date) {
    final day = date.day;
    String suffix = 'th';
    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1: suffix = 'st'; break;
        case 2: suffix = 'nd'; break;
        case 3: suffix = 'rd'; break;
        default: suffix = 'th';
      }
    }
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '$day$suffix ${months[date.month - 1]} ${date.year}';
  }

  String _formatWeight(double? value, String unit, double? pounds) {
    if (value == null) return '';
    if (unit == 'kg') {
      return '${value.toStringAsFixed(1)} kg';
    } else if (unit == 'lbs') {
      return '${value.toStringAsFixed(1)} lbs';
    } else if (unit == 'st;lb') {
      final st = value.toInt();
      final lb = pounds?.toInt() ?? 0;
      return '$st st $lb lb';
    }
    return '${value.toStringAsFixed(1)} kg';
  }

  Widget _buildOptionCircle(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: IrmaColors.brown10,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 16,
          color: IrmaColors.orange50,
        ),
      ),
    );
  }

  TableRow _buildRoundupRow(String title, List<Widget> icons) {
    final List<Widget> spacedIcons = [];
    for (int i = 0; i < icons.length; i++) {
      spacedIcons.add(icons[i]);
      if (i < icons.length - 1) {
        spacedIcons.add(const SizedBox(width: 8));
      }
    }
    return _buildRoundupRowWidget(
      title,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: spacedIcons,
      ),
    );
  }

  TableRow _buildRoundupRowWidget(String title, Widget valueWidget) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: IrmaTextStyles.labelMd.copyWith(
                color: IrmaColors.brown80,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: valueWidget,
        ),
      ],
    );
  }

  Widget _buildDailyRoundupSection(BuildContext context) {
    final box = StorageService.settingsBox;
    final String dateKey = 'log_${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final logData = box.get(dateKey);

    List<String> symptoms = [];
    String note = '';
    double? weightValue = null;
    String weightUnit = 'kg';
    double? weightPounds = null;

    if (logData != null && logData is Map) {
      final List<dynamic>? list = logData['symptoms'] as List<dynamic>?;
      if (list != null) {
        symptoms = list.map((e) => e.toString()).toList();
      }
      note = logData['note'] as String? ?? '';
      weightValue = logData['weight_value'] as double?;
      weightUnit = logData['weight_unit'] as String? ?? 'kg';
      weightPounds = logData['weight_pounds'] as double?;
    }

    final Map<String, List<String>> categorySelections = {};
    for (final s in symptoms) {
      final parts = s.split(': ');
      if (parts.length == 2) {
        final category = parts[0];
        final option = parts[1];
        if (option.isNotEmpty && option != 'None' && option != 'Typical') {
          categorySelections.putIfAbsent(category, () => []).add(option);
        }
      }
    }

    final List<TableRow> tableRows = [];

    if (categorySelections.containsKey('Mood')) {
      final List<Widget> moodIcons = [];
      for (final option in categorySelections['Mood']!) {
        final iconKey = 'Mood: $option';
        final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.smiley();
        moodIcons.add(_buildOptionCircle(icon));
      }
      tableRows.add(_buildRoundupRow('Mood', moodIcons));
    }

    if (categorySelections.containsKey('Menstrual Flow')) {
      final option = categorySelections['Menstrual Flow']!.first;
      final iconKey = 'Menstrual Flow: $option';
      final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.drop();
      tableRows.add(_buildRoundupRow('Menstrual Flow', [_buildOptionCircle(icon)]));
    }

    if (categorySelections.containsKey('Abdominal Cramps')) {
      final option = categorySelections['Abdominal Cramps']!.first;
      final iconKey = 'Abdominal Cramps: $option';
      final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.sparkle();
      tableRows.add(_buildRoundupRow('Cramps', [_buildOptionCircle(icon)]));
    }

    if (categorySelections.containsKey('Somatic Pain')) {
      final List<Widget> painIcons = [];
      for (final option in categorySelections['Somatic Pain']!) {
        final iconKey = 'Somatic Pain: $option';
        final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.pulse();
        painIcons.add(_buildOptionCircle(icon));
      }
      tableRows.add(_buildRoundupRow('Somatic Pain', painIcons));
    }

    if (categorySelections.containsKey('Physical Energy')) {
      final option = categorySelections['Physical Energy']!.first;
      final iconKey = 'Physical Energy: $option';
      final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.batteryMedium();
      tableRows.add(_buildRoundupRow('Energy', [_buildOptionCircle(icon)]));
    }

    if (categorySelections.containsKey('Gastrointestinal Activity')) {
      final List<Widget> giIcons = [];
      for (final option in categorySelections['Gastrointestinal Activity']!) {
        final iconKey = 'Gastrointestinal Activity: $option';
        final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.wind();
        giIcons.add(_buildOptionCircle(icon));
      }
      tableRows.add(_buildRoundupRow('Digestive', giIcons));
    }

    if (categorySelections.containsKey('Sleep Quality')) {
      final option = categorySelections['Sleep Quality']!.first;
      final iconKey = 'Sleep Quality: $option';
      final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.moon();
      tableRows.add(_buildRoundupRow('Sleep', [_buildOptionCircle(icon)]));
    }

    if (categorySelections.containsKey('Mental Focus')) {
      final option = categorySelections['Mental Focus']!.first;
      final iconKey = 'Mental Focus: $option';
      final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.target();
      tableRows.add(_buildRoundupRow('Focus', [_buildOptionCircle(icon)]));
    }

    if (categorySelections.containsKey('Exercise')) {
      final option = categorySelections['Exercise']!.first;
      final iconKey = 'Exercise: $option';
      final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.bicycle();
      tableRows.add(_buildRoundupRow('Exercise', [_buildOptionCircle(icon)]));
    }

    if (categorySelections.containsKey('Libido')) {
      final option = categorySelections['Libido']!.first;
      final iconKey = 'Libido: $option';
      final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.heart();
      tableRows.add(_buildRoundupRow('Libido', [_buildOptionCircle(icon)]));
    }

    if (categorySelections.containsKey('Sexual Activity')) {
      final List<Widget> sexIcons = [];
      for (final option in categorySelections['Sexual Activity']!) {
        final iconKey = 'Sexual Activity: $option';
        final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.users();
        sexIcons.add(_buildOptionCircle(icon));
      }
      tableRows.add(_buildRoundupRow('Sexual Activity', sexIcons));
    }

    if (categorySelections.containsKey('Social Bandwidth')) {
      final option = categorySelections['Social Bandwidth']!.first;
      final iconKey = 'Social Bandwidth: $option';
      final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.user();
      tableRows.add(_buildRoundupRow('Social', [_buildOptionCircle(icon)]));
    }

    if (categorySelections.containsKey('Appetite')) {
      final List<Widget> appetiteIcons = [];
      for (final option in categorySelections['Appetite']!) {
        final iconKey = 'Appetite: $option';
        final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.cookie();
        appetiteIcons.add(_buildOptionCircle(icon));
      }
      tableRows.add(_buildRoundupRow('Appetite', appetiteIcons));
    }

    if (categorySelections.containsKey('Alcohol')) {
      final option = categorySelections['Alcohol']!.first;
      final iconKey = 'Alcohol: $option';
      final icon = AddLogView.symptomIcons[iconKey] ?? PhosphorIcons.beerBottle();
      tableRows.add(_buildRoundupRow('Alcohol', [_buildOptionCircle(icon)]));
    }

    if (weightValue != null) {
      tableRows.add(
        _buildRoundupRowWidget(
          'Weight',
          Row(
            children: [
              _buildOptionCircle(PhosphorIcons.scales()),
              const SizedBox(width: 8),
              Text(
                _formatWeight(weightValue, weightUnit, weightPounds),
                style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.brown100),
              ),
            ],
          ),
        ),
      );
    }

    if (logData != null) {
      tableRows.add(
        _buildRoundupRowWidget(
          'Water',
          Row(
            children: [
              _buildOptionCircle(PhosphorIcons.drop()),
              const SizedBox(width: 8),
              Text(
                '750 ml / 2000 ml',
                style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.brown100),
              ),
            ],
          ),
        ),
      );
    }

    if (note.isNotEmpty) {
      tableRows.add(
        _buildRoundupRowWidget(
          'Note',
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildOptionCircle(PhosphorIcons.note()),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note,
                  style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.brown100),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (logData == null) {
      return Padding(
        padding: const EdgeInsets.all(IrmaSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date title
            Text(
              _formatDateWithOrdinal(_selectedDate),
              style: IrmaTextStyles.headingSmBold.copyWith(
                color: IrmaColors.brown100,
              ),
            ),
            const SizedBox(height: 16),
            // Purple10 inner box with Irma image
            ClipRRect(
              borderRadius: BorderRadius.circular(IrmaRadius.log),
              child: Container(
                width: double.infinity,
                height: 140,
                color: IrmaColors.purple10,
                child: Stack(
                  children: [
                    // Text — vertically centred
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            FractionallySizedBox(
                              widthFactor: 0.65,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'It seems that there\'s no daily log recorded for this day.',
                                style: IrmaTextStyles.paraSm.copyWith(
                                  color: IrmaColors.purple50,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FractionallySizedBox(
                              widthFactor: 0.65,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Don\'t forget to fill it out for me',
                                style: IrmaTextStyles.paraSm.copyWith(
                                  color: IrmaColors.purple50,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Irma — bottom right overlay
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        'assets/images/irma_reminder2.png',
                        height: 130,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
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


    return Padding(
      padding: const EdgeInsets.all(IrmaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateWithOrdinal(_selectedDate),
                style: IrmaTextStyles.headingSmBold.copyWith(
                  color: IrmaColors.brown100,
                ),
              ),
              GestureDetector(
                onTap: _openLogEntryEditor,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: IrmaColors.brown10,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.edit_outlined,
                      color: IrmaColors.brown80,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FractionColumnWidth(0.3),
              1: FractionColumnWidth(0.7),
            },
            children: tableRows,
          ),
        ],
      ),
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

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:irma/services/tri_metric_engine.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/services/advice_service.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/widgets/irma_top_bar.dart';
import 'package:irma/widgets/cycle_circular_indicator.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DailyMetricsView extends StatefulWidget {
  final VoidCallback onBackPressed;
  const DailyMetricsView({super.key, required this.onBackPressed});

  @override
  State<DailyMetricsView> createState() => _DailyMetricsViewState();
}

class _DailyMetricsViewState extends State<DailyMetricsView> {
  late Map<String, dynamic> _metrics;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _metrics = TriMetricEngine.calculateMetricsForDate(_selectedDate);
    });
  }

  Widget _buildSubMetricCard({
    required String title,
    required int score,
    required Color backgroundColor,
    required Color trackColor,
    required Color activeColor,
    required Color statusColor,
    required Color shadowColor,
  }) {
    final String status = TriMetricEngine.getTierForScore(score);

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

  @override
  Widget build(BuildContext context) {
    // Radial chart: scores for the selected date
    final int body = _metrics['body'] as int? ?? 80;
    final int mind = _metrics['mind'] as int? ?? 80;
    final int soul = _metrics['soul'] as int? ?? 80;
    final subMetrics = _metrics['sub_metrics'] as Map<String, dynamic>? ?? {};

    // Line chart: always anchored to today regardless of calendar selection
    final today = DateTime.now();
    final int currentDay = CycleEngine.getCycleDay(targetDate: today);
    final int averageLength = CycleEngine.getAverageCycleLength().round();
    final int numDays = math.max(averageLength, currentDay);

    final starts = CycleEngine.getCycleStarts();
    final DateTime cycleStart = starts.isNotEmpty 
        ? starts.last 
        : today.subtract(Duration(days: currentDay - 1));
    final DateTime anchor = DateTime(cycleStart.year, cycleStart.month, cycleStart.day);

    final List<Map<String, dynamic>> metricsHistory = [];
    for (int i = 0; i < numDays; i++) {
      final date = anchor.add(Duration(days: i));
      final dateMetrics = TriMetricEngine.calculateMetricsForDate(date);
      metricsHistory.add({
        'date': date,
        'cycleDay': i + 1,
        'isToday': (i + 1 == currentDay),
        'body': dateMetrics['body'] as int? ?? 80,
        'mind': dateMetrics['mind'] as int? ?? 80,
        'soul': dateMetrics['soul'] as int? ?? 80,
      });
    }

    return Scaffold(
      backgroundColor: IrmaColors.brown10,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 80.0),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: IrmaSpacing.lg,
                    bottom: IrmaSpacing.lg + 80.0 + 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // White card behind the radial bar graph
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(IrmaRadius.stat),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: IrmaSpacing.lg,
                          ),
                          child: Center(
                            child: ThreeConcentricRadialBars(
                              bodyScore: body,
                              mindScore: mind,
                              soulScore: soul,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: IrmaSpacing.lg),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
                        child: IrmaHorizontalWeekCalendar(
                          themeColor: IrmaColors.orange50,
                          tintColor: IrmaColors.orange10,
                          selectedDate: _selectedDate,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                              _metrics = TriMetricEngine.calculateMetricsForDate(date);
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: IrmaSpacing.lg),
                      // Irma's advice section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Irma's advice",
                              style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100),
                            ),
                            const SizedBox(height: IrmaSpacing.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: const BoxDecoration(
                                    color: IrmaColors.brown20,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16.0),
                                      topRight: Radius.circular(16.0),
                                      bottomRight: Radius.circular(16.0),
                                      bottomLeft: Radius.zero,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: IrmaColors.brown10,
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: AssetImage('assets/images/irma_title_profile.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                                          child: Text(
                                            AdviceService.generateMetricsAdvice(body, mind, soul),
                                            style: IrmaTextStyles.labelMdBold.copyWith(
                                              color: IrmaColors.brown100.withOpacity(0.64),
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomPaint(
                                  size: const Size(12, 12),
                                  painter: _BubbleTailPainter(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: IrmaSpacing.lg),
                      // 1. Body Sub-metrics Display Section
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: IrmaSpacing.lg,
                          vertical: IrmaSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: IrmaColors.green50,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      PhosphorIcons.heart(PhosphorIconsStyle.fill),
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Body Scores",
                                        style: IrmaTextStyles.labelLgBold.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: IrmaColors.brown80,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        TriMetricEngine.getTierForScore(body),
                                        style: IrmaTextStyles.labelMdBold.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: IrmaColors.brown60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CustomPaint(
                                        size: const Size(64, 64),
                                        painter: _CategoryScoreRingPainter(
                                          progress: body / 100.0,
                                          trackColor: IrmaColors.green10,
                                          progressColor: IrmaColors.green50,
                                          strokeWidth: 10.0,
                                        ),
                                      ),
                                      Text(
                                        '$body',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: IrmaColors.brown80,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: IrmaSpacing.xl),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSubMetricCard(
                                    title: 'Energy',
                                    score: subMetrics['Energy'] as int? ?? 80,
                                    backgroundColor: IrmaColors.green50,
                                    trackColor: IrmaColors.green40,
                                    activeColor: Colors.white,
                                    statusColor: IrmaColors.green20,
                                    shadowColor: IrmaColors.green50,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSubMetricCard(
                                    title: 'Wakefulness',
                                    score: subMetrics['Wakefulness'] as int? ?? 80,
                                    backgroundColor: IrmaColors.green50,
                                    trackColor: IrmaColors.green40,
                                    activeColor: Colors.white,
                                    statusColor: IrmaColors.green20,
                                    shadowColor: IrmaColors.green50,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSubMetricCard(
                                    title: 'Recovery',
                                    score: subMetrics['Recovery'] as int? ?? 80,
                                    backgroundColor: IrmaColors.green50,
                                    trackColor: IrmaColors.green40,
                                    activeColor: Colors.white,
                                    statusColor: IrmaColors.green20,
                                    shadowColor: IrmaColors.green50,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: IrmaSpacing.lg),

                      // 2. Mind Sub-metrics Display Section
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: IrmaSpacing.lg,
                          vertical: IrmaSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: IrmaColors.orange40,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      PhosphorIcons.brain(PhosphorIconsStyle.fill),
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Mind Scores",
                                        style: IrmaTextStyles.labelLgBold.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: IrmaColors.brown80,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        TriMetricEngine.getTierForScore(mind),
                                        style: IrmaTextStyles.labelMdBold.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: IrmaColors.brown60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CustomPaint(
                                        size: const Size(64, 64),
                                        painter: _CategoryScoreRingPainter(
                                          progress: mind / 100.0,
                                          trackColor: IrmaColors.orange10,
                                          progressColor: IrmaColors.orange40,
                                          strokeWidth: 10.0,
                                        ),
                                      ),
                                      Text(
                                        '$mind',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: IrmaColors.brown80,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: IrmaSpacing.xl),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSubMetricCard(
                                    title: 'Focus',
                                    score: subMetrics['Focus'] as int? ?? 80,
                                    backgroundColor: IrmaColors.orange40,
                                    trackColor: IrmaColors.orange30,
                                    activeColor: Colors.white,
                                    statusColor: IrmaColors.orange20,
                                    shadowColor: IrmaColors.orange40,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSubMetricCard(
                                    title: 'Creativity',
                                    score: subMetrics['Creativity'] as int? ?? 80,
                                    backgroundColor: IrmaColors.orange40,
                                    trackColor: IrmaColors.orange30,
                                    activeColor: Colors.white,
                                    statusColor: IrmaColors.orange20,
                                    shadowColor: IrmaColors.orange40,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSubMetricCard(
                                    title: 'Motivation',
                                    score: subMetrics['Motivation'] as int? ?? 80,
                                    backgroundColor: IrmaColors.orange40,
                                    trackColor: IrmaColors.orange30,
                                    activeColor: Colors.white,
                                    statusColor: IrmaColors.orange20,
                                    shadowColor: IrmaColors.orange40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: IrmaSpacing.lg),

                      // 3. Soul Sub-metrics Display Section
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: IrmaSpacing.lg,
                          vertical: IrmaSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: IrmaColors.purple30,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Soul Scores",
                                        style: IrmaTextStyles.labelLgBold.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: IrmaColors.brown80,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        TriMetricEngine.getTierForScore(soul),
                                        style: IrmaTextStyles.labelMdBold.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: IrmaColors.brown60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CustomPaint(
                                        size: const Size(64, 64),
                                        painter: _CategoryScoreRingPainter(
                                          progress: soul / 100.0,
                                          trackColor: IrmaColors.purple10,
                                          progressColor: IrmaColors.purple30,
                                          strokeWidth: 10.0,
                                        ),
                                      ),
                                      Text(
                                        '$soul',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: IrmaColors.brown80,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: IrmaSpacing.xl),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSubMetricCard(
                                    title: 'Mood',
                                    score: subMetrics['Mood'] as int? ?? 80,
                                    backgroundColor: IrmaColors.purple30,
                                    trackColor: IrmaColors.purple20,
                                    activeColor: Colors.white,
                                    statusColor: IrmaColors.purple20,
                                    shadowColor: IrmaColors.purple30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSubMetricCard(
                                    title: 'Sociability',
                                    score: subMetrics['SocialBandwidth'] as int? ?? 80,
                                    backgroundColor: IrmaColors.purple30,
                                    trackColor: IrmaColors.purple20,
                                    activeColor: Colors.white,
                                    statusColor: IrmaColors.purple20,
                                    shadowColor: IrmaColors.purple30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSubMetricCard(
                                    title: 'Stability',
                                    score: subMetrics['Stability'] as int? ?? 80,
                                    backgroundColor: IrmaColors.purple30,
                                    trackColor: IrmaColors.purple20,
                                    activeColor: Colors.white,
                                    statusColor: IrmaColors.purple20,
                                    shadowColor: IrmaColors.purple30,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: IrmaSpacing.lg),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
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
          ClipOval(
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/young-woman-being-quarantined-home.jpg',
                  width: 162,
                  height: 162,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
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

      // 1. Draw track background segments (brown20 for visibility on white bg)
      final trackPaint = Paint()
        ..color = IrmaColors.brown20
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
            color: IrmaColors.brown80,
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
    drawSegmentedBar(mindProgress, rMind, IrmaColors.orange50);
    drawLabel('Mind', rMind);

    // Draw Body (outermost)
    drawSegmentedBar(bodyProgress, rBody, IrmaColors.green50);
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
    const double paddingLeft = 24.0;
    const double paddingRight = 24.0;
    const double paddingTop = 16.0;
    const double paddingBottom = 32.0;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;
    final int totalDays = metricsHistory.length;
    final double stepX = totalDays > 1 ? chartWidth / (totalDays - 1) : 0.0;

    double minVal = 100.0;
    double maxVal = 0.0;
    for (final item in metricsHistory) {
      final double b = (item['body'] as num).toDouble();
      final double m = (item['mind'] as num).toDouble();
      final double s = (item['soul'] as num).toDouble();
      if (b < minVal) minVal = b;
      if (m < minVal) minVal = m;
      if (s < minVal) minVal = s;
      if (b > maxVal) maxVal = b;
      if (m > maxVal) maxVal = m;
      if (s > maxVal) maxVal = s;
    }
    final double range = maxVal - minVal;

    double getY(double val) {
      if (range == 0.0) return size.height - paddingBottom - 0.5 * chartHeight;
      final double scaledPercent = 10.0 + ((val - minVal) / range) * 85.0; // 95 - 10 = 85
      return size.height - paddingBottom - (scaledPercent / 100.0) * chartHeight;
    }
    double getX(int i) => paddingLeft + i * stepX;

    // 2. Draw vertical today line highlight and X-axis labels
    for (int i = 0; i < totalDays; i++) {
      final x = getX(i);
      final item = metricsHistory[i];
      final isToday = item['isToday'] as bool? ?? false;
      final int cycleDay = item['cycleDay'] as int? ?? (i + 1);

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

        // Draw "Today" label below the Day number
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

      // Draw day labels for key cycle milestones (Day 1, 7, 14, 21, and the last day of the cycle)
      if (cycleDay == 1 || cycleDay == 7 || cycleDay == 14 || cycleDay == 21 || cycleDay == totalDays) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'Day $cycleDay',
            style: IrmaTextStyles.labelSm.copyWith(
              color: isToday ? IrmaColors.orange50 : IrmaColors.brown60,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              fontSize: 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - paddingBottom + 6));
      }
    }

    // 3. Build generalized bezier path helper for arbitrary list sizes
    Path buildLinePath(List<double> values) {
      final path = Path();
      if (values.isEmpty) return path;
      final int n = values.length;
      
      // Calculate tangents (slopes) at each point dynamically based on surrounding points
      final List<double> tangents = List.filled(n, 0.0);
      for (int i = 0; i < n; i++) {
        if (i == 0) {
          tangents[i] = n > 1 ? (getY(values[1]) - getY(values[0])) * 0.5 : 0.0;
        } else if (i == n - 1) {
          tangents[i] = (getY(values[n - 1]) - getY(values[n - 2])) * 0.5;
        } else {
          tangents[i] = (getY(values[i + 1]) - getY(values[i - 1])) * 0.5;
        }
      }

      path.moveTo(getX(0), getY(values[0]));
      for (int i = 0; i < n - 1; i++) {
        final double x1 = getX(i);
        final double y1 = getY(values[i]);
        final double x2 = getX(i + 1);
        final double y2 = getY(values[i + 1]);
        
        // Control points using the calculated tangents to ensure smooth continuous slopes
        final double cp1x = x1 + stepX / 3.0;
        final double cp1y = y1 + tangents[i] / 3.0;
        final double cp2x = x2 - stepX / 3.0;
        final double cp2y = y2 - tangents[i + 1] / 3.0;
        
        path.cubicTo(cp1x, cp1y, cp2x, cp2y, x2, y2);
      }
      return path;
    }

    void drawSmoothLine(List<double> values, Color color) {
      final path = buildLinePath(values);
      final linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);
    }

    final bodyValues = metricsHistory.map((m) => (m['body'] as int).toDouble()).toList();
    final mindValues = metricsHistory.map((m) => (m['mind'] as int).toDouble()).toList();
    final soulValues = metricsHistory.map((m) => (m['soul'] as int).toDouble()).toList();

    // Draw lines (Soul at the bottom, Mind in the middle, Body on top)
    drawSmoothLine(soulValues, IrmaColors.purple40);
    drawSmoothLine(mindValues, IrmaColors.orange50);
    drawSmoothLine(bodyValues, IrmaColors.green50);
  }

  @override
  bool shouldRepaint(covariant _SmoothedLineChartPainter oldDelegate) {
    return oldDelegate.metricsHistory != metricsHistory;
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = IrmaColors.brown20
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..cubicTo(
        size.width, 0,
        size.width, size.height,
        0, size.height,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

    for (int i = 0; i < totalSegments; i++) {
      final double startAngle = -90.0 * degToRad + i * totalSegmentAngle;
      
      // 1. Draw inactive track segment
      canvas.drawArc(rect, startAngle, segmentSweep, false, inactivePaint);
      
      // 2. Draw active progress segment overlay
      double filledFraction = 0.0;
      if (progress >= (i + 1) * 0.2) {
        filledFraction = 1.0;
      } else if (progress > i * 0.2) {
        filledFraction = (progress - i * 0.2) / 0.2;
      }

      if (filledFraction > 0.0) {
        canvas.drawArc(rect, startAngle, segmentSweep * filledFraction, false, activePaint);
      }
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

class _CategoryScoreRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CategoryScoreRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw full track circle
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc (start at 12 o'clock: -pi / 2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CategoryScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

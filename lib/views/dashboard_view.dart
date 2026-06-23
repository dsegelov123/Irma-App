import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/services/advice_service.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/services/tri_metric_engine.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/widgets/cycle_circular_indicator.dart';
import 'package:irma/widgets/irma_top_bar.dart';
import 'package:irma/views/history_view.dart';
import 'package:irma/views/calendar_view.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback onLogSymptomsPressed;
  final VoidCallback onProfilePressed;
  final ValueChanged<int> onTabChanged;
  const DashboardView({
    super.key,
    required this.onLogSymptomsPressed,
    required this.onProfilePressed,
    required this.onTabChanged,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  static const bool _useIrmaTopBar = true;
  late Map<String, dynamic> _cycleState;
  late String _advice;
  late Map<String, dynamic> _metrics;
  late bool _isPremium;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _cycleState = CycleEngine.getCurrentCycleState();
      _advice = AdviceService.generateDailyAdvice();
      _isPremium = StorageService.settingsBox.get('user_is_premium', defaultValue: false) as bool;
      _metrics = TriMetricEngine.calculateMetricsForDate(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final int currentDay   = _cycleState['day'] as int;
    final String phase     = _cycleState['phase'] as String;
    final int daysUntil    = _cycleState['days_until_next'] as int;
    final bool isLate      = _cycleState['is_late'] as bool;
    final int avgLength    = _cycleState['average_length'] as int;
    final int periodDuration = _cycleState['period_duration'] as int? ?? 5;

    // Compute cycle day for the selected date (allows ring to track tapped day)
    final int selectedCycleDay = CycleEngine.getCycleDay(targetDate: _selectedDate);
    final String selectedPhase = CycleEngine.getPhaseForDay(selectedCycleDay, avgLength, periodDuration);

    // Unused old card variables removed

    final ({Color color, Color tint, IconData icon}) phaseStyle = switch (selectedPhase) {
      'Menstruation'         => (color: IrmaColors.orange50, tint: IrmaColors.orange10, icon: Icons.water_drop_rounded),
      'Follicular Phase'     => (color: IrmaColors.green50,  tint: IrmaColors.green10,  icon: Icons.spa_rounded),
      'Ovulation'            => (color: IrmaColors.purple50, tint: IrmaColors.purple10, icon: Icons.wb_sunny_rounded),
      'Luteal Phase'         => (color: IrmaColors.yellow50, tint: IrmaColors.yellow10, icon: Icons.nights_stay_rounded),
      _                      => (color: IrmaColors.yellow50, tint: IrmaColors.yellow10, icon: Icons.hourglass_empty_rounded),
    };

    if (_useIrmaTopBar) {
      return Scaffold(
        backgroundColor: IrmaColors.brown10,
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 80.0),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            left: IrmaSpacing.lg,
                            right: IrmaSpacing.lg,
                            top: IrmaSpacing.xl,
                            bottom: IrmaSpacing.xl,
                          ),
                          decoration: const BoxDecoration(
                            color: IrmaColors.brown10,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(IrmaRadius.stat),
                                  boxShadow: [
                                    BoxShadow(
                                      color: IrmaColors.brown80.withValues(alpha: 0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: IrmaSpacing.lg,
                                  vertical: IrmaSpacing.xl,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      isLate ? 'Period is late!' : 'Next period in $daysUntil days',
                                      style: IrmaTextStyles.labelXl.copyWith(
                                        color: phaseStyle.color,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: IrmaSpacing.lg),
                                    Center(
                                      child: IrmaCycleCircularIndicator(
                                        progress: (selectedCycleDay / avgLength).clamp(0.0, 1.0),
                                        currentDay: selectedCycleDay,
                                        totalDays: avgLength,
                                        periodDuration: periodDuration,
                                        phaseName: selectedPhase,
                                        phaseColor: phaseStyle.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: IrmaSpacing.lg),
                              IrmaHorizontalWeekCalendar(
                                themeColor: IrmaColors.orange50,
                                tintColor: IrmaColors.orange10,
                                selectedDate: _selectedDate,
                                onDateSelected: (date) {
                                  setState(() => _selectedDate = date);
                                },
                              ),
                            ],
                          ),
                        ),
                        _buildMainDashboardContent(context),
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
                title: 'Hi, Shinomiya!',
                leading: GestureDetector(
                  onTap: widget.onProfilePressed,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: IrmaColors.brown10,
                      shape: BoxShape.circle,
                      border: Border.all(color: IrmaColors.green50, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        'IM',
                        style: IrmaTextStyles.labelMdBold.copyWith(
                          color: IrmaColors.brown80,
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IrmaTopBarActionButton(
                    icon: Icons.calendar_today_rounded,
                    onTap: () async {
                      final result = await Navigator.push<int?>(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarView()),
                      );
                      if (result != null) {
                        widget.onTabChanged(result);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: IrmaColors.brown10,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We use a Stack to overlay the Hero section on top of the Cycle Status Section
            Stack(
              children: [
                // ── Cycle Status Section (Full Width Background Image & 30% Opacity Black Overlay) ──
                // It starts 34px above the bottom of the Hero section, extending under it by exactly 34px
                Builder(
                  builder: (context) {
                    final double rawTopPadding = MediaQuery.of(context).padding.top;
                    final double actualHeroHeight = rawTopPadding > 0 ? rawTopPadding + 156.0 : 200.0;
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: actualHeroHeight - 34.0),
                      decoration: const BoxDecoration(
                        color: IrmaColors.brown10,
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: IrmaSpacing.lg,
                          right: IrmaSpacing.lg,
                          top: IrmaSpacing.xl + 34.0, // Extended 34px under hero, content not raised
                          bottom: IrmaSpacing.xl,
                        ),
                        decoration: const BoxDecoration(
                          color: IrmaColors.brown10,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(IrmaRadius.stat),
                                boxShadow: [
                                  BoxShadow(
                                    color: IrmaColors.brown80.withValues(alpha: 0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: IrmaSpacing.lg,
                                vertical: IrmaSpacing.xl,
                              ),
                              child: Column(
                                children: [
                                  // Centered prediction header
                                  Text(
                                    isLate ? 'Period is late!' : 'Next period in $daysUntil days',
                                    style: IrmaTextStyles.labelXl.copyWith(
                                      color: phaseStyle.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: IrmaSpacing.lg),
                                  // Centered circular cycle graphic
                                  Center(
                                    child: IrmaCycleCircularIndicator(
                                      progress: (selectedCycleDay / avgLength).clamp(0.0, 1.0),
                                      currentDay: selectedCycleDay,
                                      totalDays: avgLength,
                                      periodDuration: periodDuration,
                                      phaseName: selectedPhase,
                                      phaseColor: phaseStyle.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: IrmaSpacing.lg),
                            // Horizontal weekly strip calendar centered around today
                            IrmaHorizontalWeekCalendar(
                              themeColor: IrmaColors.orange50,
                              tintColor: IrmaColors.orange10,
                              selectedDate: _selectedDate,
                              onDateSelected: (date) {
                                setState(() => _selectedDate = date);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // ── Figma Hero Header Card ───────────────────────────
                // Positioned on top of the background image
                _buildHeroSection(context),
              ],
            ),

            // ── Main Dashboard Content ─────────────────
            _buildMainDashboardContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDashboardContent(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(
        top: IrmaSpacing.xl,
        bottom: IrmaSpacing.lg + 80.0 + IrmaSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Advice Section Header & Bubble ─────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Irma's advice", style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
                const SizedBox(height: IrmaSpacing.sm),

                // ── Advice Chat Bubble ────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main bubble body
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
                          // Irma profile image in circle
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
                          // Advice text
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                              child: Text(
                                _advice,
                                style: IrmaTextStyles.labelMdBold.copyWith(
                                  color: IrmaColors.brown100.withValues(alpha: 0.64),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Speech-bubble tail
                    CustomPaint(
                      size: const Size(12, 12),
                      painter: _BubbleTailPainter(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: IrmaSpacing.xl),

          // ── Wellness Scores Section ─────────────────────
          _buildScoreSection(context),
          const SizedBox(height: 32.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: IrmaColors.brown80,
                borderRadius: BorderRadius.circular(32),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/specsoverlay.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Daily Reflection",
                              style: IrmaTextStyles.labelLg.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        SizedBox(
                          width: 220,
                          child: Text(
                            "Take a quiet moment to record your thoughts and symptoms. Your daily patterns build a clearer picture of your wellbeing over time.",
                            style: IrmaTextStyles.paraSm.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: IrmaSpacing.lg),
        ],
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
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: IrmaSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Body, Mind & Soul',
            style: IrmaTextStyles.labelXl.copyWith(
              color: IrmaColors.brown100,
            ),
          ),
          const SizedBox(height: IrmaSpacing.md),
          Row(
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
          const SizedBox(height: IrmaSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 40.0,
              child: OutlinedButton(
                onPressed: () {
                  widget.onTabChanged(2);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: IrmaColors.brown80,
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: IrmaColors.brown80, width: 1.0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See more',
                      style: IrmaTextStyles.labelMdBold.copyWith(
                        color: IrmaColors.brown80,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 24.0,
                      color: IrmaColors.brown80,
                    ),
                  ],
                ),
              ),
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

  Widget _buildHeroSection(BuildContext context) {
    final now = DateTime.now();
    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final formattedDate = '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    final int body = _metrics['body'] as int? ?? 80;
    final int mind = _metrics['mind'] as int? ?? 80;
    final int soul = _metrics['soul'] as int? ?? 80;
    final int compositeScore = ((body + mind + soul) / 3).round().clamp(0, 100);

    final int moodVal = _metrics['sub_metrics']?['Mood'] as int? ?? 80;
    final String moodText;
    final IconData moodIcon;
    if (moodVal >= 80) {
      moodText = 'Happy';
      moodIcon = Icons.sentiment_very_satisfied_rounded;
    } else if (moodVal >= 50) {
      moodText = 'Calm';
      moodIcon = Icons.sentiment_satisfied_rounded;
    } else {
      moodText = 'Tired';
      moodIcon = Icons.sentiment_neutral_rounded;
    }

    final double rawTopPadding = MediaQuery.of(context).padding.top;
    final double topPadding = rawTopPadding > 0 ? rawTopPadding + 16.0 : 32.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(IrmaRadius.large),
          bottomRight: Radius.circular(IrmaRadius.large),
        ),
        boxShadow: [
          BoxShadow(
            color: IrmaColors.brown80.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: IrmaColors.brown80.withValues(alpha: 0.03),
            blurRadius: 28,
            offset: const Offset(0, 28),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        IrmaSpacing.md, // EXACT Figma padding-left-16
        topPadding, // EXACT Figma padding-top-32 (including safe area if on mobile)
        IrmaSpacing.md, // EXACT Figma padding-right-16
        IrmaSpacing.xl, // EXACT Figma padding-bottom-32
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Calendar Date & Hamburger Icon (Menu Trigger)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 16, color: IrmaColors.brown80),
                  const SizedBox(width: 4), // EXACT Figma gap-4
                  Text(
                    formattedDate,
                    style: IrmaTextStyles.labelSm.copyWith(
                      color: IrmaColors.brown100,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: IrmaColors.brown80),
                  ),
                  child: const Center(
                    child: Icon(Icons.menu_rounded, color: IrmaColors.brown80),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0), // EXACT Figma gap-12
          
          // Row 2: Profile Picture & Name/Tags
          Row(
            children: [
              GestureDetector(
                onTap: widget.onProfilePressed,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: IrmaColors.brown10,
                    shape: BoxShape.circle,
                    border: Border.all(color: IrmaColors.green50, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'IM',
                      style: IrmaTextStyles.labelXl.copyWith(
                        color: IrmaColors.brown80,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0), // EXACT Figma gap-12
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Shinomiya!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4.0), // EXACT Figma gap-4
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: IrmaPadding.tagXs, // EXACT Figma padding-top-4, padding-right-8 mapped to Tag Xs from ui_design_system
                            decoration: BoxDecoration(
                              color: _isPremium ? IrmaColors.green10 : IrmaColors.gray20,
                              borderRadius: BorderRadius.circular(IrmaRadius.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isPremium ? Icons.star_rounded : Icons.star_outline_rounded,
                                  size: 14,
                                  color: _isPremium ? IrmaColors.green50 : IrmaColors.gray60,
                                ),
                                const SizedBox(width: 4), // EXACT Figma gap-4
                                Text(
                                  _isPremium ? 'Pro Member' : 'Free Member',
                                  style: IrmaTextStyles.labelSm.copyWith(
                                    color: _isPremium ? IrmaColors.green50 : IrmaColors.gray60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12.0), // EXACT Figma gap-12
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.analytics_rounded, size: 14, color: IrmaColors.brown80),
                              const SizedBox(width: 4), // EXACT Figma gap-4
                              Text(
                                '$compositeScore%',
                                style: IrmaTextStyles.labelSm.copyWith(
                                  color: IrmaColors.brown80,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12.0), // EXACT Figma gap-12
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(moodIcon, size: 14, color: IrmaColors.brown80),
                              const SizedBox(width: 4), // EXACT Figma gap-4
                              Text(
                                moodText,
                                style: IrmaTextStyles.labelSm.copyWith(
                                  color: IrmaColors.brown80,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// § Private painters for the Advice Chat Bubble
// ─────────────────────────────────────────────────────────────────

/// Paints a concave speech-bubble tail (12×12) matching the Figma SVG
/// bottom-left corner shape: a quarter-circle cutout that connects
/// the bottom-left of the bubble to the background.
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

import 'package:flutter/material.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/services/advice_service.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/services/tri_metric_engine.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/widgets/cycle_circular_indicator.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback onLogSymptomsPressed;
  final VoidCallback onProfilePressed;
  const DashboardView({
    super.key,
    required this.onLogSymptomsPressed,
    required this.onProfilePressed,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late Map<String, dynamic> _cycleState;
  late String _advice;
  late Map<String, dynamic> _metrics;
  late bool _isPremium;

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

    final ({Color color, Color tint, IconData icon}) phaseStyle = switch (phase) {
      'Menstruation'         => (color: IrmaColors.orange40, tint: IrmaColors.orange10, icon: Icons.water_drop_rounded),
      'Follicular Phase'     => (color: IrmaColors.green50,  tint: IrmaColors.green10,  icon: Icons.spa_rounded),
      'Ovulation'            => (color: IrmaColors.purple40, tint: IrmaColors.purple10, icon: Icons.wb_sunny_rounded),
      'Luteal Phase'         => (color: IrmaColors.brown60,  tint: IrmaColors.brown10,  icon: Icons.nights_stay_rounded),
      _                      => (color: IrmaColors.yellow40, tint: IrmaColors.yellow10, icon: Icons.hourglass_empty_rounded),
    };

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
                        image: DecorationImage(
                          image: AssetImage('assets/images/young-woman-being-quarantined-home.jpg'),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: IrmaSpacing.lg,
                          right: IrmaSpacing.lg,
                          top: IrmaSpacing.xl + 34.0, // Extended 34px under hero, content not raised
                          bottom: IrmaSpacing.xl,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5), // 50% black overlay
                        ),
                        child: Column(
                          children: [
                            // Centered prediction header
                            Text(
                              isLate ? 'Period is late!' : 'Next period in $daysUntil days',
                              style: IrmaTextStyles.paragraphSmMedium.copyWith(
                                color: phaseStyle.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: IrmaSpacing.lg),

                            // Centered circular cycle graphic
                            Center(
                              child: IrmaCycleCircularIndicator(
                                progress: (currentDay / avgLength).clamp(0.0, 1.0),
                                currentDay: currentDay,
                                totalDays: avgLength,
                                periodDuration: periodDuration,
                                phaseName: phase,
                              ),
                            ),
                            const SizedBox(height: IrmaSpacing.lg),

                            // Horizontal weekly strip calendar centered around today
                            IrmaHorizontalWeekCalendar(
                              themeColor: phaseStyle.color,
                              tintColor: phaseStyle.tint,
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

            // ── Main Dashboard Content ──────────────────────────
            Padding(
              padding: const EdgeInsets.only(
                left: IrmaSpacing.lg,
                right: IrmaSpacing.lg,
                top: IrmaSpacing.lg,
                bottom: IrmaSpacing.lg + 80.0 + IrmaSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

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
                                    color: IrmaColors.brown100.withOpacity(0.64),
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
                  const SizedBox(height: IrmaSpacing.xl),

                  // ── CTA Button ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onLogSymptomsPressed,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: const Text('Log Symptoms & Telemetry'),
                      style: IrmaButtonStyles.primaryLg(),
                    ),
                  ),
                  const SizedBox(height: IrmaSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
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
    final double topPadding = rawTopPadding > 0 ? rawTopPadding + 16.0 : 60.0;

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
            color: IrmaColors.brown80.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: IrmaColors.brown80.withOpacity(0.03),
            blurRadius: 28,
            offset: const Offset(0, 28),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        IrmaSpacing.md, // EXACT Figma padding-left-16
        topPadding, // EXACT Figma padding-top-60 (including safe area if on mobile)
        IrmaSpacing.md, // EXACT Figma padding-right-16
        IrmaSpacing.md, // EXACT Figma padding-bottom-16
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

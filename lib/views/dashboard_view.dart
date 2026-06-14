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

    final ({Color color, Color tint, IconData icon}) phaseStyle = switch (phase) {
      'Menstruation'         => (color: IrmaColors.orange40, tint: IrmaColors.orange10, icon: Icons.water_drop_rounded),
      'Follicular Phase'     => (color: IrmaColors.green50,  tint: IrmaColors.green10,  icon: Icons.spa_rounded),
      'Ovulation'            => (color: IrmaColors.purple40, tint: IrmaColors.purple10, icon: Icons.wb_sunny_rounded),
      'Luteal Phase'         => (color: IrmaColors.brown60,  tint: IrmaColors.brown10,  icon: Icons.nights_stay_rounded),
      _                      => (color: IrmaColors.yellow40, tint: IrmaColors.yellow10, icon: Icons.hourglass_empty_rounded),
    };

    return Scaffold(
      backgroundColor: IrmaColors.gray10,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Figma Hero Header Card ───────────────────────────
            _buildHeroSection(context),
            
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
                  const SizedBox(height: IrmaSpacing.xs),
 
                  // ── Greeting ──────────────────────────────────────────
                  Text('Good day.', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.gray60)),
                  const SizedBox(height: 4),
                  Text('Here\'s your cycle overview.', style: IrmaTextStyles.para2xl.copyWith(color: IrmaColors.brown100)),
                  const SizedBox(height: IrmaSpacing.lg),
 
                  // ── Cycle Status Card ─────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: IrmaPadding.cardLarge,
                    decoration: IrmaCards.large(),
                    child: Column(
                      children: [
                        // Centered prediction header matching Figma style (Poppins 14 weight 500, mapped to labelMd)
                        Text(
                          isLate ? 'Period is late!' : 'Next period in $daysUntil days',
                          style: IrmaTextStyles.labelMd.copyWith(
                            color: phaseStyle.color,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: IrmaSpacing.lg),

                        // Centered circular cycle graphic with premium wave liquid animation
                        Center(
                          child: IrmaCycleCircularIndicator(
                            progress: (currentDay / avgLength).clamp(0.0, 1.0),
                            currentDay: currentDay,
                            totalDays: avgLength,
                            themeColor: phaseStyle.color,
                            tintColor: phaseStyle.tint,
                            phaseName: phase,
                          ),
                        ),
                        const SizedBox(height: IrmaSpacing.lg),

                        const Divider(),
                        const SizedBox(height: IrmaSpacing.md),

                        // Horizontal weekly strip calendar centered around today
                        IrmaHorizontalWeekCalendar(
                          themeColor: phaseStyle.color,
                          tintColor: phaseStyle.tint,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: IrmaSpacing.lg),
 
                  // ── Advice Section Header ─────────────────────────────
                  Text("Irma's Advice", style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
                  const SizedBox(height: IrmaSpacing.sm),
 
                  // ── Advice Card ───────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: IrmaPadding.cardLarge,
                    decoration: IrmaCards.advice(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, color: IrmaColors.green50, size: 16),
                            const SizedBox(width: IrmaSpacing.xs),
                            Text(
                              'DAILY INSIGHT',
                              style: IrmaTextStyles.labelXs.copyWith(
                                color: IrmaColors.green50,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: IrmaSpacing.sm),
                        Text(
                          _advice,
                          style: IrmaTextStyles.paraMd.copyWith(
                            color: IrmaColors.brown100,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
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

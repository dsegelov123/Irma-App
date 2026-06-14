import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/services/tri_metric_engine.dart';
import 'package:irma/widgets/theme.dart';

class DailyMetricsView extends StatefulWidget {
  const DailyMetricsView({super.key});

  @override
  State<DailyMetricsView> createState() => _DailyMetricsViewState();
}

class _DailyMetricsViewState extends State<DailyMetricsView> {
  late Map<String, dynamic> _metrics;
  late bool _isPremium;
  late List<Map<String, dynamic>> _forecast;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _isPremium = StorageService.settingsBox.get('user_is_premium', defaultValue: false) as bool;
      _metrics   = TriMetricEngine.calculateMetricsForDate(DateTime.now());
      _forecast  = _isPremium ? TriMetricEngine.calculate7DayForecast() : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final int body    = _metrics['body'] as int;
    final int mind    = _metrics['mind'] as int;
    final int soul    = _metrics['soul'] as int;
    final String bodyTier = _metrics['body_tier'] as String;
    final String mindTier = _metrics['mind_tier'] as String;
    final String soulTier = _metrics['soul_tier'] as String;
    final Map sub = _metrics['sub_metrics'] as Map;

    return Scaffold(
      backgroundColor: IrmaColors.gray10,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: IrmaColors.brown80),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text('Wellness Analytics', style: IrmaTextStyles.label2xl.copyWith(color: IrmaColors.brown100)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.refresh_rounded, color: IrmaColors.brown80), onPressed: _refreshData),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: IrmaSpacing.lg,
          right: IrmaSpacing.lg,
          top: IrmaSpacing.lg,
          bottom: IrmaSpacing.lg + 80.0 + 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section: Composite Vectors ────────────────────────
            Text('Composite Vectors', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
            const SizedBox(height: IrmaSpacing.sm),
            _ParentMetricCard(title: 'Body', score: body, tier: bodyTier, color: IrmaColors.orange40, tint: IrmaColors.orange10),
            const SizedBox(height: IrmaSpacing.sm),
            _ParentMetricCard(title: 'Mind', score: mind, tier: mindTier, color: IrmaColors.green50,  tint: IrmaColors.green10),
            const SizedBox(height: IrmaSpacing.sm),
            _ParentMetricCard(title: 'Soul', score: soul, tier: soulTier, color: IrmaColors.purple40, tint: IrmaColors.purple10),
            const SizedBox(height: IrmaSpacing.xl),

            // ── Section: Sub-metrics ──────────────────────────────
            Text('Granular Sub-metrics', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
            const SizedBox(height: IrmaSpacing.sm),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: IrmaSpacing.sm,
              crossAxisSpacing: IrmaSpacing.sm,
              childAspectRatio: 0.88,
              children: [
                _SubMetricCell(name: 'Energy',       val: sub['Energy']          as int, color: IrmaColors.orange40, tint: IrmaColors.orange10),
                _SubMetricCell(name: 'Wakefulness',  val: sub['Wakefulness']     as int, color: IrmaColors.orange40, tint: IrmaColors.orange10),
                _SubMetricCell(name: 'Recovery',     val: sub['Recovery']        as int, color: IrmaColors.orange40, tint: IrmaColors.orange10),
                _SubMetricCell(name: 'Focus',        val: sub['Focus']           as int, color: IrmaColors.green50,  tint: IrmaColors.green10),
                _SubMetricCell(name: 'Creativity',   val: sub['Creativity']      as int, color: IrmaColors.green50,  tint: IrmaColors.green10),
                _SubMetricCell(name: 'Motivation',   val: sub['Motivation']      as int, color: IrmaColors.green50,  tint: IrmaColors.green10),
                _SubMetricCell(name: 'Mood',         val: sub['Mood']            as int, color: IrmaColors.purple40, tint: IrmaColors.purple10),
                _SubMetricCell(name: 'Social Band.', val: sub['SocialBandwidth'] as int, color: IrmaColors.purple40, tint: IrmaColors.purple10),
                _SubMetricCell(name: 'Stability',    val: sub['Stability']       as int, color: IrmaColors.purple40, tint: IrmaColors.purple10),
              ],
            ),
            const SizedBox(height: IrmaSpacing.xl),

            // ── Section: 7-Day Forecast ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('7-Day Projections', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
                if (!_isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.sm, vertical: 5),
                    decoration: BoxDecoration(color: IrmaColors.brown80, borderRadius: BorderRadius.circular(100)),
                    child: Text('PREMIUM', style: IrmaTextStyles.labelXs.copyWith(color: Colors.white, letterSpacing: 1.0)),
                  ),
              ],
            ),
            const SizedBox(height: IrmaSpacing.sm),

            if (_isPremium)
              ..._forecast.map((day) {
                final date = day['date'] as DateTime;
                const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Container(
                  margin: const EdgeInsets.only(bottom: IrmaSpacing.xs),
                  padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.md, vertical: IrmaSpacing.sm),
                  decoration: IrmaCards.log(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${wd[date.weekday - 1]} ${date.day}/${date.month}',
                        style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100),
                      ),
                      Row(children: [
                        _MiniIndicator(label: 'B', val: day['body'] as int, color: IrmaColors.orange40),
                        const SizedBox(width: IrmaSpacing.xs),
                        _MiniIndicator(label: 'M', val: day['mind'] as int, color: IrmaColors.green50),
                        const SizedBox(width: IrmaSpacing.xs),
                        _MiniIndicator(label: 'S', val: day['soul'] as int, color: IrmaColors.purple40),
                      ]),
                    ],
                  ),
                );
              })
            else
              // ── Premium teaser card ───────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(IrmaSpacing.lg),
                decoration: IrmaCards.large(fill: IrmaColors.purple10, border: IrmaColors.purple20),
                child: Column(
                  children: [
                    Icon(Icons.lock_rounded, color: IrmaColors.purple40, size: 36),
                    const SizedBox(height: IrmaSpacing.sm),
                    Text(
                      'Unlock Lookahead Projections',
                      style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown100),
                    ),
                    const SizedBox(height: IrmaSpacing.xs),
                    Text(
                      'Upgrade to Premium to forecast emotional and physical patterns over the next 7 days.',
                      textAlign: TextAlign.center,
                      style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.gray60, height: 1.5),
                    ),
                    const SizedBox(height: IrmaSpacing.lg),
                    ElevatedButton(
                      onPressed: () async {
                        await StorageService.settingsBox.put('user_is_premium', true);
                        _refreshData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Premium mode unlocked for testing.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IrmaColors.purple40,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: IrmaSpacing.sm),
                        shape: const StadiumBorder(),
                        textStyle: IrmaTextStyles.labelLg,
                      ),
                      child: const Text('Unlock Premium Forecasts'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: IrmaSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ── Parent metric card ─────────────────────────────────────────────

class _ParentMetricCard extends StatelessWidget {
  final String title;
  final int score;
  final String tier;
  final Color color;
  final Color tint;

  const _ParentMetricCard({
    required this.title,
    required this.score,
    required this.tier,
    required this.color,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(IrmaSpacing.md),
      decoration: IrmaCards.standard(),
      child: Row(
        children: [
          // Score display — large number
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Text(
                '$score',
                style: IrmaTextStyles.paraXl.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: IrmaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown100)),
                const SizedBox(height: 2),
                Text('$tier Tier', style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.gray60)),
                const SizedBox(height: IrmaSpacing.xs),
                // Score bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: tint,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          // Tier pill tag
          const SizedBox(width: IrmaSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.sm, vertical: 5),
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(100)),
            child: Text(
              tier.toUpperCase(),
              style: IrmaTextStyles.labelXs.copyWith(color: color, letterSpacing: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-metric grid cell ───────────────────────────────────────────

class _SubMetricCell extends StatelessWidget {
  final String name;
  final int val;
  final Color color;
  final Color tint;

  const _SubMetricCell({required this.name, required this.val, required this.color, required this.tint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(IrmaSpacing.sm),
      decoration: IrmaCards.log(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, textAlign: TextAlign.center, style: IrmaTextStyles.labelSm.copyWith(color: IrmaColors.brown100)),
          const SizedBox(height: IrmaSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.sm, vertical: 4),
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(100)),
            child: Text('$val', style: IrmaTextStyles.labelMd.copyWith(color: color)),
          ),
          const SizedBox(height: IrmaSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: val / 100,
              minHeight: 4,
              backgroundColor: IrmaColors.gray20,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Forecast mini indicator ────────────────────────────────────────

class _MiniIndicator extends StatelessWidget {
  final String label;
  final int val;
  final Color color;

  const _MiniIndicator({required this.label, required this.val, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        '$label:$val',
        style: IrmaTextStyles.labelXs.copyWith(color: color),
      ),
    );
  }
}

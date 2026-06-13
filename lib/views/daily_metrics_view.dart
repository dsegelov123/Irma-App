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
      _metrics = TriMetricEngine.calculateMetricsForDate(DateTime.now());
      if (_isPremium) {
        _forecast = TriMetricEngine.calculate7DayForecast();
      } else {
        _forecast = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int body = _metrics['body'] as int;
    final int mind = _metrics['mind'] as int;
    final int soul = _metrics['soul'] as int;

    final String bodyTier = _metrics['body_tier'] as String;
    final String mindTier = _metrics['mind_tier'] as String;
    final String soulTier = _metrics['soul_tier'] as String;

    final Map<dynamic, dynamic> sub = _metrics['sub_metrics'] as Map<dynamic, dynamic>;

    return Scaffold(
      backgroundColor: IrmaTheme.lightWarmGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: IrmaTheme.earthyBrown),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Wellness Analytics',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: IrmaTheme.darkEspresso,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: IrmaTheme.earthyBrown),
            onPressed: _refreshData,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parent Metric Cards
            const Text(
              'Composite Vectors',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            const SizedBox(height: 12),
            _buildParentMetricCard('Body', body, bodyTier, IrmaTheme.empathyOrange),
            const SizedBox(height: 12),
            _buildParentMetricCard('Mind', mind, mindTier, IrmaTheme.sageGreen),
            const SizedBox(height: 12),
            _buildParentMetricCard('Soul', soul, soulTier, IrmaTheme.gentlePurple),
            const SizedBox(height: 28),

            // Sub-metrics Grid
            const Text(
              'Granular Sub-metrics',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                _buildSubMetricCell('Energy', sub['Energy'] as int, IrmaTheme.empathyOrange),
                _buildSubMetricCell('Wakefulness', sub['Wakefulness'] as int, IrmaTheme.empathyOrange),
                _buildSubMetricCell('Recovery', sub['Recovery'] as int, IrmaTheme.empathyOrange),
                
                _buildSubMetricCell('Focus', sub['Focus'] as int, IrmaTheme.sageGreen),
                _buildSubMetricCell('Creativity', sub['Creativity'] as int, IrmaTheme.sageGreen),
                _buildSubMetricCell('Motivation', sub['Motivation'] as int, IrmaTheme.sageGreen),
                
                _buildSubMetricCell('Mood', sub['Mood'] as int, IrmaTheme.gentlePurple),
                _buildSubMetricCell('Social Band', sub['SocialBandwidth'] as int, IrmaTheme.gentlePurple),
                _buildSubMetricCell('Stability', sub['Stability'] as int, IrmaTheme.gentlePurple),
              ],
            ),
            const SizedBox(height: 32),

            // Forecast Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '7-Day Projections',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: IrmaTheme.darkEspresso,
                  ),
                ),
                if (!_isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: IrmaTheme.earthyBrown,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 12),

            if (_isPremium)
              ..._forecast.map((dayData) {
                final date = dayData['date'] as DateTime;
                final bScore = dayData['body'] as int;
                final mScore = dayData['mind'] as int;
                final sScore = dayData['soul'] as int;
                
                final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final dateStr = '${weekdays[date.weekday - 1]} ${date.day}/${date.month}';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: IrmaTheme.cardDecoration(radius: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                          color: IrmaTheme.darkEspresso,
                        ),
                      ),
                      Row(
                        children: [
                          _buildMiniIndicator('B', bScore, IrmaTheme.empathyOrange),
                          const SizedBox(width: 8),
                          _buildMiniIndicator('M', mScore, IrmaTheme.sageGreen),
                          const SizedBox(width: 8),
                          _buildMiniIndicator('S', sScore, IrmaTheme.gentlePurple),
                        ],
                      )
                    ],
                  ),
                );
              }).toList()
            else
              // Subscription Teaser Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: IrmaTheme.cardDecoration(
                  color: IrmaTheme.lightPurpleTint,
                  borderColor: IrmaTheme.lightPurple,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lock_rounded, color: IrmaTheme.gentlePurple, size: 36),
                    const SizedBox(height: 12),
                    const Text(
                      'Unlock Lookahead Projections',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: IrmaTheme.darkEspresso,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Free accounts calculate active daily metrics. Upgrade to Premium to forecast emotional and physical patterns over the next 7 days.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: IrmaTheme.gray60,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Toggle Premium state for simulation testing
                        await StorageService.settingsBox.put('user_is_premium', true);
                        _refreshData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Premium mode unlocked for testing.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: IrmaTheme.gentlePurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Unlock Premium Forecasts',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentMetricCard(String title, int score, String tier, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: IrmaTheme.cardDecoration(borderColor: IrmaTheme.lightTan),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: IrmaTheme.darkEspresso,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$tier Tier Status',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  color: IrmaTheme.gray60,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: IrmaTheme.darkEspresso,
                ),
              ),
              const Text(
                '/100',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: IrmaTheme.gray60,
                ),
              ),
              const SizedBox(width: 16),
              // Ring dot indicator
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSubMetricCell(String name, int val, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: IrmaTheme.cardDecoration(radius: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: IrmaTheme.darkEspresso,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$val',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniIndicator(String label, int val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '$val',
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: IrmaTheme.darkEspresso,
            ),
          ),
        ],
      ),
    );
  }
}

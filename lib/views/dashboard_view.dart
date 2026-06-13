import 'package:flutter/material.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/services/advice_service.dart';
import 'package:irma/widgets/theme.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback onLogSymptomsPressed;
  const DashboardView({super.key, required this.onLogSymptomsPressed});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late Map<String, dynamic> _cycleState;
  late String _advice;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _cycleState = CycleEngine.getCurrentCycleState();
      _advice = AdviceService.generateDailyAdvice();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int currentDay = _cycleState['day'] as int;
    final String currentPhase = _cycleState['phase'] as String;
    final int daysUntilNext = _cycleState['days_until_next'] as int;
    final bool isLate = _cycleState['is_late'] as bool;
    final int avgLength = _cycleState['average_length'] as int;

    // Pick visual details based on phase
    Color phaseColor;
    IconData phaseIcon;
    switch (currentPhase) {
      case 'Menstruation':
        phaseColor = IrmaTheme.empathyOrange;
        phaseIcon = Icons.water_drop_rounded;
        break;
      case 'Follicular Phase':
        phaseColor = IrmaTheme.sageGreen;
        phaseIcon = Icons.spa_rounded;
        break;
      case 'Ovulation':
        phaseColor = IrmaTheme.gentlePurple;
        phaseIcon = Icons.wb_sunny_rounded;
        break;
      case 'Luteal Phase':
        phaseColor = IrmaTheme.mediumBrown;
        phaseIcon = Icons.nights_stay_rounded;
        break;
      default:
        phaseColor = IrmaTheme.zenYellow;
        phaseIcon = Icons.hourglass_empty_rounded;
    }

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
          'Irma',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: IrmaTheme.darkEspresso,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: IrmaTheme.earthyBrown),
            onPressed: () {
              _refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cycle projections updated.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Greeting
            const Text(
              'Good day.',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            const SizedBox(height: 20),

            // Cycle Status Ring Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: IrmaTheme.cardDecoration(borderColor: IrmaTheme.lightTan),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentPhase.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: phaseColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Day $currentDay of $avgLength',
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: IrmaTheme.darkEspresso,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: phaseColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(phaseIcon, color: phaseColor, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Progress line
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: (currentDay / avgLength).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: IrmaTheme.lightTan,
                      valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isLate ? 'Cycle is extended' : 'Next period onset',
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: IrmaTheme.gray60,
                        ),
                      ),
                      Text(
                        isLate ? 'Late' : 'in $daysUntilNext days',
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: IrmaTheme.earthyBrown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Irma's Advice Block
            const Text(
              'Irma\'s Advice',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: IrmaTheme.cardDecoration(
                color: IrmaTheme.lightSageTint,
                borderColor: IrmaTheme.lightGreen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, color: IrmaTheme.sageGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'DAILY INSIGHT',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: IrmaTheme.sageGreen,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _advice,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: IrmaTheme.darkEspresso,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Navigation Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onLogSymptomsPressed,
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Log Symptoms & Telemetry'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: IrmaTheme.earthyBrown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

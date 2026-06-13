import 'package:flutter/material.dart';
import 'package:irma/views/dashboard_view.dart';
import 'package:irma/views/daily_metrics_view.dart';
import 'package:irma/views/add_log_view.dart';
import 'package:irma/views/chat_view.dart';
import 'package:irma/views/profile_view.dart';
import 'package:irma/views/history_view.dart';
import 'package:irma/views/doctor_view.dart';
import 'package:irma/views/settings_view.dart';
import 'package:irma/views/privacy_policy_view.dart';
import 'package:irma/widgets/theme.dart';

class MainShell extends StatefulWidget {
  final Function(String route) onNavigation;
  const MainShell({super.key, required this.onNavigation});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _activeTab = 0; // 0: Home, 1: Chat, 2: Insight/Metrics, 3: Profile
  bool _showLogView = false;

  void _onSaveLog() {
    setState(() {
      _showLogView = false;
      _activeTab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_showLogView) {
      bodyContent = AddLogView(onLogSaved: _onSaveLog);
    } else {
      switch (_activeTab) {
        case 0:
          bodyContent = DashboardView(
            onLogSymptomsPressed: () => setState(() => _showLogView = true),
          );
          break;
        case 1:
          bodyContent = const ChatView();
          break;
        case 2:
          bodyContent = const DailyMetricsView();
          break;
        case 3:
          bodyContent = const ProfileView();
          break;
        default:
          bodyContent = DashboardView(
            onLogSymptomsPressed: () => setState(() => _showLogView = true),
          );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: bodyContent,

      // ── Off-Canvas Drawer ────────────────────────────────────────
      drawer: Drawer(
        width: 300,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            // Header — Brown 80 → Brown 90 gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                IrmaSpacing.lg, IrmaSpacing.xxl, IrmaSpacing.lg, IrmaSpacing.lg,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [IrmaColors.brown80, IrmaColors.brown90],
                ),
                borderRadius: BorderRadius.only(topRight: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo mark
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: IrmaColors.green50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: IrmaColors.green40, width: 1),
                      ),
                      child: const Icon(Icons.spa_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: IrmaSpacing.md),
                    Text(
                      'Irma',
                      style: IrmaTextStyles.label2xl.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your wellbeing companion',
                      style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.brown30),
                    ),
                  ],
                ),
              ),
            ),

            // Divider
            Container(height: 1, color: IrmaColors.brown20),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.sm, vertical: IrmaSpacing.sm),
                children: [
                  _buildDrawerTile(
                    title: 'Cycle History',
                    icon: Icons.history_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryView()));
                    },
                  ),
                  Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: IrmaSpacing.md), color: IrmaColors.brown20),
                  _buildDrawerTile(
                    title: 'Doctor Consultation',
                    icon: Icons.personal_injury_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorView()));
                    },
                  ),
                  Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: IrmaSpacing.md), color: IrmaColors.brown20),
                  _buildDrawerTile(
                    title: 'Privacy Settings',
                    icon: Icons.admin_panel_settings_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => SettingsView(onNavigation: widget.onNavigation),
                      ));
                    },
                  ),
                  Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: IrmaSpacing.md), color: IrmaColors.brown20),
                  _buildDrawerTile(
                    title: 'Privacy Policy',
                    icon: Icons.description_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyView()));
                    },
                  ),
                ],
              ),
            ),

            // Footer — version + home indicator bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(IrmaSpacing.lg),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: IrmaColors.brown20)),
              ),
              child: Column(
                children: [
                  Text(
                    'Irma v1.0.0  ·  Zero-telemetry health isolation',
                    style: IrmaTextStyles.labelXs.copyWith(color: IrmaColors.gray50),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: IrmaSpacing.sm),
                  // Home indicator bar (§9)
                  Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: IrmaColors.brown80,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Tab Bar (§12) ─────────────────────────────────────
      bottomNavigationBar: _showLogView ? null : _BottomTabBar(
        activeTab: _activeTab,
        onTap: (i) => setState(() {
          _showLogView = false;
          _activeTab = i;
        }),
        onLogSymptomsPressed: () => setState(() => _showLogView = true),
      ),
    );
  }

  Widget _buildDrawerTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.md, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: IrmaColors.brown10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: IrmaColors.brown80, size: 20),
      ),
      title: Text(title, style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100)),
      trailing: Icon(Icons.chevron_right_rounded, color: IrmaColors.gray30, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
    );
  }
}

// ── Custom Notched Tab Bar Painter ────────────────────────────────────

class _NotchedTabBarPainter extends CustomPainter {
  final Rect barRect;

  _NotchedTabBarPainter({required this.barRect});

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = barRect.width / 375.0;
    final double scaleY = barRect.height / 80.0;
    final double dx = barRect.left;
    final double dy = barRect.top;

    double rx(double val) => dx + val * scaleX;
    double ry(double val) => dy + val * scaleY;

    final path = Path()
      ..moveTo(rx(160.131), ry(28.6934))
      ..cubicTo(rx(147.454), ry(16.3789), rx(133.673), ry(0), rx(116), ry(0))
      ..lineTo(rx(40), ry(0))
      ..cubicTo(rx(17.9086), ry(0), rx(0), ry(17.9086), rx(0), ry(40))
      ..cubicTo(rx(0), ry(62.091), rx(17.9086), ry(80), rx(40), ry(80))
      ..lineTo(rx(335), ry(80))
      ..cubicTo(rx(357.091), ry(80), rx(375), ry(62.091), rx(375), ry(40))
      ..cubicTo(rx(375), ry(17.9086), rx(357.091), ry(0), rx(335), ry(0))
      ..lineTo(rx(260), ry(0))
      ..cubicTo(rx(242.327), ry(0), rx(228.546), ry(16.3789), rx(215.869), ry(28.6934))
      ..cubicTo(rx(208.666), ry(35.6912), rx(198.836), ry(40), rx(188), ry(40))
      ..cubicTo(rx(177.164), ry(40), rx(167.334), ry(35.6912), rx(160.131), ry(28.6934))
      ..close();

    // Draw shadow (5% opacity of Brown 80, stdDev 16, shifted dy=-16)
    final shadowPaint = Paint()
      ..color = IrmaColors.brown80.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawPath(path.shift(const Offset(0, -16)), shadowPaint);

    // Draw main background path
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _NotchedTabBarPainter oldDelegate) {
    return oldDelegate.barRect != barRect;
  }
}

// ── Custom bottom tab bar widget ────────────────────────────────────

class _BottomTabBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTap;
  final VoidCallback onLogSymptomsPressed;

  const _BottomTabBar({
    required this.activeTab,
    required this.onTap,
    required this.onLogSymptomsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    
    // Determine bar size (default Figma scale is W=375, centered on screen)
    final double barWidth = (screenWidth > 399) ? 375.0 : screenWidth - 24.0;
    final double startX = (screenWidth - barWidth) / 2;
    const double barHeight = 80.0;
    
    final Rect barRect = Rect.fromLTWH(startX, 0, barWidth, barHeight);
    final double scale = barWidth / 375.0;

    double getX(double relativeX) {
      return startX + (relativeX - 24.0) * scale;
    }

    return Container(
      height: barHeight + bottomPadding,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Painter
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: bottomPadding,
            child: CustomPaint(
              painter: _NotchedTabBarPainter(barRect: barRect),
            ),
          ),
          
          // Tab Item: Home (0)
          Positioned(
            left: getX(40),
            top: 16,
            child: _buildTabItem(0, Icons.home_rounded),
          ),
          
          // Tab Item: Chat (1)
          Positioned(
            left: getX(108),
            top: 16,
            child: _buildTabItem(1, Icons.chat_bubble_rounded),
          ),
          
          // Floating Action Button (FAB)
          Positioned(
            left: getX(180),
            top: -16, // Protrude upward exactly matching Figma y=16 vs bar top y=48
            child: GestureDetector(
              onTap: onLogSymptomsPressed,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: IrmaColors.green50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: IrmaColors.green50.withOpacity(0.5),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          
          // Tab Item: Metrics (2)
          Positioned(
            left: getX(267),
            top: 16,
            child: _buildTabItem(2, Icons.bar_chart_rounded),
          ),
          
          // Tab Item: Profile (3)
          Positioned(
            left: getX(335),
            top: 16,
            child: _buildTabItem(3, Icons.person_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon) {
    final bool active = activeTab == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        decoration: active
            ? const BoxDecoration(
                color: IrmaColors.brown10,
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          size: 24,
          color: active ? IrmaColors.brown80 : IrmaColors.brown30,
        ),
      ),
    );
  }
}

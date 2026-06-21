import 'package:flutter/material.dart';
import 'package:irma/views/dashboard_view.dart';
import 'package:irma/views/daily_metrics_view.dart';
import 'package:irma/views/add_log_view.dart';
import 'package:irma/views/chat_view.dart';
import 'package:irma/views/therapy_chatbot_view.dart';
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
      bodyContent = AddLogView(
        onLogSaved: _onSaveLog,
        onBackPressed: () => setState(() => _showLogView = false),
      );
    } else {
      switch (_activeTab) {
        case 0:
          bodyContent = DashboardView(
            onLogSymptomsPressed: () => setState(() => _showLogView = true),
            onProfilePressed: () => setState(() => _activeTab = 3),
          );
          break;
        case 1:
          bodyContent = TherapyChatbotView(
            onStartChatPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatView(
                    onBackPressed: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          );
          break;
        case 2:
          bodyContent = DailyMetricsView(
            onBackPressed: () => setState(() => _activeTab = 0),
          );
          break;
        case 3:
          bodyContent = const ProfileView();
          break;
        default:
          bodyContent = DashboardView(
            onLogSymptomsPressed: () => setState(() => _showLogView = true),
            onProfilePressed: () => setState(() => _activeTab = 3),
          );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
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
  final double screenWidth;
  final double bottomPadding;

  _NotchedTabBarPainter({
    required this.screenWidth,
    required this.bottomPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = screenWidth / 2;
    final double totalHeight = 80.0 + bottomPadding;

    final path = Path();
    // Start at top-left corner (rounded, starting at y = 40)
    path.moveTo(0, 40);
    // Cubic to top-left flat edge (40, 0)
    path.cubicTo(0, 17.9086, 17.9086, 0, 40, 0);
    // Line to left side of notch
    path.lineTo(centerX - 72, 0);
    
    // Left notch outer curve
    path.cubicTo(centerX - 54.327, 0, centerX - 40.546, 16.3789, centerX - 27.869, 28.6934);
    // Left notch inner curve
    path.cubicTo(centerX - 20.666, 35.6912, centerX - 10.836, 40, centerX, 40);
    // Right notch inner curve
    path.cubicTo(centerX + 10.836, 40, centerX + 20.666, 35.6912, centerX + 27.869, 28.6934);
    // Right notch outer curve
    path.cubicTo(centerX + 40.546, 16.3789, centerX + 54.327, 0, centerX + 72, 0);
    
    // Line to top-right corner
    path.lineTo(screenWidth - 40, 0);
    // Rounded corner to right edge (screenWidth, 40)
    path.cubicTo(screenWidth - 17.9086, 0, screenWidth, 17.9086, screenWidth, 40);
    // Line straight down to the bottom of the screen (including safe area)
    path.lineTo(screenWidth, totalHeight);
    // Line across the bottom of the screen
    path.lineTo(0, totalHeight);
    path.close();

    // Draw shadow (5% opacity of Brown 80, stdDev 16, shifted dy=-16)
    final shadowPaint = Paint()
      ..color = IrmaColors.brown80.withValues(alpha: 0.05)
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
    return oldDelegate.screenWidth != screenWidth || oldDelegate.bottomPadding != bottomPadding;
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
    const double barHeight = 80.0;

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
            bottom: 0,
            child: CustomPaint(
              painter: _NotchedTabBarPainter(
                screenWidth: screenWidth,
                bottomPadding: bottomPadding,
              ),
            ),
          ),
          
          // Tab Items in a Row
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: barHeight,
            child: Row(
              children: [
                const Spacer(flex: 3),
                _buildTabItem(0, Icons.home_rounded),
                const Spacer(flex: 4),
                _buildTabItem(1, Icons.chat_bubble_rounded),
                const Spacer(flex: 2),
                const SizedBox(width: 96), // Clearance for the center notch / FAB
                const Spacer(flex: 2),
                _buildTabItem(2, Icons.bar_chart_rounded),
                const Spacer(flex: 4),
                _buildTabItem(3, Icons.person_rounded),
                const Spacer(flex: 3),
              ],
            ),
          ),
          
          // Floating Action Button (FAB)
          Positioned(
            left: screenWidth / 2 - 32,
            top: -32, // Protrude upward exactly matching Figma y=16 vs bar top y=48
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
                      color: IrmaColors.green50.withValues(alpha: 0.5),
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

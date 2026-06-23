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
import 'package:irma/views/settings_navigation_view.dart';
import 'package:irma/widgets/theme.dart';

class MainShell extends StatefulWidget {
  final Function(String route) onNavigation;
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
            onNavigation: widget.onNavigation,
            onTabChanged: (index) {
              setState(() {
                if (index == -1) {
                  _showLogView = true;
                } else {
                  _showLogView = false;
                  _activeTab = index;
                }
              });
            },
          );
          break;
        case 1:
          bodyContent = ChatView(
            onBackPressed: () => setState(() => _activeTab = 0),
          );
          break;
        case 2:
          bodyContent = DailyMetricsView(
            onBackPressed: () => setState(() => _activeTab = 0),
          );
          break;
        case 3:
          bodyContent = SettingsNavigationView(onNavigation: widget.onNavigation, showBackButton: false);
          break;
        default:
          bodyContent = DashboardView(
            onLogSymptomsPressed: () => setState(() => _showLogView = true),
            onProfilePressed: () => setState(() => _activeTab = 3),
            onNavigation: widget.onNavigation,
            onTabChanged: (index) {
              setState(() {
                if (index == -1) {
                  _showLogView = true;
                } else {
                  _showLogView = false;
                  _activeTab = index;
                }
              });
            },
          );
      }
    }

    return Scaffold(
      key: MainShell.scaffoldKey,
      backgroundColor: Colors.white,
      extendBody: true,
      body: bodyContent,

      // ── Bottom Tab Bar (§12) ─────────────────────────────────────
      bottomNavigationBar: _showLogView ? null : IrmaBottomTabBar(
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

class IrmaBottomTabBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTap;
  final VoidCallback onLogSymptomsPressed;

  const IrmaBottomTabBar({
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

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

// ── Custom bottom tab bar widget ────────────────────────────────────

class _BottomTabBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTap;

  const _BottomTabBar({required this.activeTab, required this.onTap});

  static const List<({IconData icon, String label})> _tabs = [
    (icon: Icons.home_rounded,            label: 'Home'),
    (icon: Icons.chat_bubble_rounded,     label: 'Chat'),
    (icon: Icons.bar_chart_rounded,       label: 'Metrics'),
    (icon: Icons.person_rounded,          label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: IrmaColors.green50, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: IrmaSpacing.lg,
            vertical: IrmaSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) => _buildItem(i)),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final active = activeTab == index;
    final tab = _tabs[index];

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: active
            ? const EdgeInsets.symmetric(horizontal: IrmaSpacing.md, vertical: IrmaSpacing.xs)
            : const EdgeInsets.symmetric(horizontal: IrmaSpacing.xs, vertical: IrmaSpacing.xs),
        decoration: active
            ? BoxDecoration(
                color: IrmaColors.brown80,
                borderRadius: BorderRadius.circular(1000),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              size: 22,
              color: active ? Colors.white : IrmaColors.gray40,
            ),
            if (active) ...[
              const SizedBox(width: 6),
              Text(
                tab.label,
                style: IrmaTextStyles.labelSm.copyWith(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

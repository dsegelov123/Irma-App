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
      _activeTab = 0; // Go back to dashboard on save
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine active content
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
      body: bodyContent,
      
      // Off-Canvas Navigation Drawer (Stack C Menu targets)
      drawer: Drawer(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: const BoxDecoration(
                color: IrmaTheme.lightWarmGray,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: IrmaTheme.sageGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.spa_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Irma System',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: IrmaTheme.darkEspresso,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Drawer List Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerTile(
                    title: 'Cycle History',
                    icon: Icons.history_rounded,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryView()),
                      );
                    },
                  ),
                  _buildDrawerTile(
                    title: 'Doctor Consultation',
                    icon: Icons.personal_injury_rounded,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DoctorView()),
                      );
                    },
                  ),
                  _buildDrawerTile(
                    title: 'Privacy Settings',
                    icon: Icons.admin_panel_settings_rounded,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsView(onNavigation: widget.onNavigation),
                        ),
                      );
                    },
                  ),
                  _buildDrawerTile(
                    title: 'Privacy Policy',
                    icon: Icons.description_rounded,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyView()),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Drawer Footer / Info
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'Irma App v1.27.0',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: IrmaTheme.gray60,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: IrmaTheme.earthyBrown,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      
      // Bottom Navigation Bar (Section 12 of ui_design_system.md)
      bottomNavigationBar: _showLogView
          ? null // Hide bottom bar when logging symptom
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavBarItem(0, Icons.dashboard_rounded, 'Home'),
                      _buildNavBarItem(1, Icons.chat_bubble_rounded, 'Chat'),
                      _buildNavBarItem(2, Icons.analytics_rounded, 'Metrics'),
                      _buildNavBarItem(3, Icons.person_rounded, 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDrawerTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: IrmaTheme.earthyBrown),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: IrmaTheme.darkEspresso,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label) {
    final active = _activeTab == index;
    final activeColor = IrmaTheme.sageGreen;
    final inactiveColor = IrmaTheme.gray30;

    return InkWell(
      onTap: () {
        setState(() {
          _showLogView = false;
          _activeTab = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? activeColor : inactiveColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

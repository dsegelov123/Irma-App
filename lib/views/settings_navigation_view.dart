import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/views/history_view.dart';
import 'package:irma/views/doctor_view.dart';
import 'package:irma/views/notifications_view.dart';
import 'package:irma/views/settings_view.dart';
import 'package:irma/views/privacy_policy_view.dart';

class SettingsNavigationView extends StatefulWidget {
  final Function(String route)? onNavigation;
  final bool showBackButton;

  const SettingsNavigationView({
    super.key,
    this.onNavigation,
    this.showBackButton = true,
  });

  @override
  State<SettingsNavigationView> createState() => _SettingsNavigationViewState();
}

class _SettingsNavigationViewState extends State<SettingsNavigationView> {
  late bool _isPremium;
  late String _userEmail;
  late bool _biometricsEnabled;
  late String _privacyState;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final box = StorageService.settingsBox;
    setState(() {
      _isPremium = box.get('user_is_premium', defaultValue: false) as bool;
      _userEmail = box.get('auth_email', defaultValue: 'elementary221b@gmail.com') as String;
      _biometricsEnabled = box.get('biometrics_enforced', defaultValue: true) as bool;
      _privacyState = box.get('notification_privacy_state', defaultValue: 'State A') as String;
    });
  }

  Future<void> _togglePremium(bool value) async {
    final box = StorageService.settingsBox;
    await box.put('user_is_premium', value);
    setState(() {
      _isPremium = value;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Premium subscription activated.' : 'Reverted to Free subscription tier.'),
          duration: const Duration(seconds: 1),
          backgroundColor: IrmaColors.green50,
        ),
      );
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    final box = StorageService.settingsBox;
    await box.put('biometrics_enforced', value);
    setState(() {
      _biometricsEnabled = value;
    });
  }

  Future<void> _updatePrivacyState(String value) async {
    final box = StorageService.settingsBox;
    await box.put('notification_privacy_state', value);
    setState(() {
      _privacyState = value;
    });
  }

  Future<void> _triggerLogout() async {
    StorageService.wipeKeyFromMemory();
    if (widget.onNavigation != null) {
      widget.onNavigation!('signIn');
    } else {
      // Fallback if pushed via Navigator
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacementNamed('signIn');
    }
  }

  Future<void> _triggerPurge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text(
          'Purge All Data',
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This action is irreversible. All local symptom logs, E2EE keys, and stored credentials will be wiped permanently.',
          style: TextStyle(fontFamily: 'Urbanist', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Urbanist', color: IrmaTheme.earthyBrown, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: IrmaTheme.empathyOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Purge Now'),
          )
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.purgeAllData();
      if (widget.onNavigation != null) {
        widget.onNavigation!('loading');
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacementNamed('loading');
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text(
          'Help & Support',
          style: IrmaTextStyles.label2xlBold.copyWith(color: IrmaColors.brown100),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For support queries, feedback, or data privacy requests, contact us:',
              style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.gray70),
            ),
            const SizedBox(height: IrmaSpacing.md),
            Row(
              children: [
                const Icon(Icons.email_rounded, color: IrmaColors.green50, size: 18),
                const SizedBox(width: 8),
                Text(
                  'support@irma.app',
                  style: IrmaTextStyles.labelMdBold.copyWith(color: IrmaColors.brown100),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.shield_rounded, color: IrmaColors.green50, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Zero-telemetry active protection',
                  style: IrmaTextStyles.labelSmBold.copyWith(color: IrmaColors.gray60),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: IrmaColors.brown10,
      body: Stack(
        children: [
          // ── Header Curve ──
          Positioned(
            top: -518, // Matches y = -158 center in Settings.svg (diameter 720, so top = -158 - 360 = -518)
            left: (screenWidth - 720) / 2,
            child: Container(
              width: 720,
              height: 720,
              decoration: const BoxDecoration(
                color: IrmaColors.brown80,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ── Scrollable Body Content ──
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top back-button row (matching SVG: stroke-only circle at y=60, no title text)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  child: Row(
                    children: [
                      if (widget.showBackButton)
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      IrmaSpacing.lg,
                      IrmaSpacing.xs,
                      IrmaSpacing.lg,
                      IrmaSpacing.xxl + 80.0,
                    ),
                    child: Column(
                      children: [
                        // ── Profile avatar row: green circle | 128px avatar | orange circle ──
                        // Matches SVG: green 64×64 + avatar 128×128 clip-path + orange 64×64
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Green smiley button (monotone-mood-happy) — 64×64 per design tokens
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: IrmaColors.green50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.sentiment_satisfied_alt_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Avatar circle — 128×128 per SVG clipPath
                            Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                color: IrmaColors.green10,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: IrmaColors.brown80.withValues(alpha: 0.15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/edited_photo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(
                                      Icons.face_retouching_natural_rounded,
                                      color: IrmaColors.green50,
                                      size: 52,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Orange edit button (monotone-edit) — 64×64 per design tokens
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: IrmaColors.orange40,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // User info text — left-aligned block per Figma (frame w=196, column gap=8)
                        // Matches name=24px bold brown100, email/location=14px bold dark
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Shinomiya Kaguya',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: IrmaColors.brown100,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: IrmaColors.brown100.withValues(alpha: 0.64),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tokyo, Japan',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: IrmaColors.brown100.withValues(alpha: 0.48),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: IrmaSpacing.xl),

                        // ── Group 1: General Settings (General) ──
                        _buildGroupHeader('General Settings'),
                        const SizedBox(height: IrmaSpacing.sm),
                        Container(
                          decoration: IrmaCards.large(fill: Colors.white),
                          child: Column(
                            children: [
                              _buildMenuTile(
                                title: 'Cycle History',
                                subtitle: 'View past menstruation timeline logs',
                                icon: Icons.history_rounded,
                                iconColor: IrmaColors.green50,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryView())),
                              ),
                              _buildDivider(),
                              _buildMenuTile(
                                title: 'Doctor Consultation',
                                subtitle: 'Share symptom reports securely',
                                icon: Icons.personal_injury_rounded,
                                iconColor: IrmaColors.orange40,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorView())),
                              ),
                              _buildDivider(),
                              _buildMenuTile(
                                title: 'Advice & Logs',
                                subtitle: 'Daily alerts and clinical logs',
                                icon: Icons.notifications_none_rounded,
                                iconColor: IrmaColors.purple40,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsView())),
                              ),
                              _buildDivider(),
                              _buildMenuTile(
                                title: 'Security Settings',
                                subtitle: 'Encryption and biometric settings',
                                icon: Icons.security_rounded,
                                iconColor: IrmaColors.green60,
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => SettingsView(onNavigation: widget.onNavigation ?? (_) {}),
                                )),
                              ),
                              _buildDivider(),
                              _buildMenuTile(
                                title: 'Privacy Policy',
                                subtitle: 'Data processing and encryption policies',
                                icon: Icons.description_rounded,
                                iconColor: IrmaColors.brown60,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyView())),
                              ),
                              _buildDivider(),
                              // Upgrade Membership toggle
                              SwitchListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: IrmaSpacing.xs),
                                secondary: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: IrmaColors.yellow10,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.star_rounded, color: IrmaColors.yellow50, size: 20),
                                ),
                                title: Text('Pro Subscription', style: IrmaTextStyles.labelMdBold.copyWith(color: IrmaColors.brown100)),
                                subtitle: Text(
                                  _isPremium ? 'Premium activated' : 'Standard day-only analytics',
                                  style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60),
                                ),
                                activeColor: IrmaColors.green50,
                                activeTrackColor: IrmaColors.green20,
                                value: _isPremium,
                                onChanged: _togglePremium,
                              ),
                              _buildDivider(),
                              _buildMenuTile(
                                title: 'E2EE Cloud Escrow',
                                subtitle: 'Keys backed up locally & securely',
                                icon: Icons.cloud_done_outlined,
                                iconColor: IrmaColors.green50,
                                trailing: Text(
                                  'Secure',
                                  style: IrmaTextStyles.labelSmBold.copyWith(color: IrmaColors.green50),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: IrmaSpacing.xl),

                        // ── Group 2: Preferences ──
                        _buildGroupHeader('Preferences'),
                        const SizedBox(height: IrmaSpacing.sm),
                        Container(
                          decoration: IrmaCards.large(fill: Colors.white),
                          child: Column(
                            children: [
                              // Biometrics toggle
                              SwitchListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: IrmaSpacing.xs),
                                secondary: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: IrmaColors.brown10,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.fingerprint_rounded, color: IrmaColors.brown80, size: 20),
                                ),
                                title: Text('Biometric Authentication', style: IrmaTextStyles.labelMdBold.copyWith(color: IrmaColors.brown100)),
                                subtitle: Text(
                                  'Enforce TouchID/FaceID gate on boot',
                                  style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60),
                                ),
                                activeColor: IrmaColors.green50,
                                activeTrackColor: IrmaColors.green20,
                                value: _biometricsEnabled,
                                onChanged: _toggleBiometrics,
                              ),
                              _buildDivider(),
                              // Notification Privacy Row
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: IrmaSpacing.md),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: IrmaColors.brown10,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.visibility_off_rounded, color: IrmaColors.brown80, size: 20),
                                    ),
                                    const SizedBox(width: IrmaSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Notification Privacy', style: IrmaTextStyles.labelMdBold.copyWith(color: IrmaColors.brown100)),
                                          Text(
                                            _privacyState == 'State A' ? 'Conversational & Vague' : 'Discreet & Masked',
                                            style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      value: _privacyState,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: IrmaColors.brown80),
                                      underline: const SizedBox(),
                                      style: IrmaTextStyles.labelSmBold.copyWith(color: IrmaColors.brown80),
                                      items: const [
                                        DropdownMenuItem(value: 'State A', child: Text('State A')),
                                        DropdownMenuItem(value: 'State B', child: Text('State B')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) _updatePrivacyState(val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: IrmaSpacing.xl),

                        // ── Group 3: Support ──
                        _buildGroupHeader('Support'),
                        const SizedBox(height: IrmaSpacing.sm),
                        Container(
                          decoration: IrmaCards.large(fill: Colors.white),
                          child: _buildMenuTile(
                            title: 'Help Center & FAQ',
                            subtitle: 'Learn about zero-telemetry encryption',
                            icon: Icons.help_outline_rounded,
                            iconColor: IrmaColors.brown80,
                            onTap: _showHelpDialog,
                          ),
                        ),
                        const SizedBox(height: IrmaSpacing.xl),

                        // ── Group 4: Danger Zone ──
                        _buildGroupHeader('Danger Zone'),
                        const SizedBox(height: IrmaSpacing.sm),
                        Container(
                          decoration: IrmaCards.large(fill: Colors.white),
                          child: Column(
                            children: [
                              _buildMenuTile(
                                title: 'Explicit Logout',
                                subtitle: 'Destroys local session keys in memory',
                                icon: Icons.exit_to_app_rounded,
                                iconColor: IrmaColors.brown80,
                                onTap: _triggerLogout,
                              ),
                              _buildDivider(),
                              _buildMenuTile(
                                title: 'Purge Sandbox Database',
                                subtitle: 'Permanently resets local E2EE databases',
                                icon: Icons.delete_forever_rounded,
                                iconColor: IrmaColors.orange40,
                                onTap: _triggerPurge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: IrmaSpacing.xxl),

                        // iOS-like Home Indicator Mock (§9)
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: IrmaTextStyles.labelXsBold.copyWith(color: IrmaColors.brown80, letterSpacing: 1.2),
          ),
          const Icon(
            Icons.more_vert_rounded,
            color: IrmaColors.brown60,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
      color: IrmaColors.brown20,
    );
  }

  Widget _buildMenuTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: IrmaTextStyles.labelMdBold.copyWith(color: IrmaColors.brown100)),
      subtitle: Text(subtitle, style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: IrmaColors.gray30, size: 20),
      onTap: onTap,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/widgets/theme.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late bool _isPremium;
  late String _userEmail;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final box = StorageService.settingsBox;
    setState(() {
      _isPremium = box.get('user_is_premium', defaultValue: false) as bool;
      _userEmail = box.get('auth_email', defaultValue: 'user@example.co.uk') as String;
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IrmaColors.brown10,
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
        title: Text('My Profile', style: IrmaTextStyles.label2xl.copyWith(color: IrmaColors.brown100)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: 24.0 + 80.0 + 16.0,
        ),
        child: Column(
          children: [
            // Avatar (§11 profile-picture spec — size-2xl, edit-button-true)
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: IrmaColors.brown20,
                      shape: BoxShape.circle,
                      border: Border.all(color: IrmaColors.green50, width: 2),
                    ),
                    child: Center(
                      child: Text('IM', style: IrmaTextStyles.label2xl.copyWith(
                        color: IrmaColors.brown80)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: IrmaColors.green50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile info Card
            Container(
              padding: IrmaPadding.cardLarge,
              decoration: IrmaCards.large(),
              child: Column(children: [
                _buildProfileRow('Account Handle', _userEmail, Icons.email_outlined),
                Divider(height: IrmaSpacing.xl, color: IrmaColors.brown20),
                _buildProfileRow('Security Status', 'AES-256 Sandbox Sealed', Icons.lock_outline_rounded),
                Divider(height: IrmaSpacing.xl, color: IrmaColors.brown20),
                _buildProfileRow('Key Escrow', 'Cloud Escrow Configured', Icons.cloud_done_outlined),
              ]),
            ),
            const SizedBox(height: 24),

            // Subscription details Card
            Container(
              padding: IrmaPadding.cardLarge,
              decoration: IrmaCards.large(border: _isPremium ? IrmaColors.green50 : IrmaColors.gray20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Subscription Details', style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown100)),
                  Container(
                    padding: IrmaPadding.tagXs,
                    decoration: BoxDecoration(
                      color: _isPremium ? IrmaColors.green50 : IrmaColors.gray40,
                      borderRadius: BorderRadius.circular(IrmaRadius.pill),
                    ),
                    child: Text(
                      _isPremium ? 'PREMIUM' : 'FREE',
                      style: IrmaTextStyles.labelXs.copyWith(color: Colors.white),
                    ),
                  ),
                ]),
                const SizedBox(height: IrmaSpacing.sm),
                Text(
                  _isPremium
                      ? 'You have full access to lookahead forecasting, background synchronisation, and uncapped smart AI transcripts.'
                      : 'You are on the standard day-only analytics tier. Projections and wearable features are locked.',
                  style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.gray60),
                ),
                const SizedBox(height: IrmaSpacing.lg),
                SwitchListTile(
                  title: Text('Simulate Premium Upgrade', style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100)),
                  activeThumbColor: IrmaColors.green50,
                  value: _isPremium,
                  onChanged: _togglePremium,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, IconData icon) {
    return Row(children: [
      Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: IrmaColors.brown10, shape: BoxShape.circle),
        child: Icon(icon, color: IrmaColors.brown80, size: 18),
      ),
      const SizedBox(width: IrmaSpacing.md),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: IrmaTextStyles.labelXs.copyWith(color: IrmaColors.gray60)),
        const SizedBox(height: 2),
        Text(value, style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100)),
      ])),
    ]);
  }
}

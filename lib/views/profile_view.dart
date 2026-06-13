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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Premium subscription activated.' : 'Reverted to Free subscription tier.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'My Profile',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: IrmaTheme.darkEspresso,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar (Section 11)
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: IrmaTheme.lightTan,
                      shape: BoxShape.circle,
                      border: Border.all(color: IrmaTheme.sageGreen, width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        'IM',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: IrmaTheme.earthyBrown,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: IrmaTheme.sageGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile info Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: IrmaTheme.cardDecoration(borderColor: IrmaTheme.lightTan),
              child: Column(
                children: [
                  _buildProfileRow('Account Handle', _userEmail, Icons.email_outlined),
                  const Divider(height: 32, color: IrmaTheme.gray20),
                  _buildProfileRow('Security Status', 'AES-256 Sandbox Sealed', Icons.lock_outline_rounded),
                  const Divider(height: 32, color: IrmaTheme.gray20),
                  _buildProfileRow('Key Escrow', 'Cloud Escrow Configured', Icons.cloud_done_outlined),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subscription details Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: IrmaTheme.cardDecoration(
                borderColor: _isPremium ? IrmaTheme.sageGreen : IrmaTheme.gray20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subscription Details',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: IrmaTheme.darkEspresso,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isPremium ? IrmaTheme.sageGreen : IrmaTheme.gray30,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          _isPremium ? 'PREMIUM' : 'FREE TIER',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isPremium
                        ? 'You have full access to lookahead forecasting models, background wearable synchronization loops, and uncapped smart AI transcripts.'
                        : 'You are on the standard day-only analytics tier. Projections and HealthKit features are locked.',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      color: IrmaTheme.gray60,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Simulation switch
                  SwitchListTile(
                    title: const Text(
                      'Simulate Premium Upgrade',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    activeColor: IrmaTheme.sageGreen,
                    value: _isPremium,
                    onChanged: _togglePremium,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: IrmaTheme.earthyBrown, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12,
                  color: IrmaTheme.gray60,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: IrmaTheme.darkEspresso,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

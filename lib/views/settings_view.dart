import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/widgets/theme.dart';

class SettingsView extends StatefulWidget {
  final Function(String route) onNavigation;
  const SettingsView({super.key, required this.onNavigation});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
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
      _biometricsEnabled = box.get('biometrics_enforced', defaultValue: true) as bool;
      _privacyState = box.get('notification_privacy_state', defaultValue: 'State A') as String;
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    final box = StorageService.settingsBox;
    await box.put('biometrics_enforced', value);
    setState(() {
      _biometricsEnabled = value;
    });
  }

  Future<void> _updatePrivacyState(String? value) async {
    if (value == null) return;
    final box = StorageService.settingsBox;
    await box.put('notification_privacy_state', value);
    setState(() {
      _privacyState = value;
    });
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
      // Execute Cloud Database Purge (Section 8.1)
      await StorageService.purgeAllData();
      widget.onNavigation('loading');
    }
  }

  Future<void> _triggerLogout() async {
    // Execute Explicit Logout Destruction State (Section 8.1)
    StorageService.wipeKeyFromMemory();
    widget.onNavigation('signIn');
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
          'Security Settings',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Biometrics settings
            const Text(
              'Hardware Protection',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: IrmaTheme.cardDecoration(radius: 24),
              child: SwitchListTile(
                title: const Text(
                  'Biometric Authentication',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: IrmaTheme.darkEspresso,
                  ),
                ),
                subtitle: const Text(
                  'Enforces native TouchID / FaceID gates check on app boot and resumption lifecycle triggers.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    color: IrmaTheme.gray60,
                  ),
                ),
                activeColor: IrmaTheme.sageGreen,
                value: _biometricsEnabled,
                onChanged: _toggleBiometrics,
              ),
            ),
            const SizedBox(height: 28),

            // Notification Privacy States settings
            const Text(
              'Notification Privacy Filters',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: IrmaTheme.cardDecoration(radius: 24),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text(
                      'State A (Conversational & Vague)',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Engaging and supportive notices without revealing explicit clinical variables.',
                      style: TextStyle(fontFamily: 'Urbanist', fontSize: 12),
                    ),
                    value: 'State A',
                    groupValue: _privacyState,
                    activeColor: IrmaTheme.sageGreen,
                    onChanged: _updatePrivacyState,
                  ),
                  const Divider(height: 24),
                  RadioListTile<String>(
                    title: const Text(
                      'State B (Discreet / Masked)',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Sterilised system-style notices for absolute lock screen privacy.',
                      style: TextStyle(fontFamily: 'Urbanist', fontSize: 12),
                    ),
                    value: 'State B',
                    groupValue: _privacyState,
                    activeColor: IrmaTheme.sageGreen,
                    onChanged: _updatePrivacyState,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Danger Zone
            const Text(
              'Danger Zone',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IrmaTheme.empathyOrange,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: IrmaTheme.cardDecoration(
                borderColor: IrmaTheme.empathyOrange.withOpacity(0.3),
                radius: 24,
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Explicit Logout',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: IrmaTheme.darkEspresso,
                      ),
                    ),
                    subtitle: const Text(
                      'Destroys transient o oestrogen-supporting decryption keys in memory. Requires full credentials re-authentication to enter.',
                      style: TextStyle(fontFamily: 'Urbanist', fontSize: 12),
                    ),
                    trailing: const Icon(Icons.exit_to_app_rounded, color: IrmaTheme.earthyBrown),
                    onTap: _triggerLogout,
                  ),
                  const Divider(height: 24),
                  ListTile(
                    title: const Text(
                      'Purge Cryptographic Sandbox',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: IrmaTheme.empathyOrange,
                      ),
                    ),
                    subtitle: const Text(
                      'Permanently deletes local database files, cycle starts arrays, and E2EE keys. Resets app to clean state.',
                      style: TextStyle(fontFamily: 'Urbanist', fontSize: 12),
                    ),
                    trailing: const Icon(Icons.delete_forever_rounded, color: IrmaTheme.empathyOrange),
                    onTap: _triggerPurge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

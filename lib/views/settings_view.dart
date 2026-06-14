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
      backgroundColor: IrmaColors.gray10,
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
        title: Text('Security Settings', style: IrmaTextStyles.label2xl.copyWith(color: IrmaColors.brown100)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hardware Protection', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
            const SizedBox(height: IrmaSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.sm, vertical: IrmaSpacing.xs),
              decoration: IrmaCards.standard(),
              child: SwitchListTile(
                title: Text('Biometric Authentication',
                    style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100)),
                subtitle: Text(
                  'Enforces native TouchID / FaceID gates on boot and resumption lifecycle triggers.',
                  style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60),
                ),
                activeThumbColor: IrmaColors.green50,
                activeTrackColor: IrmaColors.green20,
                value: _biometricsEnabled,
                onChanged: _toggleBiometrics,
              ),
            ),
            const SizedBox(height: IrmaSpacing.xl),
            Text('Notification Privacy Filters', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
            const SizedBox(height: IrmaSpacing.sm),
            Container(
              padding: const EdgeInsets.all(IrmaSpacing.md),
              decoration: IrmaCards.standard(),
              child: RadioGroup<String>(
                groupValue: _privacyState,
                onChanged: _updatePrivacyState,
                child: Column(children: [
                  RadioListTile<String>(
                    title: Text('State A (Conversational & Vague)',
                        style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100)),
                    subtitle: Text(
                      'Engaging and supportive notices without revealing explicit clinical variables.',
                      style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60),
                    ),
                    value: 'State A',
                    activeColor: IrmaColors.green50,
                  ),
                  Divider(height: IrmaSpacing.lg, color: IrmaColors.brown20),
                  RadioListTile<String>(
                    title: Text('State B (Discreet / Masked)',
                        style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100)),
                    subtitle: Text(
                      'Sterilised system-style notices for absolute lock screen privacy.',
                      style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60),
                    ),
                    value: 'State B',
                    activeColor: IrmaColors.green50,
                  ),
                ]),
              ),
            ),
            const SizedBox(height: IrmaSpacing.xl),
            Text('Danger Zone', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.orange40)),
            const SizedBox(height: IrmaSpacing.sm),
            Container(
              padding: const EdgeInsets.all(IrmaSpacing.lg),
              decoration: IrmaCards.standard(border: IrmaColors.orange30),
              child: Column(children: [
                ListTile(
                  title: Text('Explicit Logout',
                      style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100)),
                  subtitle: Text(
                    'Destroys transient decryption keys in memory. Requires full credential re-authentication.',
                    style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60),
                  ),
                  trailing: Icon(Icons.exit_to_app_rounded, color: IrmaColors.brown80),
                  onTap: _triggerLogout,
                ),
                Divider(height: IrmaSpacing.lg, color: IrmaColors.brown20),
                ListTile(
                  title: Text('Purge Cryptographic Sandbox',
                      style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.orange40)),
                  subtitle: Text(
                    'Permanently deletes local database files, cycle start arrays, and E2EE keys. Resets to clean state.',
                    style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60),
                  ),
                  trailing: Icon(Icons.delete_forever_rounded, color: IrmaColors.orange40),
                  onTap: _triggerPurge,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

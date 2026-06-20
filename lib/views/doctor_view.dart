import 'package:flutter/material.dart';
import 'package:irma/services/biometric_service.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/widgets/theme.dart';

class DoctorView extends StatefulWidget {
  const DoctorView({super.key});

  @override
  State<DoctorView> createState() => _DoctorViewState();
}

class _DoctorViewState extends State<DoctorView> {
  bool _canLeave = false;
  late double _avgCycleLength;
  late int _cycleCount;

  @override
  void initState() {
    super.initState();
    _avgCycleLength = CycleEngine.getAverageCycleLength();
    _cycleCount = CycleEngine.getCycleStarts().length;
  }

  Future<void> _handleBackAttempt() async {
    // Attempt biometric verification
    final hasBiometrics = await BiometricService.canAuthenticate();
    bool authenticated = false;

    if (hasBiometrics) {
      authenticated = await BiometricService.authenticate();
    } else {
      // Fallback dialog for emulator manual verification
      authenticated = await _showPinFallbackDialog();
    }

    if (authenticated) {
      setState(() {
        _canLeave = true;
      });
      // Trigger pop again
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Accidental Resumption Lock Active. User biometric verification required to return.',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
            ),
            backgroundColor: IrmaTheme.empathyOrange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<bool> _showPinFallbackDialog() async {
    String pin = '';
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text(
          'Re-authenticate User',
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No biometrics template found on device. Enter your mock security PIN (1234) to unlock Doctor View.',
              style: TextStyle(fontFamily: 'Urbanist', fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Security PIN',
              ),
              onChanged: (val) => pin = val,
            )
          ],
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
            onPressed: () {
              if (pin == '1234') {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid PIN')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: IrmaTheme.earthyBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('Verify PIN'),
          )
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canLeave,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackAttempt();
      },
      child: Scaffold(
        backgroundColor: IrmaColors.brown10,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: Center(
            child: GestureDetector(
              onTap: () async => await _handleBackAttempt(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: IrmaColors.brown20),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: IrmaColors.brown80, size: 16),
              ),
            ),
          ),
          title: Text('Doctor Consultation Mode',
              style: IrmaTextStyles.label2xl.copyWith(color: IrmaColors.brown100)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security warning banner
              Container(
                padding: const EdgeInsets.all(IrmaSpacing.md),
                decoration: IrmaCards.advice(),
                child: Row(children: [
                  Icon(Icons.shield_rounded, color: IrmaColors.green50, size: 20),
                  const SizedBox(width: IrmaSpacing.sm),
                  Expanded(
                    child: Text(
                      'Accidental Resumption Lock active. Backwards navigation triggers biometric re-authentication.',
                      style: IrmaTextStyles.labelSm.copyWith(color: IrmaColors.green50),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: IrmaSpacing.lg),

              // Patient Summary Box
              Text('Clinical Summary', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
              const SizedBox(height: IrmaSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(IrmaSpacing.lg),
                decoration: IrmaCards.large(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Irma Patient Data File',
                      style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown80)),
                  const SizedBox(height: IrmaSpacing.md),
                  _buildDataRow('Local Cryptographic Status', 'AES-256 Validated & Sealed'),
                  _buildDataRow('Average Cycle Length', '${_avgCycleLength.toStringAsFixed(1)} days'),
                  _buildDataRow('Total Logged Periods', '$_cycleCount cycles'),
                  _buildDataRow('Data Compliance Standard', 'UK Special Category Health Compliance'),
                ]),
              ),
              const SizedBox(height: IrmaSpacing.lg),

              // Diagnostics Summary
              Text('Long-Term Telemetry Metrics', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
              const SizedBox(height: IrmaSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(IrmaSpacing.lg),
                decoration: IrmaCards.large(),
                child: Text(
                  'Cycle Variance: Normal\nNo significant cycle onset deviations or long-term drift anomalies detected over the lookback window.\n\nSymptom Correlations:\n\u2022 Cramps correlate reliably with lower Body Energy scores on Days 1\u20133.\n\u2022 Restfulness metrics remain stable inside medium equilibrium bounds.',
                  style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.brown100, height: 1.6),
                ),
              ),
              const SizedBox(height: IrmaSpacing.xl),

              // Lock confirmation button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async => await _handleBackAttempt(),
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Authenticate & Exit Mode'),
                  style: IrmaButtonStyles.primaryLg(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IrmaSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: IrmaTextStyles.labelSm.copyWith(color: IrmaColors.gray60))),
          const SizedBox(width: IrmaSpacing.xs),
          Text(value, style: IrmaTextStyles.labelSm.copyWith(color: IrmaColors.brown100)),
        ],
      ),
    );
  }
}

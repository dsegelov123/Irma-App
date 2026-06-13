import 'package:flutter/material.dart';
import 'package:irma/widgets/theme.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IrmaColors.gray10,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: IrmaColors.brown80),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Privacy Policy',
          style: IrmaTextStyles.label2xl,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(IrmaSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(IrmaSpacing.lg),
          decoration: IrmaCards.large(fill: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UK Data Privacy & Compliance Notice',
                style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100),
              ),
              const SizedBox(height: IrmaSpacing.md),
              Text(
                'This application is built in strict alignment with special category health data protections under the UK General Data Protection Regulation (UK GDPR). Your data integrity is preserved using advanced cryptographic isolation pipelines.',
                style: IrmaTextStyles.paraSm.copyWith(
                  height: 1.5,
                  color: IrmaColors.brown100,
                ),
              ),
              const SizedBox(height: IrmaSpacing.lg),
              Text(
                '1. The Zero-Telemetry Rule',
                style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown80),
              ),
              const SizedBox(height: IrmaSpacing.xs),
              Text(
                'Under no circumstances is your personal health telemetry (including cycle lengths, logged symptoms, physiological phase states, daily notes, or conversational chat transcripts) shared with third-party analytical SDKs or crash-reporting frameworks. Non-health lifecycle tracking is strictly confined to UI navigation counters (e.g. screen views).',
                style: IrmaTextStyles.paraSm.copyWith(
                  height: 1.4,
                  color: IrmaColors.gray60,
                ),
              ),
              const SizedBox(height: IrmaSpacing.lg),
              Text(
                '2. Server-Blind Encryption (E2EE)',
                style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown80),
              ),
              const SizedBox(height: IrmaSpacing.xs),
              Text(
                'All tracking coordinates and text conversations are encrypted locally on your mobile device using AES-256 before synchronization occurs. The remote database stores only unreadable, encrypted cryptographic blobs. The service provider has zero visibility into your data contents.',
                style: IrmaTextStyles.paraSm.copyWith(
                  height: 1.4,
                  color: IrmaColors.gray60,
                ),
              ),
              const SizedBox(height: IrmaSpacing.lg),
              Text(
                '3. Key Escrow & Recovery',
                style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown80),
              ),
              const SizedBox(height: IrmaSpacing.xs),
              Text(
                'Your unique decryption key is generated locally upon account setup and backed up to a secure cloud Key Management Service (KMS) linked to your verified authentication token. Logging into a new device retrieves your key securely to execute local decryption.',
                style: IrmaTextStyles.paraSm.copyWith(
                  height: 1.4,
                  color: IrmaColors.gray60,
                ),
              ),
              const SizedBox(height: IrmaSpacing.lg),
              Text(
                '4. Patient Control & Erasure Rights',
                style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown80),
              ),
              const SizedBox(height: IrmaSpacing.xs),
              Text(
                'You retain absolute ownership of your data history. Triggering the "Purge Cryptographic Sandbox" command in Settings permanently destroys your keys and locally cached databases, ensuring absolute, non-recoverable erasure.',
                style: IrmaTextStyles.paraSm.copyWith(
                  height: 1.4,
                  color: IrmaColors.gray60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

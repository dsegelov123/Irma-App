import 'package:flutter/material.dart';
import 'package:irma/widgets/theme.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

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
          'Privacy Policy',
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
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: IrmaTheme.cardDecoration(radius: 32),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UK Data Privacy & Compliance Notice',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: IrmaTheme.darkEspresso,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'This application is built in strict alignment with special category health data protections under the UK General Data Protection Regulation (UK GDPR). Your data integrity is preserved using advanced cryptographic isolation pipelines.',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  height: 1.5,
                  color: IrmaTheme.darkEspresso,
                ),
              ),
              SizedBox(height: 24),
              Text(
                '1. The Zero-Telemetry Rule',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: IrmaTheme.earthyBrown,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Under no circumstances is your personal health telemetry (including cycle lengths, logged symptoms, physiological phase states, daily notes, or conversational chat transcripts) shared with third-party analytical SDKs or crash-reporting frameworks. Non-health lifecycle tracking is strictly confined to UI navigation counters (e.g. screen views).',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 13,
                  height: 1.4,
                  color: IrmaTheme.gray60,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '2. Server-Blind Encryption (E2EE)',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: IrmaTheme.earthyBrown,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'All tracking coordinates and text conversations are encrypted locally on your mobile device using AES-256 before synchronization occurs. The remote database stores only unreadable, encrypted cryptographic blobs. The service provider has zero visibility into your data contents.',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 13,
                  height: 1.4,
                  color: IrmaTheme.gray60,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '3. Key Escrow & Recovery',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: IrmaTheme.earthyBrown,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your unique decryption key is generated locally upon account setup and backed up to a secure cloud Key Management Service (KMS) linked to your verified authentication token. Logging into a new device retrieves your key securely to execute local decryption.',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 13,
                  height: 1.4,
                  color: IrmaTheme.gray60,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '4. Patient Control & Erasure Rights',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: IrmaTheme.earthyBrown,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You retain absolute ownership of your data history. Triggering the "Purge Cryptographic Sandbox" command in Settings permanently destroys your keys and locally cached databases, ensuring absolute, non-recoverable erasure.',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 13,
                  height: 1.4,
                  color: IrmaTheme.gray60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

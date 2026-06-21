import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/widgets/irma_top_bar.dart';

class TherapyChatbotView extends StatelessWidget {
  final VoidCallback onStartChatPressed;

  const TherapyChatbotView({
    super.key,
    required this.onStartChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Exact shadow defined in Figma design tokens: shadow-32-16
    final BoxShadow buttonShadow = BoxShadow(
      color: const Color(0xFF4B3425).withOpacity(0.15),
      offset: const Offset(0, 16),
      blurRadius: 32,
    );

    return Scaffold(
      backgroundColor: IrmaColors.brown10,
      body: Stack(
        children: [
          // ── Header SVG Background Decoration ────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 430,
            child: SvgPicture.asset(
              'assets/images/therapy_header_bg.svg',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),

          // ── Scrollable Body Content ───────────────────────────────
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Clearance height to sit below the IrmaTopBar (80px)
                    const SizedBox(height: 100),

                    // ── 1. Total Conversations Count (White display) ──────────
                    Text(
                      '1571',
                      style: IrmaTextStyles.displaySmBold.copyWith(
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Conversations',
                      style: IrmaTextStyles.headingSmSemibold.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── 2. Monthly Stats Row (Limit & Response Speed) ─────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left Column: Remaining monthly count
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.robot(),
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '32',
                                  style: IrmaTextStyles.headingMdBold.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Left this month',
                              style: IrmaTextStyles.paragraphSmSemibold.copyWith(
                                color: Colors.white.withOpacity(0.64),
                              ),
                            ),
                          ],
                        ),

                        // Gap of 64 between columns
                        const SizedBox(width: 64),

                        // Right Column: Support response speed
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.chartBar(),
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Slow',
                                  style: IrmaTextStyles.headingMdBold.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Response & Support',
                              style: IrmaTextStyles.paragraphSmSemibold.copyWith(
                                color: Colors.white.withOpacity(0.64),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // ── 3. Interactive Buttons Row ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left button: 64x64, orange, plus icon
                        GestureDetector(
                          onTap: onStartChatPressed,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: IrmaColors.orange40,
                              shape: BoxShape.circle,
                              boxShadow: [buttonShadow],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Center button: 96x96, white, plus icon
                        GestureDetector(
                          onTap: onStartChatPressed,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [buttonShadow],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: IrmaColors.brown80,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Right button: 64x64, green, plus icon
                        GestureDetector(
                          onTap: onStartChatPressed,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: IrmaColors.green50,
                              shape: BoxShape.circle,
                              boxShadow: [buttonShadow],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // ── 4. Upgrade Card ───────────────────────────────────────
                    Container(
                      width: 343,
                      height: 166,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EAD7), // Green 20
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFD5C2B9), // Brown 30
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Vector Leaves Background (fills the card bounds)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(23),
                              child: SvgPicture.asset(
                                'assets/images/therapy_leaves.svg',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),

                          // Overlaid Page Indicator Dots Pill (sitting on the left at x=86, y=33)
                          Positioned(
                            left: 86,
                            top: 33,
                            child: Container(
                              width: 53,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4B3425).withOpacity(0.06),
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: IrmaColors.brown60,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: IrmaColors.brown60,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: IrmaColors.brown60,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Right side: Texts & "Subscribe" Button (positioned starting at x=170)
                          Positioned(
                            left: 170,
                            top: 16,
                            right: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upgrade to Pro!',
                                  style: IrmaTextStyles.headingSmBold.copyWith(
                                    color: IrmaColors.brown80,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Bullet point 1: Live & Fast support
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: IrmaColors.brown80,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '24/7 Live & Fast Support',
                                        style: IrmaTextStyles.paragraphXsSemibold.copyWith(
                                          color: IrmaColors.brown80,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Bullet point 2: Unlimited conversations
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: IrmaColors.brown80,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Unlimited Conversations!!',
                                        style: IrmaTextStyles.paragraphXsSemibold.copyWith(
                                          color: IrmaColors.brown80,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),

                                // Subscribe CTA Button
                                SizedBox(
                                  width: 120,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Action for Upgrade
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: IrmaColors.brown80,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Subscribe',
                                      style: IrmaTextStyles.labelSm.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120), // Bottom padding clearance for tab bar (80px + safe area)
                  ],
                ),
              ),
            ),
          ),

          // ── 5. Top Bar ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: SizedBox(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'Therapy Chatbot',
                        style: IrmaTextStyles.label2xlBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

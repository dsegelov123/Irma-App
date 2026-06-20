import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/widgets/irma_top_bar.dart';

class ChatView extends StatefulWidget {
  final VoidCallback onBackPressed;
  const ChatView({
    super.key,
    required this.onBackPressed,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: IrmaColors.brown10,

      // ── Custom Layout with Exact Top & Bottom Bars ──────────────────
      body: Column(
        children: [
          // ── Reusable Top Header (height 124px including status bar) ──
          IrmaTopBar(
            title: 'Doctor Consultation',
            onBackPressed: widget.onBackPressed,
            actions: [
              IrmaTopBarActionButton(
                icon: Icons.search_rounded,
                onTap: () {},
              ),
              IrmaTopBarActionButton(
                icon: Icons.tune_rounded,
                onTap: () {},
              ),
            ],
          ),

          // ── Empty State Center Placeholder ──────────────────────────
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: IrmaSpacing.lg,
                  vertical: IrmaSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Illustration Circle (248x248, Brown 20 background)
                    Container(
                      width: 248,
                      height: 248,
                      decoration: const BoxDecoration(
                        color: IrmaColors.brown20,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: SvgPicture.asset(
                          'assets/images/therapy_illustration.svg',
                          width: 248,
                          height: 248,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Limited Knowledge Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: IrmaColors.orange20,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'LIMITED KNOWLEDGE',
                        style: IrmaTextStyles.labelXsBold.copyWith(
                          color: IrmaColors.orange40,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title & Description Text Block
                    SizedBox(
                      width: 231,
                      child: Column(
                        children: [
                          Text(
                            'Limited Knowledge',
                            style: IrmaTextStyles.headingMdBold.copyWith(
                              color: IrmaColors.brown80,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No human being is perfect. So is chatbots. Dr Freud’s knowledge is limted to 2021.',
                            style: IrmaTextStyles.paragraphMdMedium.copyWith(
                              color: IrmaColors.brown100,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Pagination Indicators (6 dots, 8x8, 8px gap)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final bool isActive = index == 0;
                        return Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.only(
                            right: index == 5 ? 0 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive ? IrmaColors.brown80 : IrmaColors.brown20,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Input Bar (height 110px + padding) ──────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4B3425).withValues(alpha: 0.05),
                  offset: const Offset(0, 0),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF4B3425).withValues(alpha: 0.05),
                  offset: const Offset(0, -5),
                  blurRadius: 11,
                ),
                BoxShadow(
                  color: const Color(0xFF4B3425).withValues(alpha: 0.04),
                  offset: const Offset(0, -20),
                  blurRadius: 20,
                ),
                BoxShadow(
                  color: const Color(0xFF4B3425).withValues(alpha: 0.03),
                  offset: const Offset(0, -45),
                  blurRadius: 27,
                ),
                BoxShadow(
                  color: const Color(0xFF4B3425).withValues(alpha: 0.01),
                  offset: const Offset(0, -80),
                  blurRadius: 32,
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: 12,
              left: 12,
              right: 12,
              bottom: bottomPadding > 0 ? bottomPadding : 12,
            ),
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  // Input Field Box (x=12, width 279, height 48)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: IrmaColors.brown10,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: TextField(
                        controller: _textController,
                        style: IrmaTextStyles.paragraphMdMedium.copyWith(
                          color: IrmaColors.brown80,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(
                              Icons.add_circle_outline_rounded,
                              color: IrmaColors.brown80,
                              size: 24,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 24,
                          ),
                          hintText: 'Type to start chatting...',
                          hintStyle: IrmaTextStyles.paragraphMdMedium.copyWith(
                            color: IrmaColors.brown50,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: IrmaSpacing.sm,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24), // Spacing between input and send button
                  // Send Button (48x48 Green 50 circle at x=315)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: IrmaColors.green50,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.subdirectory_arrow_left_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

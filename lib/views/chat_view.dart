import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:irma/widgets/theme.dart';

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
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: IrmaColors.brown10,

      // ── Custom Layout with Exact Top & Bottom Bars ──────────────────
      body: Column(
        children: [
          // ── Custom Top Header (height 124px including status bar) ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4B3425).withValues(alpha: 0.05),
                  offset: const Offset(0, 0),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF4B3425).withValues(alpha: 0.05),
                  offset: const Offset(0, 7),
                  blurRadius: 15,
                ),
                BoxShadow(
                  color: const Color(0xFF4B3425).withValues(alpha: 0.04),
                  offset: const Offset(0, 28),
                  blurRadius: 28,
                ),
                BoxShadow(
                  color: const Color(0xFF4B3425).withValues(alpha: 0.03),
                  offset: const Offset(0, 62),
                  blurRadius: 37,
                ),
                BoxShadow(
                  color: const Color(0xFF4B3425).withValues(alpha: 0.01),
                  offset: const Offset(0, 110),
                  blurRadius: 44,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: topPadding),
                SizedBox(
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Back Button (48x48 Brown 10 circle with Brown 80 chevron)
                        GestureDetector(
                          onTap: widget.onBackPressed,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: IrmaColors.brown10,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: IrmaColors.brown80,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9.2), // Starts exactly at x=73.2 (16 + 48 + 9.2)
                        Expanded(
                          child: Text(
                            'Doctor Consultation',
                            style: IrmaTextStyles.label2xlBold.copyWith(
                              color: IrmaColors.brown100,
                            ),
                          ),
                        ),
                        // Search Button (48x48 with Brown 20 outline)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: IrmaColors.brown20, width: 1),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search_rounded, color: IrmaColors.brown80, size: 20),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter Button (48x48 with Brown 20 outline)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: IrmaColors.brown20, width: 1),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.tune_rounded, color: IrmaColors.brown80, size: 20),
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

import 'package:flutter/material.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/widgets/irma_top_bar.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

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
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _textController.clear();
    });

    // Scroll to bottom after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(ChatMessage message) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0, left: 48.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: IrmaColors.brown80,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text(
                      message.text,
                      style: IrmaTextStyles.paragraphMdMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Tail at bottom right of the bubble
                  Positioned(
                    bottom: -12,
                    right: 0,
                    width: 12,
                    height: 12,
                    child: CustomPaint(
                      painter: BubbleTailPainter(IrmaColors.brown80),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Avatar to the right of the bubble (40x40, rx=20)
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF6D4B36),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: IrmaColors.brown40,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: IrmaColors.brown10,

      // ── Custom Layout with Exact Top & Bottom Bars ──────────────────
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 80.0),

              // ── Main Content Feed Area ──────────────────────────
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: IrmaSpacing.lg,
                            vertical: IrmaSpacing.md,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Illustration (width 248, natural height)
                              Image.asset(
                                'assets/images/main_ai_image.png',
                                width: 248,
                                fit: BoxFit.contain,
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
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: IrmaSpacing.lg,
                          vertical: IrmaSpacing.md,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessage(message);
                        },
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
                            onSubmitted: (_) => _sendMessage(),
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
                          onPressed: _sendMessage,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IrmaTopBar(
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
          ),
        ],
      ),
    );
  }
}

class BubbleTailPainter extends CustomPainter {
  final Color color;
  BubbleTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..cubicTo(size.width * 0.44775, size.height, 0, size.height * 0.55228, 0, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

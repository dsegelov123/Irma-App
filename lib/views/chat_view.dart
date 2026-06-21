import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  bool _isIrmaTyping = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
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

    _scrollToBottom();

    // 2 second pause before showing typing indicator
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isIrmaTyping = true;
      });
      _scrollToBottom();

      // Show typing indicator for at least 2 seconds before rendering the reply
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isIrmaTyping = false;
          _messages.add(ChatMessage(
            text: "I hear you. Every phase of your cycle is a natural progression of your body's inner wisdom. Let's explore how you are feeling today.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      });
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
                      style: IrmaTextStyles.labelMdBold.copyWith(
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
      // Bot message (Irma) - Styled exactly like the dashboard's Irma's Advice section
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 48.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Irma profile image in circle
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: IrmaColors.brown10,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/irma_title_profile.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Main bubble + tail Column
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: IrmaColors.brown20,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                        bottomLeft: Radius.zero,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text(
                      message.text,
                      style: IrmaTextStyles.labelMdBold.copyWith(
                        color: IrmaColors.brown100.withValues(alpha: 0.64),
                        height: 1.5,
                      ),
                    ),
                  ),
                  // Speech-bubble tail
                  CustomPaint(
                    size: const Size(12, 12),
                    painter: BubbleTailLeftPainter(IrmaColors.brown20),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, right: 48.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Irma profile image in circle
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: IrmaColors.brown10,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/irma_title_profile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Main bubble + tail Column
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: IrmaColors.brown20,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                      bottomLeft: Radius.zero,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Irma is typing',
                        style: IrmaTextStyles.labelMdBold.copyWith(
                          color: IrmaColors.brown100.withValues(alpha: 0.64),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const AnimatedTypingDots(),
                    ],
                  ),
                ),
                // Speech-bubble tail
                CustomPaint(
                  size: const Size(12, 12),
                  painter: BubbleTailLeftPainter(IrmaColors.brown20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        itemCount: _messages.length + (_isIrmaTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            return _buildTypingIndicator();
                          }
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
                padding: const EdgeInsets.only(
                  top: 12,
                  left: 12,
                  right: 12,
                  bottom: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Input Field Box (x=12, width 279, height 48)
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: 8,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: const Color(0xFF926247),
                        style: IrmaTextStyles.labelMdBold.copyWith(
                          color: IrmaColors.brown80,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type to start chatting...',
                          hintStyle: IrmaTextStyles.labelMdBold.copyWith(
                            color: IrmaColors.brown70,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F4F2),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          isDense: true,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 10.0),
                            child: SvgPicture.string(
                              '''<svg width="20" height="20" viewBox="8 14 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path fill-rule="evenodd" clip-rule="evenodd" d="M18.0001 17.3332C14.3182 17.3332 11.3334 20.3179 11.3334 23.9998C11.3334 27.6817 14.3182 30.6665 18.0001 30.6665C21.682 30.6665 24.6667 27.6817 24.6667 23.9998C24.6667 20.3179 21.682 17.3332 18.0001 17.3332ZM9.66675 23.9998C9.66675 19.3975 13.3977 15.6665 18.0001 15.6665C22.6025 15.6665 26.3334 19.3975 26.3334 23.9998C26.3334 28.6022 22.6025 32.3332 18.0001 32.3332C13.3977 32.3332 9.66675 28.6022 9.66675 23.9998Z" fill="#4B3425"/>
                              </svg>''',
                              width: 20,
                              height: 20,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 38,
                            minHeight: 48,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                            ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // Spacing between input and send button
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
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IrmaTopBar(
              title: 'Chat with Irma',
              onBackPressed: widget.onBackPressed,
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

class BubbleTailLeftPainter extends CustomPainter {
  final Color color;
  BubbleTailLeftPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..cubicTo(
        size.width, 0,
        size.width, size.height,
        0, size.height,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedTypingDots extends StatefulWidget {
  const AnimatedTypingDots({super.key});

  @override
  State<AnimatedTypingDots> createState() => _AnimatedTypingDotsState();
}

class _AnimatedTypingDotsState extends State<AnimatedTypingDots> {
  int _tick = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          _tick = (_tick + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        double opacity = 0.3;
        if (_tick == 0 && index == 0) opacity = 1.0;
        if (_tick == 1 && index == 1) opacity = 1.0;
        if (_tick == 2 && index == 2) opacity = 1.0;

        return AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: IrmaColors.brown60,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

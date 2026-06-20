import 'dart:async';
import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/services/advice_service.dart';
import 'package:irma/widgets/theme.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  bool _isOffline = false;
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    final box = StorageService.settingsBox;
    final List<dynamic>? stored = box.get('chat_transcripts') as List<dynamic>?;
    if (stored != null) {
      setState(() => _messages.addAll(stored.map((e) => Map<String, dynamic>.from(e as Map))));
    } else {
      setState(() => _messages.add({
        'sender': 'irma',
        'type': 'type-chatbot-text',
        'text': 'Good day. I am here to help you understand your cycle patterns. How are you feeling today?',
        'timestamp': DateTime.now().toIso8601String(),
      }));
      _saveMessages();
    }
    _scrollToBottom();
  }

  Future<void> _saveMessages() async =>
      StorageService.settingsBox.put('chat_transcripts', _messages);

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

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isOffline) return;

    _textController.clear();
    setState(() {
      _messages.add({'sender': 'user', 'type': 'type-user', 'text': text, 'timestamp': DateTime.now().toIso8601String()});
      _isThinking = true;
    });
    _saveMessages();
    _scrollToBottom();

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isThinking = false);

      final q = text.toLowerCase();
      String reply;
      String type = 'type-chatbot-text';
      Map<String, dynamic>? rec;

      if (q.contains('severe') || q.contains('emergency') || q.contains('heavy bleeding') || q.contains('intense pain')) {
        reply = 'I am concerned by the severity of what you are experiencing. In line with NHS clinical safety guidelines, if you are experiencing severe or sudden pain, or heavy bleeding requiring you to change pads hourly, please contact NHS 111 or your GP immediately. Do not delay seeking professional medical attention.';
      } else if (q.contains('recommend') || q.contains('therapist') || q.contains('doctor') || q.contains('specialist')) {
        reply = 'Based on what you have shared, consulting a practitioner could offer additional clarity. I have compiled a referral below.';
        type = 'type-chatbot-therapist-recommendation';
        rec = {
          'title': 'Dr. Elizabeth Finch',
          'specialty': 'Gynaecologist & Endocrine Specialist',
          'clinic': 'NHS Chelsea and Westminster Clinic',
          'phone': '+44 20 7352 8121',
        };
      } else if (q.contains('article') || q.contains('exercise') || q.contains('read') || q.contains('learn')) {
        reply = 'Here is an oestrogen-cycle management exercise from our verified NHS clinical reference library.';
        type = 'type-chatbot-resource-recommendation';
        rec = {
          'title': 'Managing Cyclic Pain via Light Mobilisation',
          'duration': '10 min read · Exercise',
          'author': 'NHS Clinical Board Guidelines',
        };
      } else if (q.contains('cramp') || q.contains('pain')) {
        reply = 'Menstrual cramps are caused by contractions of the uterine wall muscle. Applying a warm water bottle or doing light stretching can help. Oestrogen is currently low during this phase, which lowers your pain tolerance thresholds.';
      } else if (q.contains('fatigue') || q.contains('tired')) {
        reply = 'Feeling tired is a normal response to hormone transitions. Oestrogen changes your sleep-wake patterns. Prioritising a consistent bedtime routine helps stabilise energy levels through the cycle.';
      } else {
        reply = AdviceService.generateDailyAdvice();
      }

      setState(() => _messages.add({
        'sender': 'irma',
        'type': type,
        'text': reply,
        'recommendation': rec,
        'timestamp': DateTime.now().toIso8601String(),
      }));
      _saveMessages();
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double finalBottomPadding = keyboardHeight > 0
        ? keyboardHeight + IrmaSpacing.md
        : 80.0 + bottomPadding + IrmaSpacing.md;

    return Scaffold(
      backgroundColor: IrmaColors.brown10,

      // ── Chat Header (§10) ─────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: IrmaSpacing.md,
        title: Row(
          children: [
            // Back / menu button — 48×48 Gray 10 circle
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: IrmaColors.gray10,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chevron_left_rounded, color: IrmaColors.brown100, size: 24),
              ),
            ),
            const SizedBox(width: IrmaSpacing.sm),
            // Avatar dot
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: IrmaColors.green50,
                shape: BoxShape.circle,
                border: Border.all(color: IrmaColors.green20, width: 2),
              ),
              child: const Icon(Icons.spa_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: IrmaSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Irma', style: IrmaTextStyles.label2xl.copyWith(color: IrmaColors.brown100)),
                Text('Wise Companion', style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60)),
              ],
            ),
          ],
        ),
        actions: [
          // Search button — 48×48 with Brown 20 border
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: IrmaColors.brown20),
            ),
            child: IconButton(
              icon: Icon(Icons.search_rounded, color: IrmaColors.brown80, size: 20),
              onPressed: () {},
              padding: EdgeInsets.zero,
            ),
          ),
          // Offline toggle
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(right: IrmaSpacing.md),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: IrmaColors.brown20),
            ),
            child: IconButton(
              icon: Icon(
                _isOffline ? Icons.cloud_off_rounded : Icons.cloud_queue_rounded,
                color: _isOffline ? IrmaColors.orange40 : IrmaColors.green50,
                size: 20,
              ),
              onPressed: () => setState(() => _isOffline = !_isOffline),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Network Fault Banner (§10 emotion-status spec) ────
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.md, vertical: IrmaSpacing.xs),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.sm, vertical: 6),
                decoration: BoxDecoration(
                  color: IrmaColors.orange40,
                  borderRadius: BorderRadius.circular(1234),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: IrmaSpacing.xs),
                    Text(
                      'Network lost. Chat inputs frozen.',
                      style: IrmaTextStyles.labelMd.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // ── Chat Feed (§10 chat-main spec) ───────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(IrmaSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: IrmaColors.green50),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(IrmaSpacing.lg),
                  itemCount: _messages.length + (_isThinking ? 1 : 0),
                  separatorBuilder: (_, index) => const SizedBox(height: IrmaSpacing.lg),
                  itemBuilder: (_, i) {
                    if (i == _messages.length) return _ThinkingBubble();
                    final msg = _messages[i];
                    final isUser = msg['sender'] == 'user';
                    final type   = msg['type'] as String;

                    if (isUser) return _UserBubble(text: msg['text'] as String);
                    if (type == 'type-chatbot-therapist-recommendation') {
                      return _TherapistCard(intro: msg['text'] as String, data: msg['recommendation'] as Map?);
                    }
                    if (type == 'type-chatbot-resource-recommendation') {
                      return _ResourceCard(intro: msg['text'] as String, data: msg['recommendation'] as Map?);
                    }
                    return _IrmaBubble(text: msg['text'] as String);
                  },
                ),
              ),
            ),
          ),

          // ── Input Box (§10 chat-textbox-user-input spec) ─────
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: IrmaSpacing.sm,
              left: IrmaSpacing.sm,
              right: IrmaSpacing.sm,
              bottom: finalBottomPadding,
            ),
            child: Row(
              children: [
                // Text field — Gray 10 pill
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: IrmaColors.brown10,
                      borderRadius: BorderRadius.circular(1238),
                    ),
                    padding: const EdgeInsets.all(IrmaSpacing.xs),
                    child: TextField(
                      controller: _textController,
                      enabled: !_isOffline,
                      style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown70),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type to start chatting...',
                        hintStyle: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown50),
                        contentPadding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.md, vertical: IrmaSpacing.xs),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: IrmaSpacing.xs),
                // Send button — 48×48 green50 circle
                GestureDetector(
                  onTap: _isOffline ? null : _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isOffline ? IrmaColors.gray30 : IrmaColors.green50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message bubble widgets ─────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.md, vertical: IrmaSpacing.sm),
      decoration: const BoxDecoration(
        color: IrmaColors.brown80,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Text(text, style: IrmaTextStyles.paraMd.copyWith(color: Colors.white)),
    ),
  );
}

class _IrmaBubble extends StatelessWidget {
  final String text;
  const _IrmaBubble({required this.text});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar dot
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(color: IrmaColors.green50, shape: BoxShape.circle),
          child: const Icon(Icons.spa_rounded, color: Colors.white, size: 14),
        ),
        const SizedBox(width: IrmaSpacing.xs),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.md, vertical: IrmaSpacing.sm),
            decoration: BoxDecoration(
              color: IrmaColors.green10,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: IrmaColors.green30),
            ),
            child: Text(text, style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.brown100, height: 1.5)),
          ),
        ),
      ],
    ),
  );
}

class _ThinkingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.md, vertical: IrmaSpacing.sm),
      decoration: BoxDecoration(
        color: IrmaColors.green10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: IrmaColors.green30),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(IrmaColors.green50),
          ),
        ),
        const SizedBox(width: IrmaSpacing.xs),
        Text('Thinking…', style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.gray60)),
      ]),
    ),
  );
}

class _TherapistCard extends StatelessWidget {
  final String intro;
  final Map? data;
  const _TherapistCard({required this.intro, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IrmaBubble(text: intro),
        const SizedBox(height: IrmaSpacing.xs),
        Container(
          padding: const EdgeInsets.all(IrmaSpacing.md),
          decoration: IrmaCards.advice(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.local_hospital_rounded, color: IrmaColors.green50, size: 18),
                const SizedBox(width: IrmaSpacing.xs),
                Text(data!['title'] as String, style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100)),
              ]),
              const SizedBox(height: 4),
              Text(data!['specialty'] as String, style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.brown80)),
              Text(data!['clinic'] as String, style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60)),
              const SizedBox(height: IrmaSpacing.xs),
              Row(children: [
                Icon(Icons.phone_rounded, size: 13, color: IrmaColors.gray60),
                const SizedBox(width: 4),
                Text(data!['phone'] as String, style: IrmaTextStyles.labelSm.copyWith(color: IrmaColors.brown100)),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String intro;
  final Map? data;
  const _ResourceCard({required this.intro, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IrmaBubble(text: intro),
        const SizedBox(height: IrmaSpacing.xs),
        Container(
          padding: const EdgeInsets.all(IrmaSpacing.md),
          decoration: IrmaCards.large(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.bookmark_added_rounded, color: IrmaColors.brown80, size: 18),
                const SizedBox(width: IrmaSpacing.xs),
                Expanded(child: Text(data!['title'] as String, style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100))),
              ]),
              const SizedBox(height: IrmaSpacing.xs),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(data!['duration'] as String, style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60)),
                Text(data!['author'] as String, style: IrmaTextStyles.labelXs.copyWith(color: IrmaColors.green50)),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

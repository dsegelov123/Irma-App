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
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isOffline = false;
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    final box = StorageService.settingsBox;
    final List<dynamic>? stored = box.get('chat_transcripts') as List<dynamic>?;
    if (stored != null) {
      setState(() {
        _messages.addAll(stored.map((e) => Map<String, dynamic>.from(e as Map)));
      });
    } else {
      // Add welcome message from Irma
      setState(() {
        _messages.add({
          'sender': 'irma',
          'type': 'type-chatbot-text',
          'text': 'Good day. I am here to help you understand your cycle patterns. How are you feeling today?',
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      _saveMessages();
    }
    _scrollToBottom();
  }

  Future<void> _saveMessages() async {
    final box = StorageService.settingsBox;
    await box.put('chat_transcripts', _messages);
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

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isOffline) return;

    _textController.clear();
    setState(() {
      _messages.add({
        'sender': 'user',
        'type': 'type-user',
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _isThinking = true;
    });
    _saveMessages();
    _scrollToBottom();

    // Simulate network delay and chatbot response
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      setState(() {
        _isThinking = false;
      });

      final query = text.toLowerCase();
      String replyText = '';
      String replyType = 'type-chatbot-text';
      Map<String, dynamic>? recommendation;

      // Crisis Escalation check (Section 6.2)
      if (query.contains('severe') || query.contains('emergency') || query.contains('heavy bleeding') || query.contains('intense pain')) {
        replyText = AdviceService.generateDailyAdvice(
          targetDate: DateTime.now().subtract(const Duration(days: 0)), // Ensure trigger matches
        );
        // Force crisis trigger
        if (!replyText.contains('NHS 111')) {
          replyText = 'I am concerned by the severity of the symptoms you are experiencing. In line with NHS clinical safety guidelines, if you are experiencing severe, sudden pain, or heavy bleeding that requires changing pads hourly, please contact NHS 111 or your general practitioner immediately. Do not delay seeking professional medical attention.';
        }
      } else if (query.contains('recommend') || query.contains('therapist') || query.contains('doctor') || query.contains('help')) {
        replyText = 'Based on our discussions, consulting a practitioner might offer additional clarity. I have compiled a referral below for a verified specialist in gynaecological health.';
        replyType = 'type-chatbot-therapist-recommendation';
        recommendation = {
          'title': 'Dr. Elizabeth Finch',
          'specialty': 'Gynaecologist & Endocrine Specialist',
          'clinic': 'NHS Chelsea and Westminster Clinic',
          'phone': '+44 20 7352 8121',
        };
      } else if (query.contains('read') || query.contains('article') || query.contains('exercise') || query.contains('learn')) {
        replyText = 'Here is an oestrogen-cycle management exercise from our verified NHS clinical reference materials.';
        replyType = 'type-chatbot-resource-recommendation';
        recommendation = {
          'title': 'Managing Cyclic Pain via Light Mobilisation',
          'duration': '10 min read • Exercise',
          'author': 'NHS Clinical Board Guidelines',
        };
      } else if (query.contains('cramp') || query.contains('cramps') || query.contains('pain')) {
        replyText = 'Menstrual cramps are caused by contractions of the uterine wall muscle. Applying heat using a warm water bottle or light stretching o oestrogen support helps. Oestrogen is currently low, which changes your pain tolerance thresholds.';
      } else if (query.contains('fatigue') || query.contains('tired')) {
        replyText = 'Feeling tired is normal during active hormone transitions. Oestrogen changes sleep-wake patterns. Prioritise a regular bedtime routine to stabilise your energy levels.';
      } else {
        replyText = 'I understand. Tuning into these daily oestrogen fluctuations and tracking oestrogen patterns helps you oestrogen-synchronise. Let\'s continue monitoring how these shifts impact oestrogen-linked recovery and focus.';
      }

      setState(() {
        _messages.add({
          'sender': 'irma',
          'type': replyType,
          'text': replyText,
          'recommendation': recommendation,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      _saveMessages();
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IrmaTheme.lightWarmGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: IrmaTheme.earthyBrown),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Column(
          children: [
            Text(
              'Smart Chat',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            Text(
              'Irma (Wise Aunt)',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 11,
                color: IrmaTheme.gray60,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Simulated Offline Toggle
          IconButton(
            icon: Icon(
              _isOffline ? Icons.cloud_off_rounded : Icons.cloud_queue_rounded,
              color: _isOffline ? IrmaTheme.empathyOrange : IrmaTheme.sageGreen,
            ),
            onPressed: () {
              setState(() {
                _isOffline = !_isOffline;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isOffline ? 'Offline Mode Active' : 'Network Reconnected'),
                  backgroundColor: _isOffline ? IrmaTheme.empathyOrange : IrmaTheme.sageGreen,
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Connection Warning Banner (Section 11.3)
          if (_isOffline)
            Container(
              width: double.infinity,
              color: IrmaTheme.lightOrangeTint,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: IrmaTheme.empathyOrange),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Connection lost. Chat inputs frozen.',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: IrmaTheme.empathyOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  // Thinking bubble
                  return _buildThinkingBubble();
                }
                
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                final type = msg['type'] as String;

                if (isUser) {
                  return _buildUserBubble(msg['text'] as String);
                } else {
                  if (type == 'type-chatbot-therapist-recommendation') {
                    return _buildTherapistRecommendation(msg['text'] as String, msg['recommendation'] as Map?);
                  } else if (type == 'type-chatbot-resource-recommendation') {
                    return _buildResourceRecommendation(msg['text'] as String, msg['recommendation'] as Map?);
                  } else {
                    return _buildIrmaBubble(msg['text'] as String);
                  }
                }
              },
            ),
          ),
          
          // Input Box (Section 10.3)
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: 12,
              left: 12,
              right: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: IrmaTheme.lightWarmGray,
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _textController,
                      enabled: !_isOffline,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: IrmaTheme.darkEspresso,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type to start chatting...',
                        hintStyle: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: IrmaTheme.earthyBrown,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _isOffline ? null : _sendMessage,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isOffline ? IrmaTheme.gray30 : IrmaTheme.sageGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUserBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: IrmaTheme.earthyBrown,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildIrmaBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(24),
          ),
          border: Border(
            left: BorderSide(color: IrmaTheme.sageGreen, width: 4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: IrmaTheme.darkEspresso,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: IrmaTheme.cardDecoration(radius: 20),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(IrmaTheme.sageGreen),
          ),
        ),
      ),
    );
  }

  Widget _buildTherapistRecommendation(String intro, Map? therapist) {
    if (therapist == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIrmaBubble(intro),
        Container(
          margin: const EdgeInsets.only(bottom: 16, right: 48, left: 12),
          padding: const EdgeInsets.all(20),
          decoration: IrmaTheme.cardDecoration(
            color: IrmaTheme.lightSageTint,
            borderColor: IrmaTheme.sageGreen,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_hospital_rounded, color: IrmaTheme.sageGreen),
                  const SizedBox(width: 8),
                  Text(
                    therapist['title'] as String,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: IrmaTheme.darkEspresso,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                therapist['specialty'] as String,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: IrmaTheme.earthyBrown,
                ),
              ),
              Text(
                therapist['clinic'] as String,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12,
                  color: IrmaTheme.gray60,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.phone_rounded, size: 14, color: IrmaTheme.gray60),
                  const SizedBox(width: 6),
                  Text(
                    therapist['phone'] as String,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: IrmaTheme.darkEspresso,
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildResourceRecommendation(String intro, Map? resource) {
    if (resource == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIrmaBubble(intro),
        Container(
          margin: const EdgeInsets.only(bottom: 16, right: 48, left: 12),
          padding: const EdgeInsets.all(20),
          decoration: IrmaTheme.cardDecoration(
            borderColor: IrmaTheme.lightTan,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bookmark_added_rounded, color: IrmaTheme.earthyBrown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      resource['title'] as String,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: IrmaTheme.darkEspresso,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    resource['duration'] as String,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: IrmaTheme.gray60,
                    ),
                  ),
                  Text(
                    resource['author'] as String,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: IrmaTheme.sageGreen,
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

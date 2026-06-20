import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/widgets/theme.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    final box = StorageService.settingsBox;
    final List<dynamic>? stored = box.get('advice_logs') as List<dynamic>?;
    
    if (stored != null) {
      setState(() {
        _logs = stored.map((e) => Map<String, dynamic>.from(e as Map)).toList().reversed.toList();
      });
    } else {
      // Seed a default notice
      final defaultLog = {
        'timestamp': DateTime.now().toIso8601String(),
        'content': 'Welcome to Irma. Your oestrogen levels and menstrual cycle predictions are fully initialized in the E2EE local database.',
      };
      setState(() {
        _logs = [defaultLog];
      });
      box.put('advice_logs', [defaultLog]);
    }
  }

  Future<void> _clearLogs() async {
    final box = StorageService.settingsBox;
    await box.put('advice_logs', <dynamic>[]);
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IrmaColors.brown10,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
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
        title: Text(
          'Notifications & Logs',
          style: IrmaTextStyles.label2xl,
        ),
        centerTitle: true,
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: IrmaColors.brown80),
              onPressed: _clearLogs,
            )
        ],
      ),
      body: _logs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(IrmaSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_none_rounded, size: 48, color: IrmaColors.gray30),
                    const SizedBox(height: IrmaSpacing.md),
                    Text(
                      'No Notifications Yet',
                      style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown100),
                    ),
                    const SizedBox(height: IrmaSpacing.xs),
                    Text(
                      'Any daily notes and cycle phase warnings Irma dispatches will be displayed here.',
                      textAlign: TextAlign.center,
                      style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.gray60),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(IrmaSpacing.md),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final date = DateTime.parse(log['timestamp'] as String);
                final dateStr = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                final isClinical = log['content'].toString().contains('NHS');

                return Container(
                  margin: const EdgeInsets.only(bottom: IrmaSpacing.md),
                  padding: const EdgeInsets.all(IrmaSpacing.lg),
                  decoration: IrmaCards.large(fill: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isClinical
                                    ? Icons.health_and_safety_rounded
                                    : Icons.spa_rounded,
                                color: isClinical
                                    ? IrmaColors.orange50
                                    : IrmaColors.green50,
                                size: 18,
                              ),
                              const SizedBox(width: IrmaSpacing.xs),
                              Text(
                                isClinical ? 'CLINICAL ALERT' : 'DAILY REFLECTION',
                                style: IrmaTextStyles.labelXs.copyWith(
                                  color: isClinical ? IrmaColors.orange50 : IrmaColors.green50,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            dateStr,
                            style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60),
                          ),
                        ],
                      ),
                      const SizedBox(height: IrmaSpacing.sm),
                      Text(
                        log['content'] as String,
                        style: IrmaTextStyles.paraSm.copyWith(
                          color: IrmaColors.brown100,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

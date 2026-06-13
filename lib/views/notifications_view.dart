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
          'Notifications & Logs',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: IrmaTheme.darkEspresso,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: IrmaTheme.earthyBrown),
              onPressed: _clearLogs,
            )
        ],
      ),
      body: _logs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 48, color: IrmaTheme.gray30),
                    const SizedBox(height: 16),
                    const Text(
                      'No Notifications Yet',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: IrmaTheme.darkEspresso,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Any daily notes and cycle phase warnings Irma dispatches will be displayed here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: IrmaTheme.gray60,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final date = DateTime.parse(log['timestamp'] as String);
                final dateStr = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: IrmaTheme.cardDecoration(radius: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                log['content'].toString().contains('NHS')
                                    ? Icons.health_and_safety_rounded
                                    : Icons.spa_rounded,
                                color: log['content'].toString().contains('NHS')
                                    ? IrmaTheme.empathyOrange
                                    : IrmaTheme.sageGreen,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                log['content'].toString().contains('NHS')
                                    ? 'CLINICAL ALERT'
                                    : 'DAILY REFLECTION',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: log['content'].toString().contains('NHS')
                                      ? IrmaTheme.empathyOrange
                                      : IrmaTheme.sageGreen,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 11,
                              color: IrmaTheme.gray60,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        log['content'] as String,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: IrmaTheme.darkEspresso,
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

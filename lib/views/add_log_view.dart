import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/widgets/theme.dart';

class AddLogView extends StatefulWidget {
  final VoidCallback onLogSaved;
  const AddLogView({super.key, required this.onLogSaved});

  @override
  State<AddLogView> createState() => _AddLogViewState();
}

class _AddLogViewState extends State<AddLogView> {
  final _noteController = TextEditingController();
  final Set<String> _selectedSymptoms = {};
  bool _isPeriodStart = false;
  DateTime _selectedDate = DateTime.now();

  final List<String> _physicalSymptoms = [
    'Cramps',
    'Headache',
    'Fatigue',
    'Bloating',
    'Nausea'
  ];

  final List<String> _emotionalSymptoms = [
    'Stress',
    'Mood Swings',
    'Irritability',
    'Anxiety',
    'Restlessness'
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingLog();
  }

  String _getDateKey() {
    return 'log_${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
  }

  void _loadExistingLog() {
    final box = StorageService.settingsBox;
    final logData = box.get(_getDateKey());
    
    setState(() {
      _selectedSymptoms.clear();
      _noteController.clear();
      _isPeriodStart = false;
    });

    if (logData != null && logData is Map) {
      final List<dynamic>? symptoms = logData['symptoms'] as List<dynamic>?;
      if (symptoms != null) {
        setState(() {
          _selectedSymptoms.addAll(symptoms.map((e) => e.toString()));
        });
      }
      final String? note = logData['note'] as String?;
      if (note != null) {
        setState(() {
          _noteController.text = note;
        });
      }
      final bool? isStart = logData['is_period_start'] as bool?;
      if (isStart != null) {
        setState(() {
          _isPeriodStart = isStart;
        });
      }
    }
  }

  Future<void> _saveLog() async {
    final box = StorageService.settingsBox;
    final key = _getDateKey();

    final logData = {
      'date': _selectedDate.toIso8601String(),
      'symptoms': _selectedSymptoms.toList(),
      'note': _noteController.text,
      'is_period_start': _isPeriodStart,
    };

    await box.put(key, logData);

    // If Period Start is flagged, invoke early override anchors
    if (_isPeriodStart) {
      await CycleEngine.logPeriodStart(_selectedDate);
    } else {
      // Remove it from starts if it was checked off
      await CycleEngine.removePeriodStart(_selectedDate);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily log saved. Analytics updated.'),
          duration: Duration(seconds: 1),
        ),
      );
      widget.onLogSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IrmaColors.gray10,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: IrmaColors.brown80),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text('Daily Logging', style: IrmaTextStyles.label2xl.copyWith(color: IrmaColors.brown100)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker Banner
            Container(
              padding: const EdgeInsets.all(IrmaSpacing.md),
              decoration: IrmaCards.stat(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.calendar_today_rounded, color: IrmaColors.brown80, size: 20),
                    const SizedBox(width: IrmaSpacing.sm),
                    Text(
                      'Logging for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown100),
                    ),
                  ]),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 90)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                        _loadExistingLog();
                      }
                    },
                    child: Text('Change', style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown80)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Period Start Toggle
            Container(
              padding: const EdgeInsets.all(IrmaSpacing.md),
              decoration: IrmaCards.large(
                fill: _isPeriodStart ? IrmaColors.orange10 : Colors.white,
                border: _isPeriodStart ? IrmaColors.orange40 : IrmaColors.gray20,
              ),
              child: SwitchListTile(
                title: Text('Menstruation Onset (Period Start)', style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100)),
                subtitle: Text(
                  'Activates the Early Override reset. Forces current day to Day 1.',
                  style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60),
                ),
                activeThumbColor: IrmaColors.orange40,
                value: _isPeriodStart,
                onChanged: (val) => setState(() => _isPeriodStart = val),
              ),
            ),
            const SizedBox(height: 24),

            // Physical Symptoms Category
            Text('Physical States', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
            const SizedBox(height: 12),
            Wrap(
              spacing: IrmaSpacing.xs,
              runSpacing: IrmaSpacing.xs,
              children: _physicalSymptoms.map((s) {
                final sel = _selectedSymptoms.contains(s);
                return _SymptomPill(label: s, selected: sel, activeColor: IrmaColors.orange40, activeTint: IrmaColors.orange10,
                  onTap: () => setState(() => sel ? _selectedSymptoms.remove(s) : _selectedSymptoms.add(s)));
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Emotional Symptoms Category
            Text('Emotional / Mental States', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
            const SizedBox(height: 12),
            Wrap(
              spacing: IrmaSpacing.xs,
              runSpacing: IrmaSpacing.xs,
              children: _emotionalSymptoms.map((s) {
                final sel = _selectedSymptoms.contains(s);
                return _SymptomPill(label: s, selected: sel, activeColor: IrmaColors.purple40, activeTint: IrmaColors.purple10,
                  onTap: () => setState(() => sel ? _selectedSymptoms.remove(s) : _selectedSymptoms.add(s)));
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Notes Text Box
            Text('Daily Note', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
            const SizedBox(height: IrmaSpacing.sm),
            TextField(
              controller: _noteController,
              maxLines: 4,
              style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.brown100),
              decoration: IrmaInputDecoration.standard(hintText: 'Type any physical observation or reflection...'),
            ),
            const SizedBox(height: 32),

            // Save Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLog,
                style: IrmaButtonStyles.primaryLg(),
                child: const Text('Save Daily Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Symptom selection pill (§7 tag spec) ───────────────────────────

class _SymptomPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color activeColor;
  final Color activeTint;
  final VoidCallback onTap;

  const _SymptomPill({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.activeTint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.sm, vertical: IrmaSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? activeTint : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? activeColor : IrmaColors.gray30),
        ),
        child: Text(
          label,
          style: IrmaTextStyles.labelSm.copyWith(
            color: selected ? activeColor : IrmaColors.brown100,
          ),
        ),
      ),
    );
  }
}

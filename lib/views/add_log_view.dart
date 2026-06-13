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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daily log saved. Analytics updated.'),
        duration: Duration(seconds: 1),
      ),
    );

    widget.onLogSaved();
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
          'Daily Logging',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: IrmaTheme.darkEspresso,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: IrmaTheme.cardDecoration(radius: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: IrmaTheme.earthyBrown),
                      const SizedBox(width: 12),
                      Text(
                        'Logging for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: IrmaTheme.darkEspresso,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 90)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                        _loadExistingLog();
                      }
                    },
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        color: IrmaTheme.earthyBrown,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Period Start Toggle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: IrmaTheme.cardDecoration(
                color: _isPeriodStart ? IrmaTheme.lightOrangeTint : Colors.white,
                borderColor: _isPeriodStart ? IrmaTheme.empathyOrange : IrmaTheme.gray20,
              ),
              child: SwitchListTile(
                title: const Text(
                  'Menstruation Onset (Period Start)',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    color: IrmaTheme.darkEspresso,
                  ),
                ),
                subtitle: const Text(
                  'Activates the Early Override reset. Forces current day to Day 1 and shifts cycle calendar anchors.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                  ),
                ),
                activeColor: IrmaTheme.empathyOrange,
                value: _isPeriodStart,
                onChanged: (val) {
                  setState(() {
                    _isPeriodStart = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Physical Symptoms Category
            const Text(
              'Physical States',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _physicalSymptoms.map((symptom) {
                final selected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: selected,
                  selectedColor: IrmaTheme.lightOrangeTint,
                  checkmarkColor: IrmaTheme.empathyOrange,
                  labelStyle: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: selected ? IrmaTheme.empathyOrange : IrmaTheme.darkEspresso,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(
                      color: selected ? IrmaTheme.empathyOrange : IrmaTheme.gray30,
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Emotional Symptoms Category
            const Text(
              'Emotional / Mental States',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emotionalSymptoms.map((symptom) {
                final selected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: selected,
                  selectedColor: IrmaTheme.lightPurpleTint,
                  checkmarkColor: IrmaTheme.gentlePurple,
                  labelStyle: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: selected ? IrmaTheme.gentlePurple : IrmaTheme.darkEspresso,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(
                      color: selected ? IrmaTheme.gentlePurple : IrmaTheme.gray30,
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Notes Text Box
            const Text(
              'Daily Note',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type any physical observation or reflection...',
                hintStyle: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: IrmaTheme.gray60,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: IrmaTheme.gray20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: IrmaTheme.sageGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: IrmaTheme.earthyBrown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Save Daily Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

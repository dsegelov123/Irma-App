import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/widgets/theme.dart';
import 'package:irma/widgets/irma_top_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddLogView extends StatefulWidget {
  final VoidCallback onLogSaved;
  final VoidCallback onBackPressed;
  const AddLogView({super.key, required this.onLogSaved, required this.onBackPressed});

  @override
  State<AddLogView> createState() => _AddLogViewState();
}

class _AddLogViewState extends State<AddLogView> {
  static const bool _useLargeCircle = true;
  DateTime _selectedDate = DateTime.now();
  bool _isPeriodStart = false;

  // Selected Option States
  final Set<String> _selectedMoods = {};
  String _selectedFlow = '';
  String _selectedCramps = '';
  final Set<String> _selectedSomaticPains = {};
  String _selectedEnergy = '';
  final Set<String> _selectedGI = {};
  String _selectedSleep = '';
  String _selectedFocus = '';
  String _selectedExercise = '';
  String _selectedLibido = '';
  final Set<String> _selectedSexActivity = {};
  String _selectedSocial = '';
  final Set<String> _selectedAppetite = {};
  String _selectedAlcohol = '';
  double? _weightValue;
  double? _weightPoundsValue;
  String _weightUnit = 'kg';
  late final TextEditingController _noteController;
  late final TextEditingController _weightController;

  // Category Options Lists
  final List<String> _moods = ['Happy', 'Calm', 'Irritable', 'Anxious', 'Sad', 'Depressed', 'Mood Swings', 'Angry', 'Overwhelmed', 'Unmotivated'];
  final List<String> _flows = ['None', 'Spotting', 'Light', 'Typical', 'Heavy', 'Very Heavy'];
  final List<String> _cramps = ['None', 'Light', 'Typical', 'Heavy'];
  final List<String> _somaticPains = ['None', 'Breast Tenderness', 'Back Pain', 'Headache/Migraine', 'Joint/Muscle Pain'];
  final List<String> _energies = ['Low', 'Typical', 'High'];
  final List<String> _gi = ['None', 'Bloating', 'Nausea', 'Gas', 'Constipation', 'Diarrhoea'];
  final List<String> _sleeps = ['Poor', 'Typical', 'Good'];
  final List<String> _focuses = ['Low', 'Typical', 'High'];
  final List<String> _exercises = ['None', 'Light', 'Typical', 'Heavy'];
  final List<String> _libidos = ['Low', 'Typical', 'High'];
  final List<String> _sexActivity = ['None', 'Had Sex', 'Masturbated', 'Orgasm', 'Pain During Sex', 'Vaginal Dryness', 'Increased Sensitivity'];
  final List<String> _socials = ['Withdrawn', 'Typical', 'Outgoing'];
  final List<String> _appetites = ['Low', 'Typical', 'High', 'Craving Salt', 'Craving Sugar', 'Craving Savoury'];
  final List<String> _alcohols = ['None', 'Light', 'Typical', 'Heavy'];

  // Icon Maps
  static final Map<String, IconData> _symptomIcons = {
    // Mood
    'Mood: Happy': PhosphorIcons.smiley(),
    'Mood: Calm': PhosphorIcons.smileyMeh(),
    'Mood: Irritable': PhosphorIcons.smileyAngry(),
    'Mood: Anxious': PhosphorIcons.smileyNervous(),
    'Mood: Sad': PhosphorIcons.smileySad(),
    'Mood: Depressed': PhosphorIcons.smileySad(),
    'Mood: Mood Swings': PhosphorIcons.maskHappy(),
    'Mood: Angry': PhosphorIcons.smileyXEyes(),
    'Mood: Overwhelmed': PhosphorIcons.brain(),
    'Mood: Unmotivated': PhosphorIcons.smileyBlank(),

    // Menstrual Flow
    'Menstrual Flow: None': PhosphorIcons.dropSlash(),
    'Menstrual Flow: Spotting': PhosphorIcons.drop(),
    'Menstrual Flow: Light': PhosphorIcons.dropHalf(),
    'Menstrual Flow: Typical': PhosphorIcons.drop(),
    'Menstrual Flow: Heavy': PhosphorIcons.waves(),
    'Menstrual Flow: Very Heavy': PhosphorIcons.waves(),

    // Abdominal Cramps
    'Abdominal Cramps: None': PhosphorIcons.prohibit(),
    'Abdominal Cramps: Light': PhosphorIcons.sparkle(),
    'Abdominal Cramps: Typical': PhosphorIcons.sparkle(),
    'Abdominal Cramps: Heavy': PhosphorIcons.lightning(),

    // Somatic Pain
    'Somatic Pain: None': PhosphorIcons.check(),
    'Somatic Pain: Breast Tenderness': PhosphorIcons.circlesFour(),
    'Somatic Pain: Back Pain': PhosphorIcons.bone(),
    'Somatic Pain: Headache/Migraine': PhosphorIcons.headset(),
    'Somatic Pain: Joint/Muscle Pain': PhosphorIcons.pulse(),

    // Physical Energy
    'Physical Energy: Low': PhosphorIcons.batteryEmpty(),
    'Physical Energy: Typical': PhosphorIcons.batteryMedium(),
    'Physical Energy: High': PhosphorIcons.batteryFull(),

    // Gastrointestinal Activity
    'Gastrointestinal Activity: None': PhosphorIcons.checkCircle(),
    'Gastrointestinal Activity: Bloating': PhosphorIcons.wind(),
    'Gastrointestinal Activity: Nausea': PhosphorIcons.faceMask(),
    'Gastrointestinal Activity: Gas': PhosphorIcons.cloud(),
    'Gastrointestinal Activity: Constipation': PhosphorIcons.lock(),
    'Gastrointestinal Activity: Diarrhoea': PhosphorIcons.arrowsOutLineHorizontal(),

    // Sleep Quality
    'Sleep Quality: Poor': PhosphorIcons.moonStars(),
    'Sleep Quality: Typical': PhosphorIcons.moon(),
    'Sleep Quality: Good': PhosphorIcons.bed(),

    // Mental Focus
    'Mental Focus: Low': PhosphorIcons.eyeClosed(),
    'Mental Focus: Typical': PhosphorIcons.eye(),
    'Mental Focus: High': PhosphorIcons.target(),

    // Exercise
    'Exercise: None': PhosphorIcons.x(),
    'Exercise: Light': PhosphorIcons.footprints(),
    'Exercise: Typical': PhosphorIcons.bicycle(),
    'Exercise: Heavy': PhosphorIcons.barbell(),

    // Libido
    'Libido: Low': PhosphorIcons.heartBreak(),
    'Libido: Typical': PhosphorIcons.heart(),
    'Libido: High': PhosphorIcons.flame(),

    // Sexual Activity
    'Sexual Activity: None': PhosphorIcons.heartStraightBreak(),
    'Sexual Activity: Had Sex': PhosphorIcons.users(),
    'Sexual Activity: Masturbated': PhosphorIcons.hand(),
    'Sexual Activity: Orgasm': PhosphorIcons.crown(),
    'Sexual Activity: Pain During Sex': PhosphorIcons.warning(),
    'Sexual Activity: Vaginal Dryness': PhosphorIcons.sun(),
    'Sexual Activity: Increased Sensitivity': PhosphorIcons.waves(),

    // Social Bandwidth
    'Social Bandwidth: Withdrawn': PhosphorIcons.userMinus(),
    'Social Bandwidth: Typical': PhosphorIcons.user(),
    'Social Bandwidth: Outgoing': PhosphorIcons.usersThree(),

    // Appetite
    'Appetite: Low': PhosphorIcons.forkKnife(),
    'Appetite: Typical': PhosphorIcons.cookingPot(),
    'Appetite: High': PhosphorIcons.cookie(),
    'Appetite: Craving Salt': PhosphorIcons.popcorn(),
    'Appetite: Craving Sugar': PhosphorIcons.cake(),
    'Appetite: Craving Savoury': PhosphorIcons.hamburger(),

    // Alcohol
    'Alcohol: None': PhosphorIcons.wine(),
    'Alcohol: Light': PhosphorIcons.beerBottle(),
    'Alcohol: Typical': PhosphorIcons.beerStein(),
    'Alcohol: Heavy': PhosphorIcons.brandy(),
  };

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _weightController = TextEditingController();
    _loadExistingLog();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String _getDateKey() {
    return 'log_${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
  }

  void _loadExistingLog() {
    final box = StorageService.settingsBox;
    final logData = box.get(_getDateKey());

    setState(() {
      _selectedMoods.clear();
      _selectedFlow = '';
      _selectedCramps = '';
      _selectedSomaticPains.clear();
      _selectedEnergy = '';
      _selectedGI.clear();
      _selectedSleep = '';
      _selectedFocus = '';
      _selectedExercise = '';
      _selectedLibido = '';
      _selectedSexActivity.clear();
      _selectedSocial = '';
      _selectedAppetite.clear();
      _selectedAlcohol = '';
      _isPeriodStart = false;
      _weightValue = null;
      _weightPoundsValue = null;
      _weightUnit = 'kg';
      _noteController.clear();
    });

    if (logData != null && logData is Map) {
      final List<dynamic>? symptoms = logData['symptoms'] as List<dynamic>?;
      if (symptoms != null) {
        for (var item in symptoms) {
          final s = item.toString();
          if (s.startsWith('Mood: ')) {
            _selectedMoods.add(s.substring(6));
          } else if (s.startsWith('Menstrual Flow: ')) {
            _selectedFlow = s.substring(16);
          } else if (s.startsWith('Abdominal Cramps: ')) {
            _selectedCramps = s.substring(18);
          } else if (s.startsWith('Somatic Pain: ')) {
            _selectedSomaticPains.remove('None');
            _selectedSomaticPains.add(s.substring(14));
          } else if (s.startsWith('Physical Energy: ')) {
            _selectedEnergy = s.substring(17);
          } else if (s.startsWith('Gastrointestinal Activity: ')) {
            _selectedGI.remove('None');
            _selectedGI.add(s.substring(27));
          } else if (s.startsWith('Sleep Quality: ')) {
            _selectedSleep = s.substring(15);
          } else if (s.startsWith('Mental Focus: ')) {
            _selectedFocus = s.substring(14);
          } else if (s.startsWith('Exercise: ')) {
            _selectedExercise = s.substring(10);
          } else if (s.startsWith('Libido: ')) {
            _selectedLibido = s.substring(8);
          } else if (s.startsWith('Sexual Activity: ')) {
            _selectedSexActivity.remove('None');
            _selectedSexActivity.add(s.substring(17));
          } else if (s.startsWith('Social Bandwidth: ')) {
            _selectedSocial = s.substring(18);
          } else if (s.startsWith('Appetite: ')) {
            _selectedAppetite.remove('Typical');
            _selectedAppetite.add(s.substring(10));
          } else if (s.startsWith('Alcohol: ')) {
            _selectedAlcohol = s.substring(9);
          } else {
            // Backward compatibility
            if (_moods.contains(s)) _selectedMoods.add(s);
            if (_somaticPains.contains(s)) {
              _selectedSomaticPains.remove('None');
              _selectedSomaticPains.add(s);
            }
            if (_gi.contains(s)) {
              _selectedGI.remove('None');
              _selectedGI.add(s);
            }
          }
        }
      }
      final bool? isStart = logData['is_period_start'] as bool?;
      if (isStart != null) {
        _isPeriodStart = isStart;
      }
      _weightValue = logData['weight_value'] as double?;
      _weightPoundsValue = logData['weight_pounds'] as double?;
      _weightUnit = logData['weight_unit'] as String? ?? 'kg';
      _weightController.text = _weightValue != null ? _getWeightDisplay() : '';
      final String? note = logData['note'] as String?;
      _noteController.text = note ?? '';
    }
  }

  Future<void> _saveLog() async {
    final box = StorageService.settingsBox;
    final key = _getDateKey();

    final List<String> symptomsList = [];
    for (var m in _selectedMoods) {
      symptomsList.add('Mood: $m');
    }
    symptomsList.add('Menstrual Flow: $_selectedFlow');
    symptomsList.add('Abdominal Cramps: $_selectedCramps');
    for (var p in _selectedSomaticPains) {
      symptomsList.add('Somatic Pain: $p');
    }
    symptomsList.add('Physical Energy: $_selectedEnergy');
    for (var g in _selectedGI) {
      symptomsList.add('Gastrointestinal Activity: $g');
    }
    symptomsList.add('Sleep Quality: $_selectedSleep');
    symptomsList.add('Mental Focus: $_selectedFocus');
    symptomsList.add('Exercise: $_selectedExercise');
    symptomsList.add('Libido: $_selectedLibido');
    for (var s in _selectedSexActivity) {
      symptomsList.add('Sexual Activity: $s');
    }
    symptomsList.add('Social Bandwidth: $_selectedSocial');
    for (var a in _selectedAppetite) {
      symptomsList.add('Appetite: $a');
    }
    symptomsList.add('Alcohol: $_selectedAlcohol');

    final logData = {
      'date': _selectedDate.toIso8601String(),
      'symptoms': symptomsList,
      'note': _noteController.text,
      'weight_value': _weightValue,
      'weight_pounds': _weightPoundsValue,
      'weight_unit': _weightUnit,
      'is_period_start': _isPeriodStart,
    };

    await box.put(key, logData);

    if (_isPeriodStart) {
      await CycleEngine.logPeriodStart(_selectedDate);
    } else {
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

  Future<void> _clearLog() async {
    final box = StorageService.settingsBox;
    final key = _getDateKey();

    await box.delete(key);
    await CycleEngine.removePeriodStart(_selectedDate);

    setState(() {
      _selectedMoods.clear();
      _selectedFlow = '';
      _selectedCramps = '';
      _selectedSomaticPains.clear();
      _selectedEnergy = '';
      _selectedGI.clear();
      _selectedSleep = '';
      _selectedFocus = '';
      _selectedExercise = '';
      _selectedLibido = '';
      _selectedSexActivity.clear();
      _selectedSocial = '';
      _selectedAppetite.clear();
      _selectedAlcohol = '';
      _isPeriodStart = false;
      _weightValue = null;
      _weightPoundsValue = null;
      _weightUnit = 'kg';
      _weightController.clear();
      _noteController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log cleared for this day.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _setFlow(String option) {
    setState(() {
      if (_selectedFlow == option) {
        _selectedFlow = '';
        _isPeriodStart = false;
      } else {
        _selectedFlow = option;
        if (option == 'None' || option == 'Spotting') {
          _isPeriodStart = false;
        }
      }
    });
  }

  void _toggleMultiSelect(Set<String> set, String option) {
    setState(() {
      if (option == 'None') {
        if (set.contains('None')) {
          set.remove('None');
        } else {
          set.clear();
          set.add('None');
        }
      } else {
        set.remove('None');
        if (set.contains(option)) {
          set.remove(option);
        } else {
          set.add(option);
        }
      }
    });
  }

  void _toggleAppetite(String option) {
    setState(() {
      if (option == 'Low' || option == 'Typical' || option == 'High') {
        final isAlreadySelected = _selectedAppetite.contains(option);
        _selectedAppetite.remove('Low');
        _selectedAppetite.remove('Typical');
        _selectedAppetite.remove('High');
        if (!isAlreadySelected) {
          _selectedAppetite.add(option);
        }
      } else {
        if (_selectedAppetite.contains(option)) {
          _selectedAppetite.remove(option);
        } else {
          _selectedAppetite.add(option);
        }
      }
    });
  }

  IconData _getIconForOption(String opt, String category) {
    final key = '$category: $opt';
    if (_symptomIcons.containsKey(key)) {
      return _symptomIcons[key]!;
    }
    return PhosphorIcons.check();
  }

  String _getWeightDisplay() {
    if (_weightValue == null) return 'Record weight';
    if (_weightUnit == 'kg') {
      return '${_weightValue!.toStringAsFixed(1)} kg';
    } else if (_weightUnit == 'lbs') {
      return '${_weightValue!.toStringAsFixed(1)} lbs';
    } else if (_weightUnit == 'st;lb') {
      final st = _weightValue!.toInt();
      final lb = _weightPoundsValue?.toInt() ?? 0;
      return '$st st $lb lb';
    }
    return 'Record weight';
  }

  void _showWeightBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        String localUnit = _weightUnit;
        final TextEditingController valueController = TextEditingController(
          text: (_weightValue != null && _weightValue != 0) ? _weightValue!.toString() : '',
        );
        final TextEditingController poundsController = TextEditingController(
          text: (_weightPoundsValue != null && _weightPoundsValue != 0) ? _weightPoundsValue!.toString() : '',
        );

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
              ),
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: IrmaColors.brown20,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Record Weight',
                    style: IrmaTextStyles.headingXsBold.copyWith(color: IrmaColors.brown100),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: ['kg', 'st;lb', 'lbs'].map((unit) {
                      final isSelected = localUnit == unit;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              localUnit = unit;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? IrmaColors.orange50 : Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              unit == 'st;lb' ? 'st & lb' : unit,
                              style: IrmaTextStyles.labelMd.copyWith(
                                color: isSelected ? Colors.white : IrmaColors.brown80,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  if (localUnit == 'st;lb')
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stone (st)', style: IrmaTextStyles.labelSm.copyWith(color: IrmaColors.brown60)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: valueController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: IrmaColors.brown10,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: '0',
                                  hintStyle: const TextStyle(color: IrmaColors.brown40),
                                ),
                                style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.brown100),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pounds (lb)', style: IrmaTextStyles.labelSm.copyWith(color: IrmaColors.brown60)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: poundsController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: IrmaColors.brown10,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: '0',
                                  hintStyle: const TextStyle(color: IrmaColors.brown40),
                                ),
                                style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.brown100),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localUnit == 'kg' ? 'Weight (kg)' : 'Weight (lbs)',
                          style: IrmaTextStyles.labelSm.copyWith(color: IrmaColors.brown60),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: valueController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: IrmaColors.brown10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            hintText: '0.0',
                            hintStyle: const TextStyle(color: IrmaColors.brown40),
                          ),
                          style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.brown100),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_weightValue != null) ...[
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _weightValue = null;
                              _weightPoundsValue = null;
                              _weightUnit = 'kg';
                              _weightController.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Clear',
                            style: IrmaTextStyles.labelMd.copyWith(color: Colors.redAccent),
                          ),
                        ),
                        const Spacer(),
                      ],
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown60),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          final double? val = double.tryParse(valueController.text);
                          final double? lbsVal = double.tryParse(poundsController.text);
                          if (val != null) {
                            setState(() {
                              _weightValue = val;
                              _weightPoundsValue = (localUnit == 'st;lb') ? (lbsVal ?? 0) : null;
                              _weightUnit = localUnit;
                              _weightController.text = _getWeightDisplay();
                            });
                          }
                          Navigator.pop(context);
                        },
                        style: IrmaButtonStyles.primaryLg(),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategorySection(String title, List<String> options, Set<String> selection, Function(String) onToggle, {bool blockFormat = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: IrmaSpacing.md,
          children: options.map((opt) {
            final isSel = selection.contains(opt);
            return _SymptomButton(
              label: opt,
              selected: isSel,
              icon: _getIconForOption(opt, title),
              onTap: () => onToggle(opt),
              blockFormat: blockFormat,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSingleSelectSection(String title, List<String> options, String currentSelection, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: IrmaSpacing.md,
          children: options.map((opt) {
            final isSel = currentSelection == opt;
            return _SymptomButton(
              label: opt,
              selected: isSel,
              icon: _getIconForOption(opt, title),
              onTap: () => onSelect(opt),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFlowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Menstrual Flow', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: IrmaSpacing.md,
          children: _flows.map((opt) {
            final isSel = _selectedFlow == opt;
            return _SymptomButton(
              label: opt,
              selected: isSel,
              icon: _getIconForOption(opt, 'Menstrual Flow'),
              onTap: () => _setFlow(opt),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHorizontalCalendar() {
    final now = DateTime.now();
    final List<String> weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final offset = index - 3;
        final date = now.add(Duration(days: offset));
        final isSelected = date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;
        final isToday = date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
        final weekdayStr = weekdays[date.weekday - 1];

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                  _loadExistingLog();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? IrmaColors.orange50 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isToday ? IrmaColors.orange50.withValues(alpha: 0.5) : Colors.transparent),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weekdayStr,
                      style: IrmaTextStyles.labelSm.copyWith(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : IrmaColors.brown60,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: IrmaTextStyles.labelXl.copyWith(
                        color: isSelected ? Colors.white : IrmaColors.brown100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IrmaColors.brown10,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 80.0),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    top: IrmaSpacing.xxl,
                    bottom: IrmaSpacing.xl + 80.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHorizontalCalendar(),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Mood
                      _buildCategorySection('Mood', _moods, _selectedMoods, (opt) {
                        setState(() {
                          if (_selectedMoods.contains(opt)) {
                            _selectedMoods.remove(opt);
                          } else {
                            _selectedMoods.add(opt);
                          }
                        });
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Menstrual Flow
                      _buildFlowSection(),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Abdominal Cramps
                      _buildSingleSelectSection('Abdominal Cramps', _cramps, _selectedCramps, (opt) {
                        setState(() => _selectedCramps = (_selectedCramps == opt) ? '' : opt);
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Somatic Pain
                      _buildCategorySection('Somatic Pain', _somaticPains, _selectedSomaticPains, (opt) {
                        _toggleMultiSelect(_selectedSomaticPains, opt);
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Physical Energy
                      _buildSingleSelectSection('Physical Energy', _energies, _selectedEnergy, (opt) {
                        setState(() => _selectedEnergy = (_selectedEnergy == opt) ? '' : opt);
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Gastrointestinal Activity
                      _buildCategorySection('Gastrointestinal Activity', _gi, _selectedGI, (opt) {
                        _toggleMultiSelect(_selectedGI, opt);
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Sleep Quality
                      _buildSingleSelectSection('Sleep Quality', _sleeps, _selectedSleep, (opt) {
                        setState(() => _selectedSleep = (_selectedSleep == opt) ? '' : opt);
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Mental Focus
                      _buildSingleSelectSection('Mental Focus', _focuses, _selectedFocus, (opt) {
                        setState(() => _selectedFocus = (_selectedFocus == opt) ? '' : opt);
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Exercise
                      _buildSingleSelectSection('Exercise', _exercises, _selectedExercise, (opt) {
                        setState(() => _selectedExercise = (_selectedExercise == opt) ? '' : opt);
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Libido
                      _buildSingleSelectSection('Libido', _libidos, _selectedLibido, (opt) {
                        setState(() => _selectedLibido = (_selectedLibido == opt) ? '' : opt);
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Sexual Activity
                      _buildCategorySection('Sexual Activity', _sexActivity, _selectedSexActivity, (opt) {
                        _toggleMultiSelect(_selectedSexActivity, opt);
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Social Bandwidth
                      _buildSingleSelectSection('Social Bandwidth', _socials, _selectedSocial, (opt) {
                        setState(() => _selectedSocial = (_selectedSocial == opt) ? '' : opt);
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Appetite
                      _buildCategorySection('Appetite', _appetites, _selectedAppetite, _toggleAppetite),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Alcohol
                      _buildSingleSelectSection('Alcohol', _alcohols, _selectedAlcohol, (opt) {
                        setState(() => _selectedAlcohol = (_selectedAlcohol == opt) ? '' : opt);
                      }),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Weight
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Weight', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _weightController,
                            readOnly: true,
                            onTap: _showWeightBottomSheet,
                            decoration: InputDecoration(
                              hintText: 'Record weight',
                              hintStyle: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.brown40),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                                child: PhosphorIcon(
                                  PhosphorIcons.scales(),
                                  color: IrmaColors.orange50,
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.brown100),
                          ),
                        ],
                      ),
                      const SizedBox(height: IrmaSpacing.xl),
                      const Divider(color: IrmaColors.brown30, height: 1),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Notes
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notes', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _noteController,
                            maxLines: 5,
                            minLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add details about your day...',
                              hintStyle: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.brown40),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: IrmaColors.orange50, width: 1.5),
                              ),
                            ),
                            style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.brown100),
                          ),
                        ],
                      ),
                      const SizedBox(height: IrmaSpacing.xl),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _clearLog,
                              style: IrmaButtonStyles.outlinedLg(),
                              child: const Text('Clear log'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveLog,
                              style: IrmaButtonStyles.primaryLg(),
                              child: const Text('Save log'),
                            ),
                          ),
                        ],
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
              title: 'Daily log entry',
              onBackPressed: widget.onBackPressed,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom selectable symptom button ─────────────────────────────────

class _SymptomButton extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;
  final bool blockFormat;

  const _SymptomButton({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
    this.blockFormat = false,
  });

  @override
  Widget build(BuildContext context) {
    if (blockFormat) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 84,
          height: 84,
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: selected ? IrmaColors.orange50 : Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : IrmaColors.orange50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: PhosphorIcon(
                    icon,
                    size: 14,
                    color: selected ? IrmaColors.orange50 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 6.0),
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: IrmaTextStyles.labelSm.copyWith(
                      color: selected ? Colors.white : IrmaColors.brown80,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final double circleSize = _AddLogViewState._useLargeCircle ? 28.0 : 24.0;
    final EdgeInsetsGeometry buttonPadding = _AddLogViewState._useLargeCircle
        ? const EdgeInsets.only(left: 2.0, right: 12.0, top: 2.0, bottom: 2.0)
        : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: buttonPadding,
        decoration: BoxDecoration(
          color: selected ? IrmaColors.orange50 : Colors.white,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: selected ? Colors.white : IrmaColors.orange50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: PhosphorIcon(
                  icon,
                  size: _AddLogViewState._useLargeCircle ? 16 : 14,
                  color: selected ? IrmaColors.orange50 : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Padding(
              padding: _AddLogViewState._useLargeCircle ? const EdgeInsets.only(right: 4.0) : EdgeInsets.zero,
              child: Text(
                label,
                style: IrmaTextStyles.labelMd.copyWith(
                  color: selected ? Colors.white : IrmaColors.brown80,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

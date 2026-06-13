import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';
import 'package:irma/widgets/theme.dart';

/// Step-by-step onboarding wizard capturing physiological baselines.
class OnboardingWizardView extends StatefulWidget {
  final Function(String route) onNavigation;
  const OnboardingWizardView({super.key, required this.onNavigation});

  @override
  State<OnboardingWizardView> createState() => _OnboardingWizardViewState();
}

class _OnboardingWizardViewState extends State<OnboardingWizardView> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1 values
  bool _isCycleRegular = true;

  // Step 2 values
  double _avgCycleLength = 28.0;
  double _avgPeriodDuration = 5.0;

  // Step 3 values
  DateTime _lastPeriodStartDate = DateTime.now().subtract(const Duration(days: 14));

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finalizeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finalizeOnboarding() async {
    // Save configurations to storage
    final box = StorageService.settingsBox;
    await box.put('cycle_regularity_is_regular', _isCycleRegular);
    await box.put('average_cycle_length', _avgCycleLength.toInt());
    await box.put('average_period_duration', _avgPeriodDuration.toInt());
    await box.put('last_period_start_date', _lastPeriodStartDate.toIso8601String());
    await box.put('onboarding_completed', true);

    widget.onNavigation('mainShell');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: IrmaColors.brown80),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          'Step ${_currentStep + 1} of 3',
          style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown80),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress dot indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.lg, vertical: IrmaSpacing.sm),
              child: Row(
                children: List.generate(3, (index) {
                  final active = index == _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: active ? IrmaColors.green50 : IrmaColors.brown20,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
            // Bottom Action buttons
            Padding(
              padding: const EdgeInsets.all(IrmaSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: IrmaButtonStyles.primaryLg(),
                  child: Text(_currentStep == 2 ? 'Finalize Setup' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(IrmaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle Regularity',
            style: IrmaTextStyles.label2xl.copyWith(fontSize: 28, color: IrmaColors.brown100),
          ),
          const SizedBox(height: IrmaSpacing.xs),
          Text(
            'Does your biological cycle typically arrive at consistent intervals?',
            style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.gray60),
          ),
          const SizedBox(height: IrmaSpacing.xxl),
          // Option Cards
          _buildChoiceCard(
            title: 'Regular Cycle',
            subtitle: 'Arrives predictably every 21–35 days with minimal variance.',
            selected: _isCycleRegular,
            onTap: () => setState(() => _isCycleRegular = true),
          ),
          const SizedBox(height: IrmaSpacing.lg),
          _buildChoiceCard(
            title: 'Irregular Cycle',
            subtitle: 'Fluctuates dynamically, varying significantly from month to month.',
            selected: !_isCycleRegular,
            onTap: () => setState(() => _isCycleRegular = false),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(IrmaSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? IrmaColors.green10 : Colors.white, // Green 10 selection
          borderRadius: BorderRadius.circular(32), // Standard Card Radius
          border: Border.all(
            color: selected ? IrmaColors.green50 : IrmaColors.gray20, // Sage Green vs Light Gray
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown100),
                  ),
                  const SizedBox(height: IrmaSpacing.xs),
                  Text(
                    subtitle,
                    style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.gray60),
                  ),
                ],
              ),
            ),
            const SizedBox(width: IrmaSpacing.md),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? IrmaColors.brown80 : IrmaColors.gray30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(IrmaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle Length & Duration',
            style: IrmaTextStyles.label2xl.copyWith(fontSize: 28, color: IrmaColors.brown100),
          ),
          const SizedBox(height: IrmaSpacing.xs),
          Text(
            'Establishes the initial baseline day-count interval and bleeding window.',
            style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.gray60),
          ),
          const SizedBox(height: IrmaSpacing.xxl),
          // Average Cycle Length Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Average Cycle Length',
                style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown100),
              ),
              Text(
                '${_avgCycleLength.toInt()} days',
                style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown80),
              ),
            ],
          ),
          Slider(
            value: _avgCycleLength,
            min: 15.0,
            max: 45.0,
            activeColor: IrmaColors.brown80,
            inactiveColor: IrmaColors.brown20,
            onChanged: (val) => setState(() => _avgCycleLength = val),
          ),
          const SizedBox(height: IrmaSpacing.xl),
          // Average Period Duration Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expected Period Duration',
                style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown100),
              ),
              Text(
                '${_avgPeriodDuration.toInt()} days',
                style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown80),
              ),
            ],
          ),
          Slider(
            value: _avgPeriodDuration,
            min: 1.0,
            max: 10.0,
            activeColor: IrmaColors.brown80,
            inactiveColor: IrmaColors.brown20,
            onChanged: (val) => setState(() => _avgPeriodDuration = val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(IrmaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last Period Start Date',
            style: IrmaTextStyles.label2xl.copyWith(fontSize: 28, color: IrmaColors.brown100),
          ),
          const SizedBox(height: IrmaSpacing.xs),
          Text(
            'Anchors the absolute timeline matrix, allowing Irma to compute active cycle phases.',
            style: IrmaTextStyles.paraMd.copyWith(color: IrmaColors.gray60),
          ),
          const SizedBox(height: IrmaSpacing.xxl),
          // Selected Date Card
          Container(
            padding: const EdgeInsets.all(IrmaSpacing.lg),
            decoration: BoxDecoration(
              color: IrmaColors.brown10,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: IrmaColors.brown20, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menstruation Onset Date',
                      style: IrmaTextStyles.labelSm.copyWith(color: IrmaColors.gray60),
                    ),
                    const SizedBox(height: IrmaSpacing.xs),
                    Text(
                      '${_lastPeriodStartDate.day}/${_lastPeriodStartDate.month}/${_lastPeriodStartDate.year}',
                      style: IrmaTextStyles.label2xl.copyWith(color: IrmaColors.brown100),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _lastPeriodStartDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _lastPeriodStartDate = picked);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: IrmaColors.brown80,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    side: const BorderSide(color: IrmaColors.brown20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    textStyle: IrmaTextStyles.labelMd,
                  ),
                  child: const Text('Change Date'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

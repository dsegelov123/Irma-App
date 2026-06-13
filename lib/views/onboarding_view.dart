import 'package:flutter/material.dart';
import 'package:irma/services/storage_service.dart';

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
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4B3425)),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          'Step ${_currentStep + 1} of 3',
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4B3425),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress dot indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                children: List.generate(3, (index) {
                  final active = index == _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF9BB068) : const Color(0xFFE8DDD9),
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
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF4B3425), // Warm Earthy Brown
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000), // Pill Shape
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cycle Regularity',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F160F),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Does your biological cycle typically arrive at consistent intervals?',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              color: Color(0xFF697077),
            ),
          ),
          const SizedBox(height: 48),
          // Option Cards
          _buildChoiceCard(
            title: 'Regular Cycle',
            subtitle: 'Arrives predictably every 21–35 days with minimal variance.',
            selected: _isCycleRegular,
            onTap: () => setState(() => _isCycleRegular = true),
          ),
          const SizedBox(height: 24),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2F5EB) : Colors.white, // Green 10 selection
          borderRadius: BorderRadius.circular(32), // Standard Card Radius
          border: Border.all(
            color: selected ? const Color(0xFF9BB068) : const Color(0xFFDDE1E6), // Sage Green vs Light Gray
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
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F160F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      color: Color(0xFF697077),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? const Color(0xFF4B3425) : const Color(0xFFC1C6CD),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cycle Length & Duration',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F160F),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Establishes the initial baseline day-count interval and bleeding window.',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              color: Color(0xFF697077),
            ),
          ),
          const SizedBox(height: 48),
          // Average Cycle Length Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Average Cycle Length',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F160F),
                ),
              ),
              Text(
                '${_avgCycleLength.toInt()} days',
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B3425),
                ),
              ),
            ],
          ),
          Slider(
            value: _avgCycleLength,
            min: 15.0,
            max: 45.0,
            activeColor: const Color(0xFF4B3425),
            inactiveColor: const Color(0xFFE8DDD9),
            onChanged: (val) => setState(() => _avgCycleLength = val),
          ),
          const SizedBox(height: 40),
          // Average Period Duration Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Expected Period Duration',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F160F),
                ),
              ),
              Text(
                '${_avgPeriodDuration.toInt()} days',
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B3425),
                ),
              ),
            ],
          ),
          Slider(
            value: _avgPeriodDuration,
            min: 1.0,
            max: 10.0,
            activeColor: const Color(0xFF4B3425),
            inactiveColor: const Color(0xFFE8DDD9),
            onChanged: (val) => setState(() => _avgPeriodDuration = val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Period Start Date',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F160F),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anchors the absolute timeline matrix, allowing Irma to compute active cycle phases.',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              color: Color(0xFF697077),
            ),
          ),
          const SizedBox(height: 48),
          // Selected Date Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4F2), // Brown 10
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFE8DDD9), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menstruation Onset Date',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Color(0xFF697077),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_lastPeriodStartDate.day}/${_lastPeriodStartDate.month}/${_lastPeriodStartDate.year}',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F160F),
                      ),
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
                    foregroundColor: const Color(0xFF4B3425),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000),
                    ),
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

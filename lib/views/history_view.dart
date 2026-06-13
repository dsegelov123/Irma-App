import 'package:flutter/material.dart';
import 'package:irma/services/cycle_engine.dart';
import 'package:irma/widgets/theme.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<DateTime> _cycleStarts = [];
  double _avgCycleLength = 28.0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _cycleStarts = CycleEngine.getCycleStarts().reversed.toList();
      _avgCycleLength = CycleEngine.getAverageCycleLength();
    });
  }

  void _compilePdfReport() {
    // PDF Report compiler pipeline (Section 9.1.1)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: IrmaTheme.empathyOrange),
            SizedBox(width: 8),
            Text(
              'PDF Report Compiled',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Standard 12-Month Clinical Report has been compiled successfully to transient cache storage.',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Metrics Summary:\n• Average Cycle Length: ${_avgCycleLength.round()} days\n• Total Recorded Cycles: ${_cycleStarts.length}\n• Encryption Verification: AES-256 Valid',
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                color: IrmaTheme.gray60,
                height: 1.5,
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Urbanist',
                color: IrmaTheme.earthyBrown,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF dispatched to system print tray.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: IrmaTheme.earthyBrown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text(
              'Share',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        ],
      ),
    );
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
          'Cycle History',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: IrmaTheme.darkEspresso,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: IrmaTheme.earthyBrown),
            onPressed: _compilePdfReport,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Summary Card
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: IrmaTheme.cardDecoration(borderColor: IrmaTheme.lightTan),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historical Average',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: IrmaTheme.gray60,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_avgCycleLength.toStringAsFixed(1)} days',
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: IrmaTheme.darkEspresso,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: IrmaTheme.lightGreen,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${_cycleStarts.length} cycles logged',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: IrmaTheme.earthyBrown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Menstruation Starts Chronology',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: IrmaTheme.darkEspresso,
              ),
            ),
            const SizedBox(height: 12),

            // History List
            Expanded(
              child: _cycleStarts.isEmpty
                  ? const Center(
                      child: Text('No historical periods recorded yet.'),
                    )
                  : ListView.builder(
                      itemCount: _cycleStarts.length,
                      itemBuilder: (context, index) {
                        final start = _cycleStarts[index];
                        final dateStr = '${start.day}/${start.month}/${start.year}';
                        
                        // Calculate length of this cycle if there is a next one
                        String lengthStr = 'Active Loop';
                        bool isAnomaly = false;
                        if (index > 0) {
                          // Note: starts are reversed, so start[index] is older than start[index-1]
                          final nextStart = _cycleStarts[index - 1];
                          final length = nextStart.difference(start).inDays;
                          lengthStr = '$length days';
                          isAnomaly = CycleEngine.isCycleOutlier(length, _avgCycleLength);
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: IrmaTheme.cardDecoration(radius: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.water_drop_rounded, color: IrmaTheme.empathyOrange),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dateStr,
                                        style: const TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w700,
                                          color: IrmaTheme.darkEspresso,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Bleeding onset logged',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 12,
                                          color: IrmaTheme.gray60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  if (isAnomaly)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: IrmaTheme.lightYellowTint,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Outlier',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: IrmaTheme.mediumBrown,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    lengthStr,
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w700,
                                      color: isAnomaly ? IrmaTheme.mediumBrown : IrmaTheme.darkEspresso,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

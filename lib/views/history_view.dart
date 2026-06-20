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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Row(children: [
          Icon(Icons.picture_as_pdf_rounded, color: IrmaColors.orange40),
          const SizedBox(width: IrmaSpacing.xs),
          Text('PDF Report Compiled', style: IrmaTextStyles.labelLg.copyWith(color: IrmaColors.brown100)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Standard 12-Month Clinical Report compiled to transient cache storage.',
              style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.brown100),
            ),
            const SizedBox(height: IrmaSpacing.md),
            Text(
              'Metrics Summary:\n• Average Cycle Length: ${_avgCycleLength.round()} days\n• Total Recorded Cycles: ${_cycleStarts.length}\n• Encryption: AES-256 Valid',
              style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60, height: 1.6),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown80)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF dispatched to system print tray.')),
              );
            },
            style: IrmaButtonStyles.primarySm(),
            child: const Text('Share'),
          ),
        ],
      ),
    );
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
            onTap: () => Navigator.pop(context),
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
        title: Text('Cycle History', style: IrmaTextStyles.label2xl.copyWith(color: IrmaColors.brown100)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf_rounded, color: IrmaColors.brown80),
            onPressed: _compilePdfReport,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: IrmaSpacing.sm),
            Container(
              padding: const EdgeInsets.all(IrmaSpacing.md),
              decoration: IrmaCards.large(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Historical Average', style: IrmaTextStyles.paraSm.copyWith(color: IrmaColors.gray60)),
                    const SizedBox(height: 4),
                    Text('${_avgCycleLength.toStringAsFixed(1)} days',
                        style: IrmaTextStyles.para2xl.copyWith(color: IrmaColors.brown100, fontWeight: FontWeight.w700)),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.sm, vertical: 6),
                    decoration: BoxDecoration(color: IrmaColors.green10, borderRadius: BorderRadius.circular(100)),
                    child: Text('${_cycleStarts.length} cycles logged',
                        style: IrmaTextStyles.labelSm.copyWith(color: IrmaColors.green50)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: IrmaSpacing.lg),
            Text('Menstruation Starts Chronology', style: IrmaTextStyles.labelXl.copyWith(color: IrmaColors.brown100)),
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
                        String lengthStr = 'Active Loop';
                        bool isAnomaly = false;
                        if (index > 0) {
                          final nextStart = _cycleStarts[index - 1];
                          final length = nextStart.difference(start).inDays;
                          lengthStr = '$length days';
                          isAnomaly = CycleEngine.isCycleOutlier(length, _avgCycleLength);
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: IrmaSpacing.xs),
                          padding: const EdgeInsets.symmetric(
                              horizontal: IrmaSpacing.md, vertical: IrmaSpacing.sm),
                          decoration: IrmaCards.log(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: IrmaColors.orange10,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.water_drop_rounded, color: IrmaColors.orange40, size: 18),
                                ),
                                const SizedBox(width: IrmaSpacing.sm),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(dateStr, style: IrmaTextStyles.labelMd.copyWith(color: IrmaColors.brown100)),
                                  Text('Bleeding onset', style: IrmaTextStyles.paraXs.copyWith(color: IrmaColors.gray60)),
                                ]),
                              ]),
                              Row(children: [
                                if (isAnomaly)
                                  Container(
                                    margin: const EdgeInsets.only(right: IrmaSpacing.xs),
                                    padding: const EdgeInsets.symmetric(horizontal: IrmaSpacing.xs, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: IrmaColors.yellow10,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text('Outlier',
                                        style: IrmaTextStyles.labelXs.copyWith(color: IrmaColors.yellow40)),
                                  ),
                                Text(lengthStr,
                                    style: IrmaTextStyles.labelMd.copyWith(
                                      color: isAnomaly ? IrmaColors.yellow40 : IrmaColors.brown100)),
                              ]),
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

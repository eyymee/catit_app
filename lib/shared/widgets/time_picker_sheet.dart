import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class TimePickerSheet extends StatefulWidget {
  final TimeOfDay initialTime;
  const TimePickerSheet({super.key, required this.initialTime});

  @override
  State<TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<TimePickerSheet> {
  late int _hour;
  late int _minute;
  late bool _isAm;
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;
  static const double _itemExtent = 52.0;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTime;
    _isAm = t.period == DayPeriod.am;
    _hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    _minute = t.minute;
    _hourCtrl = FixedExtentScrollController(initialItem: _hour - 1);
    _minCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  TimeOfDay get _result {
    final h = _isAm ? (_hour == 12 ? 0 : _hour) : (_hour == 12 ? 12 : _hour + 12);
    return TimeOfDay(hour: h, minute: _minute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Select time', style: AppTextStyles.headlineMd()),
          const SizedBox(height: 24),
          SizedBox(
            height: _itemExtent * 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: _itemExtent,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withAlpha(120),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _DrumPicker(
                        controller: _hourCtrl,
                        itemCount: 12,
                        itemExtent: _itemExtent,
                        selectedIndex: _hour - 1,
                        label: (i) => '${i + 1}',
                        onChanged: (i) => setState(() => _hour = i + 1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        ':',
                        style: AppTextStyles.headlineMd()
                            .copyWith(fontSize: 28, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(
                      child: _DrumPicker(
                        controller: _minCtrl,
                        itemCount: 60,
                        itemExtent: _itemExtent,
                        selectedIndex: _minute,
                        label: (i) => i.toString().padLeft(2, '0'),
                        onChanged: (i) => setState(() => _minute = i),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AmPmChip(
                label: 'AM',
                selected: _isAm,
                onTap: () => setState(() => _isAm = true),
              ),
              const SizedBox(width: 12),
              _AmPmChip(
                label: 'PM',
                selected: !_isAm,
                onTap: () => setState(() => _isAm = false),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                  child: Text('Cancel',
                      style:
                          AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, _result),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Confirm',
                      style: AppTextStyles.labelMd(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrumPicker extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final double itemExtent;
  final int selectedIndex;
  final String Function(int) label;
  final ValueChanged<int> onChanged;

  const _DrumPicker({
    required this.controller,
    required this.itemCount,
    required this.itemExtent,
    required this.selectedIndex,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: itemExtent,
      perspective: 0.004,
      diameterRatio: 2.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (_, i) {
          final sel = i == selectedIndex;
          return Center(
            child: Text(
              label(i),
              style: sel
                  ? AppTextStyles.headlineMd(color: AppColors.primary)
                  : AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          );
        },
      ),
    );
  }
}

class _AmPmChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AmPmChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryFixed : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd(
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

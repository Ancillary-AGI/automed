import 'package:flutter/material.dart';

import 'package:automed_app/core/theme/app_colors.dart';
import 'package:automed_app/core/theme/app_text_styles.dart';
import 'package:automed_app/core/models/medication_models.dart';

class PillReminderWidget extends StatefulWidget {
  final List<MedicationReminder> reminders;
  final void Function(MedicationReminder)? onToggleEnabled;

  const PillReminderWidget(
      {super.key, required this.reminders, this.onToggleEnabled});

  @override
  State<PillReminderWidget> createState() => _PillReminderWidgetState();
}

class _PillReminderWidgetState extends State<PillReminderWidget> {
  late List<MedicationReminder> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.reminders);
  }

  void _toggleEnabled(int index) {
    setState(() {
      final item = _items[index];
      _items[index] = MedicationReminder(
        id: item.id,
        medicationId: item.medicationId,
        patientId: item.patientId,
        reminderTimes: item.reminderTimes,
        isEnabled: !item.isEnabled,
        type: item.type,
        settings: item.settings,
      );
    });
    widget.onToggleEnabled?.call(_items[index]);
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('No reminders',
              style:
                  AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
        ),
      );
    }

    return Column(
      children: _items.asMap().entries.map((e) {
        final i = e.key;
        final r = e.value;
        final times = r.reminderTimes.map((t) => t.displayTime).join(', ');
        return ListTile(
          leading: Icon(r.isEnabled ? Icons.alarm_on : Icons.alarm_off,
              color: r.isEnabled ? AppColors.appSuccess : AppColors.textSecondary),
          title: Text(r.medicationId, style: AppTextStyles.bodyText1),
          subtitle: Text(times,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          trailing: ElevatedButton(
            onPressed: () => _toggleEnabled(i),
            child: Text(r.isEnabled ? 'Disable' : 'Enable'),
          ),
        );
      }).toList(),
    );
  }
}

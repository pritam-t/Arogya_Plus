import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Provider/Medication/MedicationProvider.dart';
import '../../data/local/medication_db_helper.dart';
import '../../main.dart';

class User_Logs_Screen extends StatefulWidget {
  final Map<String, dynamic>? medication; // For edit mode

  const User_Logs_Screen({Key? key, this.medication}) : super(key: key);

  @override
  State<User_Logs_Screen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<User_Logs_Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  bool _isMorning = false;
  bool _isNight = false;
  TimeOfDay? _morningTime;
  TimeOfDay? _nightTime;
  String _repeatType = 'everyday';
  List<String> _selectedDays = [];
  int _reminderMinutes = 15;

  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _loadMedicationData();
    }
  }

  void _loadMedicationData() {
    final med = widget.medication!;
    _nameController.text = med[MedicationDBHelper.COL_NAME] ?? '';
    _dosageController.text = med[MedicationDBHelper.COL_DOSAGE] ?? '';
    _isMorning = med[MedicationDBHelper.COL_IS_MORNING] == 1;
    _isNight = med[MedicationDBHelper.COL_IS_NIGHT] == 1;

    if (med[MedicationDBHelper.COL_MORNING_TIME] != null) {
      final parts = med[MedicationDBHelper.COL_MORNING_TIME].split(':');
      _morningTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    if (med[MedicationDBHelper.COL_NIGHT_TIME] != null) {
      final parts = med[MedicationDBHelper.COL_NIGHT_TIME].split(':');
      _nightTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    _repeatType = med[MedicationDBHelper.COL_REPEAT_TYPE] ?? 'everyday';
    if (med[MedicationDBHelper.COL_DAYS] != null) {
      _selectedDays = med[MedicationDBHelper.COL_DAYS].split(',');
    }
    _reminderMinutes = med[MedicationDBHelper.COL_REMINDER_MINUTES] ?? 15;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isMorning) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isMorning
          ? (_morningTime ?? TimeOfDay(hour: 8, minute: 0))
          : (_nightTime ?? TimeOfDay(hour: 21, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.surfaceColor,
              hourMinuteTextColor: AppTheme.primaryColor,
              dialHandColor: AppTheme.primaryColor,
              dialBackgroundColor: AppTheme.primaryLight.withOpacity(0.1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isMorning) {
          _morningTime = picked;
        } else {
          _nightTime = picked;
        }
      });
    }
  }

  void _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    final medData = {
      MedicationDBHelper.COL_NAME: _nameController.text.trim(),
      MedicationDBHelper.COL_DOSAGE: _dosageController.text.trim(),
      MedicationDBHelper.COL_IS_MORNING: _isMorning ? 1 : 0,
      MedicationDBHelper.COL_MORNING_TIME: _morningTime != null
          ? '${_morningTime!.hour.toString().padLeft(2, '0')}:${_morningTime!.minute.toString().padLeft(2, '0')}'
          : null,
      MedicationDBHelper.COL_IS_NIGHT: _isNight ? 1 : 0,
      MedicationDBHelper.COL_NIGHT_TIME: _nightTime != null
          ? '${_nightTime!.hour.toString().padLeft(2, '0')}:${_nightTime!.minute.toString().padLeft(2, '0')}'
          : null,
      MedicationDBHelper.COL_REPEAT_TYPE: _repeatType,
      MedicationDBHelper.COL_DAYS: _repeatType == 'custom' ? _selectedDays.join(',') : null,
      MedicationDBHelper.COL_REMINDER_MINUTES: _reminderMinutes,
    };

    final provider = context.read<MedicationProvider>();
    String action = '';

    try {
      if (widget.medication == null) {
        // Add new medication
        await provider.addMedication(medData);
        action = 'added';
      } else {
        // Update existing medication
        await provider.updateMedication(widget.medication![MedicationDBHelper.COL_ID], medData);
        action = 'updated';
      }

      // After updating the DB, reload medications in provider
      await provider.loadMedications(); // ensures UI rebuilds automatically

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Medication '${_nameController.text}' $action successfully"),
          backgroundColor: action == 'added' ? Colors.green : Colors.blue,
        ),
      );

      } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving medication: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spacingM),
          children: [
            // Basic Information Card
            _buildCard(
              title: 'Basic Information',
              icon: Icons.medication_rounded,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name',
                      hintText: 'e.g., Aspirin',
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter medication name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage',
                      hintText: 'e.g., 500mg',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter dosage';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Time Schedule Card
            _buildCard(
              title: 'Time Schedule',
              icon: Icons.access_time_rounded,
              child: Column(
                children: [
                  // Morning Time
                  _buildTimeSelector(
                    label: 'Morning',
                    icon: Icons.wb_sunny_outlined,
                    isSelected: _isMorning,
                    selectedTime: _morningTime,
                    onToggle: (value) {
                      setState(() => _isMorning = value ?? false);
                    },
                    onTimeTap: () => _selectTime(context, true),
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  // Night Time
                  _buildTimeSelector(
                    label: 'Night',
                    icon: Icons.nightlight_round,
                    isSelected: _isNight,
                    selectedTime: _nightTime,
                    onToggle: (value) {
                      setState(() => _isNight = value ?? false);
                    },
                    onTimeTap: () => _selectTime(context, false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Repeat Schedule Card
            _buildCard(
              title: 'Repeat Schedule',
              icon: Icons.repeat_rounded,
              child: Column(
                children: [
                  // Everyday/Custom Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildRepeatTypeButton('Everyday', 'everyday'),
                        ),
                        Expanded(
                          child: _buildRepeatTypeButton('Custom', 'custom'),
                        ),
                      ],
                    ),
                  ),

                  // Custom Days Selection
                  if (_repeatType == 'custom') ...[
                    const SizedBox(height: AppTheme.spacingM),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _weekDays.map((day) {
                        final isSelected = _selectedDays.contains(day.toLowerCase());
                        return FilterChip(
                          label: Text(day.substring(0, 3)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedDays.add(day.toLowerCase());
                              } else {
                                _selectedDays.remove(day.toLowerCase());
                              }
                            });
                          },
                          backgroundColor: AppTheme.surfaceColor,
                          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Reminder Settings Card
            _buildCard(
              title: 'Reminder Settings',
              icon: Icons.notifications_active_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remind me before',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [5, 10, 15, 30, 60].map((minutes) {
                      final isSelected = _reminderMinutes == minutes;
                      return ChoiceChip(
                        label: Text('$minutes min'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _reminderMinutes = minutes);
                        },
                        backgroundColor: AppTheme.surfaceColor,
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMedication,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                  ),
                ),
                child: Text(
                  widget.medication == null ? 'Add Medication' : 'Update Medication',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required IconData icon,
    required bool isSelected,
    required TimeOfDay? selectedTime,
    required Function(bool?) onToggle,
    required VoidCallback onTimeTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withOpacity(0.05)
            : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: onToggle,
              ),
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                size: screenWidth * 0.05,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (isSelected) ...[
            SizedBox(height: screenWidth * 0.02),
            InkWell(
              onTap: onTimeTap,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.03,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: screenWidth * 0.045,
                      color: Colors.white,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      selectedTime != null
                          ? selectedTime.format(context)
                          : 'Set Time',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRepeatTypeButton(String label, String value) {
    final isSelected = _repeatType == value;
    return InkWell(
      onTap: () => setState(() => _repeatType = value),
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/Dashboard/DashboardProvider.dart';
import '../../data/local/db_helper.dart';
import '../../main.dart';
import '../back_screens/navigation.dart';
import 'package:intl/intl.dart';

class UserDashBoard extends StatelessWidget {
  const UserDashBoard({super.key});

  void _addMedication(BuildContext context, DashboardProvider provider,
      TextEditingController nameController,
      TextEditingController dosageController,
      TextEditingController conditionController,
      TimeOfDay selectedTime) async
  {

    final String dosage = dosageController.text.isNotEmpty && conditionController.text.isNotEmpty
        ? 'Dosage: ${dosageController.text}, Condition: ${conditionController.text}'
        : dosageController.text.isNotEmpty ? 'Dosage: ${dosageController.text}' : conditionController.text.isNotEmpty
        ? 'Condition: ${conditionController.text}' : '';

    final now = DateTime.now();
    final medicationTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Check for duplicates
    if (provider.medications.any((m) => m[DBHelper.COL_MED_NAME] == nameController.text.trim())) {
      return;
    }

    await provider.addMedication(
      name: nameController.text,
      dosage: dosage,
      time: medicationTime.millisecondsSinceEpoch,
    );

    _clearDialogFields(nameController, dosageController, conditionController);
  }

  void _showAddMedicationDialog(BuildContext context) {
    // Create controllers locally for the dialog
    final medicationNameController = TextEditingController();
    final dosageController = TextEditingController();
    final conditionController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.medication, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Add Medication'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: medicationNameController,
                      decoration: InputDecoration(
                        labelText: 'Medication Name',
                        prefixIcon: Icon(Icons.medical_services, color: AppTheme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dosageController,
                      decoration: InputDecoration(
                        labelText: 'Dosage (e.g., 500mg)',
                        prefixIcon: Icon(Icons.colorize, color: AppTheme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: conditionController,
                      decoration: InputDecoration(
                        labelText: 'For Condition (e.g., Fever)',
                        prefixIcon: Icon(Icons.healing, color: AppTheme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.access_time, color: AppTheme.primaryColor),
                        title: const Text('Reminder Time'),
                        subtitle: Text(selectedTime.format(context)),
                        trailing: Icon(Icons.keyboard_arrow_right, color: AppTheme.textHint),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearDialogFields(medicationNameController, dosageController, conditionController);
                  },
                  child: Text('Cancel', style: TextStyle(color: AppTheme.textHint)),
                ),
                Consumer<DashboardProvider>(
                  builder: (context, provider, child) => ElevatedButton(
                    onPressed: () {
                      if (medicationNameController.text.isNotEmpty) {
                        _addMedication(context, provider, medicationNameController,
                            dosageController, conditionController, selectedTime);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add Reminder'),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Dispose controllers when dialog is closed
      medicationNameController.dispose();
      dosageController.dispose();
      conditionController.dispose();
    });
  }

  void _confirmDeleteMedication(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: const Text('Are you sure you want to delete this medication?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer<DashboardProvider>(
            builder: (context, provider, child) => TextButton(
              onPressed: () {
                provider.deleteMedication(index);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  void _clearDialogFields(TextEditingController nameController,
      TextEditingController dosageController,
      TextEditingController conditionController) {
    nameController.clear();
    dosageController.clear();
    conditionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                _buildUserProfile(provider.userinfo),
                const SizedBox(height: AppTheme.spacingL),

                // Health Overview Cards
                _buildHealthOverview(),
                const SizedBox(height: AppTheme.spacingL),

                // Today's Medications - Compact Design
                _buildCompactMedicationsSection(context, provider),
                const SizedBox(height: AppTheme.spacingL),

                _buildAppointmentsSection(context, provider),
                const SizedBox(height: AppTheme.spacingL),

                // Nearby Doctors Quick Access
                _buildNearbyDoctorsSection(context),
                const SizedBox(height: AppTheme.spacingL),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserProfile(Map<String, dynamic>? userinfo) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          padding: EdgeInsets.all(screenWidth * 0.045),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top row with avatar and user info
              Row(
                children: [
                  // Avatar
                  Container(
                    width: screenWidth * 0.16,
                    height: screenWidth * 0.16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.08),
                    ),
                    child: _buildProfileImage(screenWidth),
                  ),

                  SizedBox(width: screenWidth * 0.04),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userinfo == null ? 'Loading...' : userinfo[DBHelper.COL_NAME],
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: screenHeight * 0.008),

                        // Age and Gender
                        Row(
                          children: [
                            _buildInfoChip(
                              icon: Icons.cake_outlined,
                              text: '${userinfo?[DBHelper.COL_AGE] ?? ''} years',
                              screenWidth: screenWidth,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            _buildInfoChip(
                              icon: userinfo?[DBHelper.COL_GENDER] == 'Male'
                                  ? Icons.male : Icons.female,
                              text: '${userinfo?[DBHelper.COL_GENDER] ?? ''}',
                              screenWidth: screenWidth,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              // Divider
              Container(
                height: 1,
                width: double.infinity,
                color: AppTheme.borderColor.withOpacity(0.5),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Quick Stats / Other Info
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Stats',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.012),

              Align(
                alignment: Alignment.centerLeft,
                child: Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    final chips = <Widget>[];

                    // Medications taken count
                    final medsTaken = provider.medications
                        .where((m) => m[DBHelper.COL_MED_IS_TAKEN] == 1)
                        .length;
                    chips.add(_buildSimpleConditionChip(
                        "Meds Taken: $medsTaken", screenWidth));

                    // Upcoming appointment
                    if (provider.appointments.isNotEmpty) {
                      final nextAppointment = provider.appointments.first;
                      chips.add(_buildSimpleConditionChip(
                          "Next Appointment: ${nextAppointment[DBHelper.COL_APPOINT_DOCTOR]}",
                          screenWidth));
                    }

                    // Primary Emergency Contact
                    final primaryContact = provider.userinfo != null
                        ? provider.userinfo![DBHelper.COL_EMERGENCY_NAME]
                        : null;
                    if (primaryContact != null) {
                      chips.add(_buildSimpleConditionChip(
                          "Emergency Contact: $primaryContact", screenWidth));
                    }

                    if (chips.isEmpty) {
                      chips.add(_buildSimpleConditionChip("No quick stats", screenWidth));
                    }

                    return Wrap(
                      spacing: screenWidth * 0.025,
                      runSpacing: screenHeight * 0.01,
                      children: chips,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(double screenWidth) {
    return FutureBuilder<File?>(
      future: _loadProfileImageFromDB(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ClipOval(
            child: Image.file(
              snapshot.data!,
              width: screenWidth * 0.14,
              height: screenWidth * 0.14,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: screenWidth * 0.07,
                );
              },
            ),
          );
        } else {
          return Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: screenWidth * 0.07,
          );
        }
      },
    );
  }

  Future<File?> _loadProfileImageFromDB() async {
    try {
      final users = await DBHelper.getInstance.getUsers();
      if (users.isNotEmpty) {
        final imagePath = users.first[DBHelper.COL_PROFILE_IMAGE];
        if (imagePath != null && File(imagePath).existsSync()) {
          return File(imagePath);
        }
      }
    } catch (e) {
      print("Error loading profile image: $e");
    }
    return null;
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.textSecondary,
            size: screenWidth * 0.035,
          ),
          SizedBox(width: screenWidth * 0.015),
          Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleConditionChip(String condition, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        condition,
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHealthOverview() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        // Medications taken count
        final medsTaken = provider.medications
            .where((m) => m[DBHelper.COL_MED_IS_TAKEN] == 1)
            .length;

        final conditionsCount = provider.healthConditions.length;
        final allergiesCount = provider.allergies.length;

        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Health Overview",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Medications taken
              _buildOverviewCard(
                medsTaken.toString(),
                "Meds Taken",
                "This Week",
                Icons.medication,
                AppTheme.successColor,
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Health conditions
              _buildOverviewCard(
                conditionsCount.toString(),
                "Health Conditions",
                "Added by you",
                Icons.health_and_safety,
                AppTheme.warningColor,
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Allergies
              _buildOverviewCard(
                allergiesCount.toString(),
                "Allergies",
                "Added by you",
                Icons.warning_amber_rounded,
                AppTheme.errorColor,
              ),
              const SizedBox(height: AppTheme.spacingM),

              // View Details Button
              _buildViewDetailsButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(String value, String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton(BuildContext context) {
    final navigatorBarState = context.findAncestorStateOfType<NavigatorBarState>();

    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          navigatorBarState?.goToLogs();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.successColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'View Details',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactMedicationsSection(BuildContext context, DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Medications",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _showAddMedicationDialog(context),
                icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryColor, size: 30),
                tooltip: 'Add Medication',
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),

          // Compact medication list
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              children: [
                ...provider.medications.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> medication = entry.value;
                  bool isLast = index == provider.medications.length - 1;

                  return _buildCompactMedicationItem(context, medication, index, isLast, provider);
                }),
                if (provider.medications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      children: [
                        Icon(Icons.medication_outlined,
                            size: 48,
                            color: AppTheme.textHint),
                        const SizedBox(height: 8),
                        Text(
                          'No medications added yet',
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textHint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to add your first medication reminder',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMedicationItem(BuildContext context, Map<String, dynamic> medication,
      int index, bool isLast, DashboardProvider provider)
  {
    final bool isTaken = medication[DBHelper.COL_MED_IS_TAKEN] == 1;
    final int timeStamp = medication[DBHelper.COL_MED_TIME];
    final medicationDateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    final medicationTime = TimeOfDay.fromDateTime(medicationDateTime).format(context);

    return GestureDetector(
      onTap: () => provider.toggleMedicationTaken(index),
      onLongPress: () => _confirmDeleteMedication(context, index),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isTaken ? AppTheme.successColor.withOpacity(0.05) : null,
          border: isLast ? null : Border(
            bottom: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isTaken ? AppTheme.successColor : Colors.transparent,
                border: Border.all(
                  color: isTaken ? AppTheme.successColor : AppTheme.textHint,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isTaken
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: AppTheme.spacingM),

            // Medication info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication[DBHelper.COL_MED_NAME],
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isTaken ? TextDecoration.lineThrough : null,
                      color: isTaken ? AppTheme.textHint : null,
                    ),
                  ),
                  if (medication[DBHelper.COL_MED_DOSAGE].toString().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      medication[DBHelper.COL_MED_DOSAGE],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textHint,
                        decoration: isTaken ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isTaken
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                medicationTime,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isTaken ? AppTheme.successColor : AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection(BuildContext context, DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upcoming Appointments",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          provider.appointments.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 48,
                      color: AppTheme.textHint),
                  const SizedBox(height: 8),
                  Text(
                    "No upcoming appointments",
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find nearby doctors to book appointments',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
          )
              : Column(
            children: provider.appointments
                .map((appointment) => _buildAppointmentCard(context, appointment, provider))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Map<String, dynamic> appointment, DashboardProvider provider) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(appointment['date'] as int);
    String formattedDate = DateFormat("dd MMM yyyy").format(date);

    return GestureDetector(
      onLongPress: () async {
        bool? confirmDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Appointment"),
            content: Text("Are you sure you want to delete the appointment?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text("Delete"),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (confirmDelete == true) {
          await provider.deleteAppointment(appointment['id']);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: provider.appointments.last == appointment ? 0 : AppTheme.spacingM),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            // Doctor Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.medical_services_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),

            // Appointment Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment['doctor'] ?? "Unknown Doctor",
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment['specialty'] ?? "Specialty",
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: AppTheme.textHint),
                      const SizedBox(width: 4),
                      Text(
                        "$formattedDate • ${appointment['time']}",
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Appointment Type (badge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                appointment['type'] ?? "In-person",
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyDoctorsSection(BuildContext context) {
    final navigatorBarState = context.findAncestorStateOfType<NavigatorBarState>();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nearby Doctors",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  navigatorBarState?.goToNearbyDoctors();
                },
                child: const Text("View All"),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          GestureDetector(
            onTap: () {
              navigatorBarState?.goToNearbyDoctors();
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/maps_preview.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Find nearby doctors',
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
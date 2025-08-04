import 'package:flutter/material.dart';
import '../../main.dart';
import '../back_screens/navigation.dart';

class UserDashBoard extends StatefulWidget {
  const UserDashBoard({super.key});

  @override
  State<UserDashBoard> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashBoard> {

  final List<Map<String, dynamic>> medications = [
    {
      'id': 'add_new',
      'name': 'Add New Reminder',
      'description': 'Tap to add',
      'time': '',
      'isTaken': false,
      'isAddButton': true,
    },
    {
      'id': '1',
      'name': 'Petrol',
      'description': '500mg - Fever',
      'time': '9:00 AM',
      'isTaken': false,
      'isAddButton': false,
    },
    {
      'id': '2',
      'name': 'Afeem',
      'description': 'Amlodipine 5mg',
      'time': '9:30 AM',
      'isTaken': true,
      'isAddButton': false,
    },
    {
      'id': '3',
      'name': 'Ganja',
      'description': 'Asthma Relief',
      'time': '2:00 PM',
      'isTaken': false,
      'isAddButton': false,
    },
  ];

  final List<Map<String, dynamic>> appointments = [
    {
      'doctor': 'Dr. Baba',
      'specialty': 'Nikhil"s Favourite ',
      'date': '6 Aug',
      'time': '10:30 AM',
      'type': 'Checkup / Date',
    },
  ];

  final List<Map<String, String>> nearbyDoctors = [
    {'name': 'Dr. Parab', 'specialty': 'Panauti Expert', 'distance': '0.5 km'},
    {'name': 'Dr. Kadam', 'specialty': 'Insta Id Finder', 'distance': '1.2 km'},
    {'name': 'Dr. Kashid', 'specialty': 'Liquor', 'distance': '2.1 km'},
  ];

  void toggleMedicationTaken(int index) {
    if (!medications[index]['isAddButton']) {
      setState(() {
        medications[index]['isTaken'] = !medications[index]['isTaken'];
      });
    }
  }

  void addNewMedication() {
    // TODO: Navigate to add medication screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add medication feature will be implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildUserProfile(),
            const SizedBox(height: AppTheme.spacingXL),

            // Health Overview Cards
            _buildHealthOverview(),
            const SizedBox(height: AppTheme.spacingXL),

            // Today's Medications
            _buildMedicationsSection(),
            const SizedBox(height: AppTheme.spacingXL),

            // Upcoming Appointments
            _buildAppointmentsSection(),
            const SizedBox(height: AppTheme.spacingXL),

            // Nearby Doctors Quick Access
            _buildNearbyDoctorsSection(),
            const SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
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
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(35),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pritam Thopate",
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Age: 20 • Male",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textHint,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildConditionChip("Asthma"),
                    _buildConditionChip("High BP"),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConditionChip(String condition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        condition,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHealthOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Health Overview",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(child: _buildOverviewCard("12", "Meds Taken", "This Week", Icons.medication, AppTheme.successColor)),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(child: _buildOverviewCard("8", "AI Assists", "Used", Icons.smart_toy, AppTheme.primaryColor)),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(child: _buildOverviewCard("15", "Scans Done", "Total", Icons.qr_code_scanner, AppTheme.warningColor)),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(child: _buildOverviewCard("2", "Fever Alert", "Days Ago", Icons.thermostat, AppTheme.errorColor)),
          ],
        ),
      ],
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

  Widget _buildMedicationsSection() {
    return Column(
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
            TextButton(
              onPressed: () {
                // TODO: Navigate to all medications
              },
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: medications.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingM),
            itemBuilder: (context, index) {
              final medication = medications[index];
              return _buildMedicationCard(medication, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication, int index) {
    final bool isAddButton = medication['isAddButton'] ?? false;
    final bool isTaken = medication['isTaken'] ?? false;

    return GestureDetector(
      onTap: () {
        if (isAddButton) {
          addNewMedication();
        } else {
          toggleMedicationTaken(index);
        }
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isAddButton
              ? AppTheme.primaryColor.withOpacity(0.1)
              : isTaken
              ? AppTheme.successColor.withOpacity(0.1)
              : AppTheme.surfaceColor,
          border: Border.all(
            color: isAddButton
                ? AppTheme.primaryColor.withOpacity(0.3)
                : isTaken
                ? AppTheme.successColor
                : AppTheme.borderColor,
            width: isAddButton ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
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
                Expanded(
                  child: Text(
                    medication['name'],
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isAddButton ? AppTheme.primaryColor : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isAddButton)
                  Icon(
                    isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isTaken ? AppTheme.successColor : AppTheme.textHint,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (!isAddButton) ...[
              Text(
                medication['description'],
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textHint,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (medication['time'].isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: AppTheme.textHint),
                    const SizedBox(width: 4),
                    Text(
                      medication['time'],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ] else ...[
              const Spacer(),
              Center(
                child: Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  medication['description'],
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Upcoming Appointments",
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all appointments
              },
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...appointments.map((appointment) => _buildAppointmentCard(appointment)),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['doctor'],
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment['specialty'],
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textHint,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppTheme.textHint),
                    const SizedBox(width: 4),
                    Text(
                      "${appointment['date']} • ${appointment['time']}",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              appointment['type'],
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.warningColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyDoctorsSection() {

    final navigatorBarState = context.findAncestorStateOfType<NavigatorBarState>();

    return Column(
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
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Adjust radius here
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/maps_preview.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
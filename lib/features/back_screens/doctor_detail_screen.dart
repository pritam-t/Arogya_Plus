  import 'package:flutter/material.dart';
  import 'package:url_launcher/url_launcher_string.dart';
  
  import '../../data/local/db_helper.dart';
import '../../main.dart';
  // Import your main.dart file to access AppTheme
  
  class DoctorDetailsScreen extends StatelessWidget {
    final Map<String, dynamic> doctor;
  
    const DoctorDetailsScreen({Key? key, required this.doctor}) : super(key: key);
  
    Color _getExpertiseColor(String expertise) {
      switch (expertise.toLowerCase()) {
        case 'general medicine':
          return AppTheme.primaryColor;
        case 'pediatrics':
          return Colors.pink;
        case 'cardiology':
          return AppTheme.errorColor;
        case 'gynecology':
          return Colors.purple;
        case 'orthopedics':
          return AppTheme.warningColor;
        case 'dermatology':
          return Colors.teal;
        default:
          return AppTheme.primaryColor;
      }
    }
  
    IconData _getExpertiseIcon(String expertise) {
      switch (expertise.toLowerCase()) {
        case 'general medicine':
          return Icons.medical_services;
        case 'pediatrics':
          return Icons.child_care;
        case 'cardiology':
          return Icons.favorite;
        case 'gynecology':
          return Icons.pregnant_woman;
        case 'orthopedics':
          return Icons.accessibility_new;
        case 'dermatology':
          return Icons.face;
        default:
          return Icons.medical_services;
      }
    }
  
    // Generate avatar based on doctor name
    String _getAvatarText(String doctorName) {
      List<String> nameParts = doctorName.split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}';
      } else if (nameParts.isNotEmpty) {
        return nameParts[0].substring(0, 2).toUpperCase();
      }
      return 'DR';
    }
  
    Color _getAvatarColor(String doctorName) {
      // Generate consistent color based on name hash
      int hash = doctorName.hashCode;
      List<Color> colors = [
        AppTheme.primaryColor,
        Colors.purple,
        Colors.teal,
        Colors.orange,
        Colors.pink,
        Colors.indigo,
        Colors.green,
        Colors.red,
      ];
      return colors[hash.abs() % colors.length];
    }

    Future<void> _showAppointmentDialog(BuildContext context, Map<String, dynamic> doctor) async {
      final TextEditingController timeController = TextEditingController();
      String appointmentType = "In-person"; // default
      DateTime? selectedDate;

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Book Appointment with ${doctor['doctorName']}"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Select Date
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        icon: Icon(Icons.calendar_today),
                        label: Text(selectedDate == null
                            ? "Pick Date"
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedDate != null
                              ? AppTheme.successColor
                              : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Enter Time
                    TextField(
                      controller: timeController,
                      decoration: InputDecoration(
                        labelText: "Time (e.g. 14:30)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Select Type
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: appointmentType,
                          isExpanded: true,
                          items: ["In-person", "Online"]
                              .map((t) => DropdownMenuItem(
                            value: t,
                            child: Row(
                              children: [
                                Icon(t == "In-person"
                                    ? Icons.local_hospital
                                    : Icons.video_call),
                                SizedBox(width: 8),
                                Text(t),
                              ],
                            ),
                          ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              appointmentType = val!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.check),
                    label: Text("Book Appointment"),
                    onPressed: () async {
                      if (selectedDate != null && timeController.text.isNotEmpty) {
                        try {
                          await DBHelper.getInstance.insertAppointment(
                            doctor: doctor['doctorName'],
                            specialty: doctor['expertise'],
                            date: selectedDate!.millisecondsSinceEpoch,
                            time: timeController.text,
                            type: appointmentType,
                          );

                          Navigator.pop(dialogContext);

                          // Show success snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Appointment Booked!',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'With Dr. ${doctor['doctorName']} on ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at ${timeController.text}',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppTheme.successColor,
                              duration: Duration(seconds: 4),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.all(16),
                              action: SnackBarAction(
                                label: 'View',
                                textColor: Colors.white,
                                onPressed: () {

                                },
                              ),
                            ),
                          );
                        } catch (e) {
                          // Show error snackbar if booking fails
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Failed to book appointment. Please try again.'),
                                ],
                              ),
                              backgroundColor: AppTheme.errorColor,
                              duration: Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.all(16),
                            ),
                          );
                        }
                      } else {
                        // Show validation snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Please select date and time'),
                              ],
                            ),
                            backgroundColor: AppTheme.warningColor,
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: EdgeInsets.all(16),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      final screenSize = MediaQuery.of(context).size;
      final screenWidth = screenSize.width;
      final screenHeight = screenSize.height;
  
      final expertiseColor = _getExpertiseColor(doctor['expertise']);
      final expertiseIcon = _getExpertiseIcon(doctor['expertise']);
      final avatarText = _getAvatarText(doctor['doctorName']);
      final avatarColor = _getAvatarColor(doctor['doctorName']);
  
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: CustomScrollView(
          slivers: [
            // Custom App Bar with Hero Section

            SliverAppBar(
              expandedHeight: screenHeight * 0.25, // reduced height
              pinned: true,
              elevation: 0,
              backgroundColor: expertiseColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        expertiseColor,
                        expertiseColor.withOpacity(0.85),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.015,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end, // push content to bottom
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Doctor Avatar (smaller)
                          Container(
                            width: screenWidth * 0.20,
                            height: screenWidth * 0.20,
                            decoration: BoxDecoration(
                              color: avatarColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                avatarText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.01),

                          // Doctor Name
                          Text(
                            doctor['doctorName'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: screenHeight * 0.005),

                          // Rating Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Colors.amber[300], size: screenWidth * 0.045),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                '${doctor['rating']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.038,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.015),
                              Flexible(
                                child: Text(
                                  '(${doctor['reviews']} reviews)',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: screenWidth * 0.033,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
  
            // Content
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              Icons.location_on,
                              doctor['distanceText'],
                              'Distance',
                              AppTheme.errorColor,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              Icons.access_time,
                              doctor['isAvailable'] ? 'Available' : 'Closed',
                              'Status',
                              doctor['isAvailable'] ? AppTheme.successColor : AppTheme.warningColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.04),
  
                      // Information Cards
                      _buildInfoCard(
                        context,
                        'Specialization',
                        Icons.medical_services,
                        expertiseColor,
                        [
                          _InfoItem('Expertise', doctor['expertise']),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.025),
  
                      _buildInfoCard(
                        context,
                        'Contact Information',
                        Icons.contact_phone,
                        AppTheme.primaryColor,
                        [
                          if (doctor['phoneNumber'].isNotEmpty)
                            _InfoItem('Phone', doctor['phoneNumber']),
                          _InfoItem('Address', doctor['address']),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.025),
  
                      _buildInfoCard(
                        context,
                        'Working Hours',
                        Icons.schedule,
                        AppTheme.warningColor,
                        [
                          _InfoItem('Timing', _formatTiming(doctor['timing'])),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.05),
  
                      // Action Buttons
                      _buildActionButtons(context),
                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  
    Widget _buildStatCard(BuildContext context, IconData icon, String value, String label, Color color) {
      final screenWidth = MediaQuery.of(context).size.width;
  
      return Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: screenWidth * 0.06),
            SizedBox(height: screenWidth * 0.02),
            Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
  
    Widget _buildInfoCard(BuildContext context, String title, IconData icon, Color color, List<_InfoItem> items) {
      final screenWidth = MediaQuery.of(context).size.width;
  
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: screenWidth * 0.055),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: items.map((item) => _buildInfoRow(context, item.title, item.value)).toList(),
              ),
            ),
          ],
        ),
      );
    }
  
    Widget _buildInfoRow(BuildContext context, String title, String value) {
      final screenWidth = MediaQuery.of(context).size.width;
  
      return Padding(
        padding: EdgeInsets.only(bottom: screenWidth * 0.03),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: screenWidth * 0.2,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }
  
    Widget _buildActionButtons(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final expertiseColor = _getExpertiseColor(doctor['expertise']);
  
      return Column(
        children: [
          // Primary Actions Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (doctor['phoneNumber'].isNotEmpty) {
                      launchUrlString('tel:${doctor['phoneNumber']}');
                    }
                  },
                  icon: Icon(Icons.phone, size: screenWidth * 0.05),
                  label: Text(
                    'Call Now',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (doctor['location'] != null) {
                      launchUrlString(doctor['location']);
                    }
                  },
                  icon: Icon(Icons.directions, size: screenWidth * 0.05),
                  label: Text(
                    'Directions',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          // Book Appointment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: doctor['isAvailable']
                  ? () async {
                await _showAppointmentDialog(context, doctor);
              }
                  : null,

              icon: Icon(Icons.calendar_today, size: screenWidth * 0.05),
              label: Text(
                'Book Appointment',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: expertiseColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.textHint,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }
  
    String _formatTiming(String timing) {
      if (timing == "Not Available") return timing;
      // Split by commas and take first few entries to avoid overflow
      List<String> timeParts = timing.split(', ');
      if (timeParts.length > 3) {
        return timeParts.take(3).join('\n') + '\n...';
      }
      return timeParts.join('\n');
    }
  }
  
  class _InfoItem {
    final String title;
    final String value;
  
    _InfoItem(this.title, this.value);
  }
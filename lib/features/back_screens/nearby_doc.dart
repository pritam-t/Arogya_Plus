import 'package:flutter/material.dart';

import '../../main.dart';

class NearbyDoc_Screen extends StatefulWidget {
  const NearbyDoc_Screen({super.key});

  @override
  State<NearbyDoc_Screen> createState() => _NearbyDoctorsScreenState();
}

class _NearbyDoctorsScreenState extends State<NearbyDoc_Screen> {
  // Sample data - sorted by distance (nearest first)
  final List<Map<String, dynamic>> nearbyDoctors = [
    {
      'id': '1',
      'doctorName': 'Dr. Rajesh Kumar',
      'clinicName': 'Kumar Medical Center',
      'expertise': 'General Medicine',
      'distance': 0.3,
      'distanceText': '0.3 km',
      'timing': '9:00 AM - 8:00 PM',
      'rating': 4.8,
      'reviews': 245,
      'isAvailable': true,
      'phoneNumber': '+91 98765 43210',
      'address': 'Shop 12, Medical Complex, Main Road',
    },
    {
      'id': '2',
      'doctorName': 'Dr. Priya Shah',
      'clinicName': 'Shah Pediatric Clinic',
      'expertise': 'Pediatrics',
      'distance': 0.7,
      'distanceText': '0.7 km',
      'timing': '10:00 AM - 6:00 PM',
      'rating': 4.9,
      'reviews': 189,
      'isAvailable': true,
      'phoneNumber': '+91 98765 43211',
      'address': 'B-Wing, Healthcare Plaza, Near Bus Stand',
    },
    {
      'id': '3',
      'doctorName': 'Dr. Anil Verma',
      'clinicName': 'Heart Care Clinic',
      'expertise': 'Cardiology',
      'distance': 1.2,
      'distanceText': '1.2 km',
      'timing': '8:00 AM - 2:00 PM',
      'rating': 4.7,
      'reviews': 321,
      'isAvailable': false,
      'phoneNumber': '+91 98765 43212',
      'address': 'Ground Floor, Medicity Complex, City Center',
    },
    {
      'id': '4',
      'doctorName': 'Dr. Sunita Joshi',
      'clinicName': 'Women\'s Health Center',
      'expertise': 'Gynecology',
      'distance': 1.5,
      'distanceText': '1.5 km',
      'timing': '11:00 AM - 7:00 PM',
      'rating': 4.6,
      'reviews': 156,
      'isAvailable': true,
      'phoneNumber': '+91 98765 43213',
      'address': 'Second Floor, Women\'s Medical Hub, Mall Road',
    },
    {
      'id': '5',
      'doctorName': 'Dr. Mohit Singh',
      'clinicName': 'Bone & Joint Clinic',
      'expertise': 'Orthopedics',
      'distance': 2.1,
      'distanceText': '2.1 km',
      'timing': '9:00 AM - 5:00 PM',
      'rating': 4.5,
      'reviews': 98,
      'isAvailable': true,
      'phoneNumber': '+91 98765 43214',
      'address': 'First Floor, Orthopedic Center, Hospital Road',
    },
    {
      'id': '6',
      'doctorName': 'Dr. Kavita Reddy',
      'clinicName': 'Skin & Hair Clinic',
      'expertise': 'Dermatology',
      'distance': 2.8,
      'distanceText': '2.8 km',
      'timing': '10:00 AM - 8:00 PM',
      'rating': 4.4,
      'reviews': 234,
      'isAvailable': true,
      'phoneNumber': '+91 98765 43215',
      'address': 'Third Floor, Beauty & Wellness Center, Park Street',
    },
  ];

  String selectedFilter = 'All';
  final List<String> specialtyFilters = [
    'All',
    'General Medicine',
    'Pediatrics',
    'Cardiology',
    'Gynecology',
    'Orthopedics',
    'Dermatology',
  ];

  List<Map<String, dynamic>> get filteredDoctors {
    if (selectedFilter == 'All') {
      return nearbyDoctors;
    }
    return nearbyDoctors.where((doctor) => doctor['expertise'] == selectedFilter).toList();
  }

  Color _getExpertiseColor(String expertise) {
    switch (expertise.toLowerCase()) {
      case 'general medicine':
        return AppTheme.primaryColor;
      case 'pediatrics':
        return Colors.pink;
      case 'cardiology':
        return Colors.red;
      case 'gynecology':
        return Colors.purple;
      case 'orthopedics':
        return Colors.orange;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nearby Doctors'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature will be implemented')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // Doctors List
          Expanded(
            child: filteredDoctors.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: filteredDoctors.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingM),
              itemBuilder: (context, index) {
                return _buildDoctorCard(filteredDoctors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        itemCount: specialtyFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppTheme.spacingS),
        itemBuilder: (context, index) {
          final filter = specialtyFilters[index];
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                ),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : AppTheme.textHint,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final expertiseColor = _getExpertiseColor(doctor['expertise']);
    final expertiseIcon = _getExpertiseIcon(doctor['expertise']);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
        border: Border.all(color: AppTheme.borderColor),
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
          // Doctor Header Info
          Row(
            children: [
              // Doctor Image/Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [expertiseColor, expertiseColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Icon(
                    expertiseIcon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),

              // Doctor Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor['doctorName'],
                            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: doctor['isAvailable'] ? AppTheme.successColor : AppTheme.errorColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor['isAvailable'] ? 'Available' : 'Busy',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: doctor['isAvailable'] ? AppTheme.successColor : AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor['clinicName'],
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor['rating']} (${doctor['reviews']} reviews)',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Expertise Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: expertiseColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: expertiseColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(expertiseIcon, size: 16, color: expertiseColor),
                const SizedBox(width: 6),
                Text(
                  doctor['expertise'],
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: expertiseColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Timing and Distance Info
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: AppTheme.textHint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        doctor['timing'],
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    doctor['distanceText'],
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingS),

          // Address
          Row(
            children: [
              Icon(Icons.location_city, size: 16, color: AppTheme.textHint),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  doctor['address'],
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textHint,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement call functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${doctor['doctorName']}...')),
                    );
                  },
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: doctor['isAvailable'] ? () {
                    // TODO: Implement book appointment functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking appointment with ${doctor['doctorName']}...')),
                    );
                  } : null,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('Book'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              IconButton(
                onPressed: () {
                  // TODO: Implement directions functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Getting directions to ${doctor['clinicName']}...')),
                  );
                },
                icon: Icon(Icons.directions, color: AppTheme.primaryColor),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'No doctors found',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textHint,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Try changing your filter selection',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
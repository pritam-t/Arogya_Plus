import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

import '../../main.dart';
import 'doctor_detail_screen.dart';

class NearbyDoc_Screen extends StatefulWidget
{
  const NearbyDoc_Screen({super.key});

  @override
  State<NearbyDoc_Screen> createState() => _NearbyDoctorsScreenState();
}

class _NearbyDoctorsScreenState extends State<NearbyDoc_Screen> {
  List<Map<String, dynamic>> nearbyDoctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initFetch();
  }

  Future<void> _initFetch() async {
    bool permissionGranted = await _handleLocationPermission();
    if (permissionGranted) {
      await fetchDoctors();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')),
      );
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
            Text('Location permission denied. Enable to see nearby doctors.'),
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permission permanently denied. Enable from settings.'),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> fetchDoctors() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double lat = position.latitude;
      double lng = position.longitude;

      final apiKey = "AIzaSyCds-eRBeUj-Hk4K3D8nq2eYZb5DJZmo_A";
      final radius = 5000; // 5 km
      final type = "doctor";

      final url =
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=$radius&type=$type&key=$apiKey";

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] != 'OK') {
        throw Exception('Places API error: ${data['status']}');
      }

      List<Map<String, dynamic>> doctors = [];

      for (var result in data['results'])
      {
        final placeId = result['place_id'];
        final detailsUrl =
            "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,formatted_phone_number,rating,user_ratings_total,opening_hours,geometry,types,vicinity&key=$apiKey";

        final detailsResponse = await http.get(Uri.parse(detailsUrl));
        final detailsData = json.decode(detailsResponse.body)['result'];

        double distanceInMeters = Geolocator.distanceBetween(
          lat,
          lng,
          detailsData['geometry']['location']['lat'],
          detailsData['geometry']['location']['lng'],
        );
        String distanceText = (distanceInMeters / 1000).toStringAsFixed(1) + ' km';

        // Handle JSON arrays safely
        String expertise = (detailsData['types'] as List<dynamic>?)
            ?.join(", ") ??
            "General Medicine";
        String timing = (detailsData['opening_hours']?['weekday_text']
        as List<dynamic>?)
            ?.join(", ") ??
            "Not Available";

        doctors.add({
          "doctorName": detailsData['name'] ?? "",
          "clinicName": detailsData['name'] ?? "",
          "expertise": expertise,
          "distance": distanceInMeters / 1000,
          "distanceText": distanceText,
          "timing": timing,
          "rating": detailsData['rating'] ?? 0.0,
          "reviews": detailsData['user_ratings_total'] ?? 0,
          "isAvailable": true,
          "phoneNumber": detailsData['formatted_phone_number'] ?? "",
          "address": detailsData['vicinity'] ?? "",
          "location":
          "https://www.google.com/maps?q=${detailsData['geometry']['location']['lat']},${detailsData['geometry']['location']['lng']}",
        });
      }

      // Sort doctors by distance (nearest first)
      doctors.sort((a, b) => a['distance'].compareTo(b['distance']));

      setState(() {
        nearbyDoctors = doctors;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching doctors: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching doctors: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
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

  void _showDoctorDetails(Map<String, dynamic> doctor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DoctorDetailsScreen(doctor: doctor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header section with title and back button
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.add_location, size: 28, color: Colors.green),
                  SizedBox(width: 10,),
                  Center(
                    child: Text(
                      'Doctors near you',
                      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${nearbyDoctors.length} found',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Finding nearby doctors...'),
                  ],
                ),
              )
                  : nearbyDoctors.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                itemCount: nearbyDoctors.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: AppTheme.spacingM),
                itemBuilder: (context, index) =>
                    _buildDoctorCard(nearbyDoctors[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No doctors found nearby',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try expanding your search area or check your location',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final expertiseColor = _getExpertiseColor(doctor['expertise']);
    final expertiseIcon = _getExpertiseIcon(doctor['expertise']);

    return GestureDetector(
      onTap: () => _showDoctorDetails(doctor),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Doctor Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [expertiseColor, expertiseColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Icon(expertiseIcon, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 16),

            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['doctorName'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                        '${doctor['rating']} (${doctor['reviews']})',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.red[400]),
                      const SizedBox(width: 4),
                      Text(
                        doctor['distanceText'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (doctor['phoneNumber'].isNotEmpty) {
                        launchUrlString('tel:${doctor['phoneNumber']}');
                      }
                    },
                    icon: Icon(Icons.phone, color: Colors.green[600], size: 20),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// global_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediscan_plus/main.dart';

import '../../Provider/Assistant_Cubit/search_cubit.dart';
import '../../Provider/Scan_Cubit/scan_medi_cubit.dart';
import '../user_screens/ai_assistant.dart';
import '../user_screens/dashboard.dart';
import '../user_screens/medi_scan.dart';
import '../user_screens/user_logs.dart';
import '../user_screens/profile.dart';
import 'nearby_doc.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentPageIndex;
  final VoidCallback? onNotificationPressed;

  const GlobalAppBar({
    super.key,
    required this.currentPageIndex,
    this.onNotificationPressed,
  });

  // Page titles
  static const List<String> pageTitles = [
    'Dashboard', // Home
    'AI Assistant', // AI/Search
    'Scan Medicine', // Scan
    'My Logs', // Logs
    'Profile', // Profile
    'Nearby Doctors', // Additional
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentTitle = currentPageIndex < pageTitles.length
        ? pageTitles[currentPageIndex]
        : 'Arogya+';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
            Colors.white,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // Make AppBar transparent to show gradient
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // App Logo
            SizedBox(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              child: Image.asset(
                'assets/images/app_bar_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.medical_services,
                    color: Colors.white,
                    size: screenWidth * 0.07,
                  );
                },
              ),
            ),

            SizedBox(width: screenWidth * 0.03),

            // Page Title
            Expanded(
              child: Text(
                currentTitle,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Notification button
          Container(
            margin: EdgeInsets.only(right: screenWidth * 0.04),
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined, size: screenWidth * 0.05),
                  color: Colors.white,
                  onPressed: onNotificationPressed ?? () => _showNotificationDialog(context),
                ),
                // Notification badge
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        // Bottom border with gradient effect
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade200.withOpacity(0.3),
                  Colors.white.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    // Sample notification data - replace with your actual notifications
    final notifications = [
      {
        'title': 'Medication Reminder',
        'message': 'Time to take your morning medication - Aspirin 500mg',
        'time': '9:00 AM',
        'icon': Icons.medication,
        'isRead': false,
      },
      {
        'title': 'Appointment Reminder',
        'message': 'You have an appointment with Dr. Smith tomorrow at 2:00 PM',
        'time': '1 day ago',
        'icon': Icons.calendar_today,
        'isRead': true,
      },
      {
        'title': 'Health Tip',
        'message': 'Don\'t forget to stay hydrated! Aim for 8 glasses of water today.',
        'time': '2 days ago',
        'icon': Icons.lightbulb_outline,
        'isRead': true,
      },
      {
        'title': 'Medication Refill',
        'message': 'Your prescription is running low. Consider refilling soon.',
        'time': '3 days ago',
        'icon': Icons.warning_amber,
        'isRead': false,
      },
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications,
                          color: Colors.blue.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notifications list
                Flexible(
                  child: notifications.isEmpty
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                      : ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (notification['isRead'] as bool)
                                ? Colors.grey.shade100
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            notification['icon'] as IconData,
                            color: (notification['isRead'] as bool)
                                ? Colors.grey.shade600
                                : Colors.blue.shade600,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          notification['title'] as String,
                          style: TextStyle(
                            fontWeight: (notification['isRead'] as bool)
                                ? FontWeight.normal
                                : FontWeight.w600,
                            color: (notification['isRead'] as bool)
                                ? Colors.grey.shade700
                                : Colors.grey.shade800,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notification['message'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification['time'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        trailing: !(notification['isRead'] as bool)
                            ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        )
                            : null,
                        onTap: () {
                          // Handle notification tap
                          // You can navigate to specific screens based on notification type
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opened: ${notification['title']}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                if (notifications.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Mark all as read functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All notifications marked as read'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        child: const Text('Mark All as Read'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Clear all notifications functionality
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All notifications cleared'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + 8); // +1 for border // +1 for border // +1 for border// +1 for border// +1 for border
}

// ---------------- NavigatorBar ----------------
class NavigatorBar extends StatefulWidget {
  const NavigatorBar({super.key});

  @override
  State<NavigatorBar> createState() => NavigatorBarState();
}

class NavigatorBarState extends State<NavigatorBar> {
  int currentPage = 0;

  // Screens
  List<Widget> pages = [
    UserDashBoard(),
    BlocProvider(create: (context) => SearchCubit(), child: AI_Assistant_Screen()),
    BlocProvider(create: (context) => ScanMediCubit(), child: const ScanMedi_Screen()),
    User_Logs_Screen(),
    UserSetting_Screen(),
    NearbyDoc_Screen(),
  ];

  // Navigation items
  final List<NavigationItem> navigationItems = [
    NavigationItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    NavigationItem(icon: Icons.smart_toy_outlined, activeIcon: Icons.smart_toy_outlined, label: 'Search'),
    NavigationItem(icon: Icons.document_scanner_outlined, activeIcon: Icons.document_scanner_outlined, label: 'Scan', isCenter: true),
    NavigationItem(icon: Icons.fact_check, activeIcon: Icons.fact_check_outlined, label: 'Cart'),
    NavigationItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  void _onItemTapped(int index) {
    FocusScope.of(context).unfocus();
    setState(() {
      currentPage = index;
    });
  }

  void goToNearbyDoctors() {
    setState(() {
      currentPage = 5;
    });
  }

  void goToLogs() {
    setState(() {
      currentPage = 3; // User Logs index
    });
  }

  void gotoDashboard() {
    setState(() {
      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentPage != 0) {
          setState(() {
            currentPage = 0;
          });
        }
      },
      child: Scaffold(
        appBar: GlobalAppBar(
          currentPageIndex: currentPage,
          onNotificationPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You have 3 new notifications'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        body: IndexedStack(
          index: currentPage,
          children: pages,
        ),

        // Bottom Navigation Bar
// Bottom Navigation Bar with gradient
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: screenHeight * 0.10,
            child: Stack(
              children: [
                // Main navigation bar with gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: screenHeight * 0.07,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade200,
                          Colors.blue.shade400,
                        ],
                        stops: [0.0, 1.0],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Left items
                        for (int i = 0; i < 2; i++) _buildNavigationItem(i, screenWidth, screenHeight),
                        // Spacer for center button
                        SizedBox(width: screenWidth * 0.18),
                        // Right items
                        for (int i = 3; i < navigationItems.length; i++) _buildNavigationItem(i, screenWidth, screenHeight),
                      ],
                    ),
                  ),
                ),

                // Floating center button with enhanced gradient
                Positioned(
                  top: screenHeight * 0.005,
                  left: screenWidth / 2 - screenWidth * 0.08,
                  child: GestureDetector(
                    onTap: () => _onItemTapped(2),
                    child: Container(
                      width: screenWidth * 0.16,
                      height: screenWidth * 0.16,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                            Colors.blue.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade600.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        // Add a subtle white border to match the gradient theme
                        border: Border.all(
                          color: Colors.black,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        currentPage == 2 ? navigationItems[2].activeIcon : navigationItems[2].icon,
                        color: Colors.black,
                        size: screenWidth * 0.09,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),      ),
    );
  }

  Widget _buildNavigationItem(int index, double screenWidth, double screenHeight) {
    final item = navigationItems[index];
    final isActive = currentPage == index;

    return SizedBox(
      width: screenWidth * 0.18,
      height: screenHeight * 0.09,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () => _onItemTapped(index),
        splashColor: AppTheme.primaryColor.withOpacity(0.2),
        highlightColor: Colors.transparent,
        child: Center(
          child: Icon(
            isActive ? item.activeIcon : item.icon,
            color: isActive ? Colors.white70 : Colors.black,
            size: isActive ? screenWidth * 0.085 : screenWidth * 0.07,
          ),
        ),
      ),
    );
  }
}

// ---------------- Navigation Item Class ----------------
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isCenter;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isCenter = false,
  });
}

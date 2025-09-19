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

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
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
                  color: AppTheme.primaryColor,
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
                color: Colors.black87,
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
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, size: screenWidth * 0.05),
                color: Colors.grey[700],
                onPressed: onNotificationPressed ??
                        () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications pressed')),
                      );
                    },
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
      // Bottom border
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          height: 1.0,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + 8); // +1 for border
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
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: screenHeight * 0.10,
            child: Stack(
              children: [
                // Main navigation bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: screenHeight * 0.07,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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

                // Floating center button
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
                          colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        currentPage == 2 ? navigationItems[2].activeIcon : navigationItems[2].icon,
                        color: Colors.white,
                        size: screenWidth * 0.09,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            color: isActive ? AppTheme.primaryColor : Colors.grey[600],
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

import 'package:flutter/material.dart';
import 'package:mediscan_plus/features/user_screens/user_setting.dart';
import 'package:mediscan_plus/main.dart';
import '../user_screens/ai_assistant.dart';
import '../user_screens/dashboard.dart';
import '../user_screens/medi_scan.dart';
import '../user_screens/user_logs.dart';


class NavigatorBar extends StatefulWidget {
  const NavigatorBar({super.key});

  @override
  State<NavigatorBar> createState() => _NavigatorBarState();
}

class _NavigatorBarState extends State<NavigatorBar> with TickerProviderStateMixin {
  int currentPage = 0;
  late AnimationController _animationController;
  late AnimationController _centerButtonController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _centerButtonAnimation;

  // Replace these with your actual screen widgets
  List<Widget> pages = [
    SafeArea(child: UserDashBoard()),
    SafeArea(child: AI_Assistant_Screen()),
    SafeArea(child: ScanMedi_Screen()),
    SafeArea(child: User_Logs_Screen()),
    SafeArea(child: UserSetting_Screen()),

    // Placeholder screens for demo
    const Center(child: Text('Home Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('AI Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Scan Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Log Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24))),
  ];

  // Navigation items configuration
  final List<NavigationItem> navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.smart_toy_outlined,
      activeIcon: Icons.smart_toy_outlined,
      label: 'Search',
    ),
    NavigationItem(
      icon: Icons.document_scanner_outlined,
      activeIcon: Icons.document_scanner_outlined,
      label: 'Scan',
      isCenter: true,
    ),
    NavigationItem(
      icon: Icons.fact_check,
      activeIcon: Icons.fact_check_outlined,
      label: 'Cart',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _centerButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _centerButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _centerButtonController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _centerButtonController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    FocusScope.of(context).unfocus();

    if (index == 2) { // Center button (Scan)
      _centerButtonController.forward().then((_) {
        _centerButtonController.reverse();
      });
    } else {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }

    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: currentPage,
          children: pages,
        ),
        bottomNavigationBar: SizedBox(
          height: 100,
          child: Stack(
            children: [
              // Main navigation bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Left items (Home, Search)
                      for (int i = 0; i < 2; i++)
                        _buildNavigationItem(i),

                      // Center space for floating button
                      const SizedBox(width: 60),

                      // Right items (Cart, Profile)
                      for (int i = 3; i < navigationItems.length; i++)
                        _buildNavigationItem(i),
                    ],
                  ),
                ),
              ),

              // Floating center button
              Positioned(
                top: 5,
                left: MediaQuery.of(context).size.width / 2 - 30,
                child: AnimatedBuilder(
                  animation: _centerButtonAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _centerButtonAnimation.value,
                      child: GestureDetector(
                        onTap: () => _onItemTapped(2),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor,
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            currentPage == 2
                                ? navigationItems[2].activeIcon
                                : navigationItems[2].icon,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(int index) {
    final item = navigationItems[index];
    final isActive = currentPage == index;

    return SizedBox(
      width: 80,
      height: 80,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () => _onItemTapped(index),
        splashColor: AppTheme.primaryColor,
        highlightColor: Colors.transparent,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey<bool>(isActive),
                color: isActive ? AppTheme.primaryColor : Colors.grey[600],
                size: isActive ? 35 : 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class for navigation items
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
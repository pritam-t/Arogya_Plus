import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  static const KEYLOGIN= 'login';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start fade animation
    _fadeController.forward();

    // Navigate after delay
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      skiplogin();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/images/splashscreen_logo.png',
            fit: BoxFit.fitHeight,
            errorBuilder: (context, error, stackTrace) {
              // Fallback in case image fails to load
              return Container(
                color: const Color(0xFF2563EB),
                child: const Center(
                  child: Text(
                    'Arogya+',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void skiplogin() async
  {
    final navigator = Navigator.of(context);
    var sharepref = await SharedPreferences.getInstance();
    var isLoggedIn = sharepref.getBool(KEYLOGIN);

    if(isLoggedIn!=null)
    {
      if(isLoggedIn) {
        navigator.pushReplacementNamed('/navigator-bar');
      } else {
        navigator.pushReplacementNamed('/login');
      }
    }
    else {
      navigator.pushReplacementNamed('/login');
    }
  }
}
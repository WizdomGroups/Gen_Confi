import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/client/home/client_home_dashboard.dart';
import 'package:gen_confi/features/experts/ui/experts_screen.dart';
import 'package:gen_confi/features/experts/ui/grooming_locked_screen.dart';
import 'package:gen_confi/features/client/grooming/ui/grooming_results_screen.dart'; // Added import for Grooming Results tab
import 'package:gen_confi/services/auth_store.dart';
import 'package:gen_confi/client/profile/profile_screen.dart'; // Restored import

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tabs: 0: Home, 1: Grooming, 2: Experts, 3: Profile
    final List<Widget> pages = [
      ClientHomeDashboard(
        onNavigateToTab: _onTabTapped, // Pass callback to allow Home to switch tabs
      ),
      // Index 1: Grooming (Results or Locked)
      AuthStore().hasCompletedGrooming && AuthStore().groomingImagePath != null
          ? GroomingResultsScreen(
              imagePath: AuthStore().groomingImagePath!,
              isTabMode: true,
            )
          : const GroomingLockedScreen(),
          
      // Index 2: Experts (Unlocked or Locked)
      AuthStore().hasCompletedGrooming 
          ? const ExpertsScreen() 
          : const GroomingLockedScreen(),
          
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.face_retouching_natural_rounded),
                label: 'Grooming',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_rounded),
                label: 'Experts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

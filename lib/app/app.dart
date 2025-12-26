import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/app/theme/app_theme.dart';
import 'package:gen_confi/features/auth/splash_screen.dart';
import 'package:gen_confi/features/auth/login_screen.dart';
import 'package:gen_confi/features/auth/signup_screen.dart';
import 'package:gen_confi/features/auth/role_selector.dart';
// import 'package:gen_confi/features/admin/dashboard/admin_dashboard.dart'; // Legacy removed
// import 'package:gen_confi/features/expert/dashboard/expert_dashboard.dart'; // Legacy removed
import 'package:gen_confi/features/client/onboarding/gender_mode_screen.dart';
import 'package:gen_confi/client/onboarding/body_type/body_type_screen.dart';
import 'package:gen_confi/client/onboarding/style_preferences/style_preferences_screen.dart';
import 'package:gen_confi/client/onboarding/grooming_profile/grooming_profile_screen.dart';
import 'package:gen_confi/client/onboarding/finish/finish_screen.dart';
import 'package:gen_confi/client/onboarding/selfie/smart_selfie_screen.dart';
import 'package:gen_confi/features/smart_capture/ui/smart_face_capture_screen.dart';
import 'package:gen_confi/client/onboarding/user_type/user_type_screen.dart';
import 'package:gen_confi/client/onboarding/goal/goal_selection_screen.dart';

import 'package:gen_confi/client/home/client_home_dashboard.dart';
import 'package:gen_confi/client/layout/client_shell.dart';
import 'package:gen_confi/expert/home/expert_home_dashboard.dart';
import 'package:gen_confi/expert/onboarding/expert_onboarding_screen.dart';
import 'package:gen_confi/admin/dashboard/admin_dashboard.dart';
import 'package:gen_confi/client/profile/profile_screen.dart';
import 'package:gen_confi/client/profile/edit_profile_screen.dart';
import 'package:gen_confi/client/profile/style_profile_details_screen.dart';

import 'package:gen_confi/features/client/grooming/grooming_hub_screen.dart';
import 'package:gen_confi/features/client/grooming/routine_player_screen.dart';
import 'package:gen_confi/features/client/grooming/skin/skin_recommendations_screen.dart';
import 'package:gen_confi/features/client/grooming/history/grooming_history_screen.dart';
import 'package:gen_confi/features/client/grooming/skin_analysis_screen.dart';


class GenConfiApp extends StatelessWidget {
  const GenConfiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gen Confi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      // Simple map-based navigation for now, can be upgraded to onGenerateRoute later
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.roleSelection: (context) => const RoleSelectorScreen(),

        AppRoutes.genderModeSelection: (context) => const GenderModeScreen(),
        AppRoutes.bodyTypeSelection: (context) => const BodyTypeScreen(),
        AppRoutes.clientOnboardingStylePreferences: (context) =>
            const StylePreferencesScreen(),
        AppRoutes.clientOnboardingGroomingProfile: (context) =>
            const GroomingProfileScreen(),
        
        
        // Master Onboarding
        AppRoutes.onboardingSelfie: (context) => const SmartSelfieScreen(),
        AppRoutes.onboardingUserType: (context) => const UserTypeScreen(),
        AppRoutes.onboardingGoal: (context) => const GoalSelectionScreen(),
        
        // Smart Capture
        AppRoutes.smartFaceCapture: (context) => const SmartFaceCaptureScreen(),

        AppRoutes.clientOnboardingFinish: (context) => const FinishScreen(),
        AppRoutes.clientShell: (context) => const ClientShell(),
        AppRoutes.clientHome: (context) => ClientHomeDashboard(
              onNavigateToTab: (index) {
                debugPrint("Navigate to tab $index requested from standalone home");
              },
            ),
        AppRoutes.clientProfile: (context) => const ProfileScreen(),
        AppRoutes.clientProfileEdit: (context) => const EditProfileScreen(),
        AppRoutes.clientProfileStyleDetails: (context) =>
            const StyleProfileDetailsScreen(),

        AppRoutes.expertOnboarding: (context) => const ExpertOnboardingScreen(),
        AppRoutes.expertHome: (context) => const ExpertHomeDashboard(),
        AppRoutes.adminDashboard: (context) => const AdminDashboard(),

        // Grooming Routes
        AppRoutes.clientGroomingHub: (context) => const GroomingHubScreen(),
        AppRoutes.clientGroomingRoutine: (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return RoutinePlayerScreen(routineKey: args['routineKey']);
        },
        AppRoutes.clientGroomingSkin: (context) =>
            const SkinRecommendationsScreen(),
        AppRoutes.clientGroomingHistory: (context) =>
            const GroomingHistoryScreen(),
        AppRoutes.clientGroomingAnalysis: (context) =>
            const SkinAnalysisScreen(),
        AppRoutes.smartCapture: (context) => const SmartFaceCaptureScreen(),
      },
    );
  }
}

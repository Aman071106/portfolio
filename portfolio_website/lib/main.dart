import 'package:flutter/material.dart';
import 'package:portfolio_website/routes/router_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:portfolio_website/utils/constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Firebase connection test (Firestore)
  try {
    // print("here");
    // ProjectService service = ProjectService();
    // dynamic projects = await service.fetchProjects();
    // print(projects.toString());
  } catch (e) {
    // print("❌ Firebase connection failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        cardColor: AppColors.cardColor,
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.textPrimaryColor,
          displayColor: AppColors.textPrimaryColor,
        ),
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryColor,
          secondary: AppColors.accentColor,
          // ignore: deprecated_member_use
          background: AppColors.backgroundColor,
          surface: AppColors.cardColor,
        ),
      ),
      routerConfig: MyAppRouter.getRouter(),
    );
  }
}

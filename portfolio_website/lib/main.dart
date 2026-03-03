import 'package:flutter/material.dart';
import 'package:portfolio_website/routes/router_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:portfolio_website/utils/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Aman Gupta — Portfolio',
      theme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        cardColor: AppColors.cardColor,
        textTheme: baseTextTheme.apply(
          bodyColor: AppColors.textPrimaryColor,
          displayColor: AppColors.textPrimaryColor,
        ),
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryColor,
          secondary: AppColors.accentColor,
          surface: AppColors.surfaceColor,
        ),
      ),
      routerConfig: MyAppRouter.getRouter(),
    );
  }
}

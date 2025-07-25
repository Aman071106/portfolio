import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/navabar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      endDrawer: isDesktop ? null : NavDrawer(currentPath: '/'),
      body: Column(
        children: [
          NavBar(currentPath: '/'),
          Expanded(
            child: BlocProvider(
              create: (context) => HomeBloc()..add(LoadHomeData()),
              child: BlocConsumer<HomeBloc, HomeState>(
                listener: (context, state) {
                  if (state is HomeLoaded) {
                    if (state.formSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Message sent successfully!'),
                          backgroundColor: AppColors.accentColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusM),
                          ),
                        ),
                      );
                    } else if (state.formError.isNotEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${state.formError}'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                           shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusM),
                          ),
                        ),
                      );
                    }
                  }
                },
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  } else if (state is HomeLoaded) {
                    final homeData = state.homeData;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHeroSection(homeData, isDesktop, _launchUrl),
                          _buildContactSection(state, isDesktop, context),
                        ],
                      ),
                    );
                  } else if (state is HomeError) {
                    return Center(
                        child: Text('Failed to load home data: ${state.message}'));
                  } else {
                    return const Center(child: Text('Initial state'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Map<String, dynamic> homeData, bool isDesktop, Function(String) launchUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: .1),
            AppColors.backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical:
              isDesktop ? AppDimensions.paddingXXXL : AppDimensions.paddingXXL,
          horizontal: AppDimensions.paddingL,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  isDesktop
                      ? AppDimensions.maxContentWidthDesktop
                      : AppDimensions.maxContentWidthMobile,
            ),
            child: isDesktop ? _buildDesktopHero(homeData, launchUrl) : _buildMobileHero(homeData, launchUrl),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHero(Map<String, dynamic> homeData, Function(String) launchUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left content
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Hello, I'm",
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeL,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                homeData['name'],
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeXXL * 1.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingM,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusL,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: .3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  homeData['tagline'],
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeL,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLightColor,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              Text(
                homeData['intro'],
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeM,
                  height: 1.6,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              ElevatedButton(
                onPressed: () {
                  if (homeData['resumeUrl'] != null) {
                    launchUrl(homeData['resumeUrl']);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textLightColor,
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXL,
                    vertical: AppDimensions.paddingL,
                  ),
                  elevation: 5,
                  shadowColor: AppColors.primaryColor.withValues(alpha: .5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusL,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download_rounded),
                    const SizedBox(width: AppDimensions.paddingM),
                    Text(
                      "Download Resume",
                      style: TextStyle(
                        fontSize: AppDimensions.fontSizeM,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppDimensions.paddingXXL),

        // Right profile image
        Expanded(
          flex: 2,
          child: _buildProfileImage(homeData, 400),
        ),
      ],
    );
  }

  Widget _buildMobileHero(Map<String, dynamic> homeData, Function(String) launchUrl) {
    return Column(
      children: [
        // Profile image
        _buildProfileImage(homeData, AppDimensions.profileImageSizeMobile * 1.2),
        const SizedBox(height: AppDimensions.paddingXL),

        // Content
        Column(
          children: [
            Text(
              "Hello, I'm",
              style: TextStyle(
                fontSize: AppDimensions.fontSizeM,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXS),
            Text(
              homeData['name'],
              style: TextStyle(
                fontSize: AppDimensions.fontSizeXL * 1.2,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusL,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: .3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                homeData['tagline'],
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLightColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              homeData['intro'],
              style: TextStyle(
                fontSize: AppDimensions.fontSizeM,
                height: 1.6,
                color: AppColors.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            ElevatedButton(
              onPressed: () {
                if (homeData['resumeUrl'] != null) {
                  launchUrl(homeData['resumeUrl']);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.textLightColor,
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXL,
                  vertical: AppDimensions.paddingM,
                ),
                elevation: 5,
                shadowColor: AppColors.primaryColor.withValues(alpha: .5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusL,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.download_rounded),
                  const SizedBox(width: AppDimensions.paddingM),
                  Text(
                    "Download Resume",
                    style: TextStyle(
                      fontSize: AppDimensions.fontSizeM,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileImage(Map<String, dynamic> homeData, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.textLightColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: .4),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Hero(
          tag: 'profile-image',
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade800.withValues(alpha: 0.6),
                        Colors.blue.shade200.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Image.network(
                    homeData['profileImage'],
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                          color: AppColors.textLightColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.person,
                          size: size * 0.5,
                          color: AppColors.textLightColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Optional: Soft transparent circle on top for effect
              ClipOval(
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.blue.withValues(alpha: 0.1),
                      ],
                      center: Alignment.center,
                      radius: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(HomeLoaded state, bool isDesktop, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundColor,
            AppColors.primaryColor.withValues(alpha: .05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical:
              isDesktop ? AppDimensions.paddingXXXL : AppDimensions.paddingXXL,
          horizontal: AppDimensions.paddingL,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  isDesktop
                      ? AppDimensions.maxContentWidthDesktop
                      : AppDimensions.maxContentWidthMobile,
            ),
            child: Column(
              children: [
                // Section Title
                Text(
                  "Get In Touch",
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeXXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Container(
                  width: 80,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
                Text(
                  "Have a question or want to work together? Drop me a message!",
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeM,
                    color: AppColors.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingXXL),

                // Contact Form
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingXL),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusL,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .08),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: .1),
                      width: 1,
                    ),
                  ),
                  child: _buildContactForm(state, context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm(HomeLoaded state, BuildContext context) {
    return Form(
      // The form key is not strictly necessary with BLoC for validation
      // as validation can be done in the BLoC or using input decoration error text.
      // However, if you have complex form logic requiring a FormState,
      // you might still need a GlobalKey.
      // key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          _buildInputLabel("Name"),
          const SizedBox(height: AppDimensions.paddingXS),
          TextFormField(
            initialValue: state.name,
            onChanged: (value) => context.read<HomeBloc>().add(NameChanged(name: value)),
            decoration: _inputDecoration(
              "Enter your name",
              Icons.person_outline,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Email Field
          _buildInputLabel("Email"),
          const SizedBox(height: AppDimensions.paddingXS),
          TextFormField(
            initialValue: state.email,
             onChanged: (value) => context.read<HomeBloc>().add(EmailChanged(email: value)),
            decoration: _inputDecoration(
              "Enter your email",
              Icons.email_outlined,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Message Field
          _buildInputLabel("Message"),
          const SizedBox(height: AppDimensions.paddingXS),
          TextFormField(
             initialValue: state.message,
             onChanged: (value) => context.read<HomeBloc>().add(MessageChanged(message: value)),
            decoration: _inputDecoration(
              "Write your message here...",
              Icons.message_outlined,
            ),
            maxLines: 5,
          ),
          const SizedBox(height: AppDimensions.paddingXL),

          // Submit Button
          Center(
            child: SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: state.isSubmitting ? null : () => context.read<HomeBloc>().add(SubmitContactForm()),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textLightColor,
                  backgroundColor: AppColors.accentColor,
                  disabledForegroundColor: AppColors.textLightColor.withValues(
                    alpha: 0.6,
                  ),
                  disabledBackgroundColor: AppColors.accentColor.withValues(
                    alpha: 0.6,
                  ),
                  elevation: 5,
                  shadowColor: AppColors.accentColor.withValues(alpha: .5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusL,
                    ),
                  ),
                ),
                child:
                    state.isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.textLightColor,
                            strokeWidth: 2,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send_rounded),
                            const SizedBox(width: AppDimensions.paddingM),
                            Text(
                              "Send Message",
                              style: TextStyle(
                                fontSize: AppDimensions.fontSizeM,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
           if (state.formError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingM),
              child: Center(
                child: Text(
                  state.formError,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: AppDimensions.fontSizeM,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primaryColor),
      filled: true,
      fillColor: AppColors.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        borderSide: BorderSide(
          color: AppColors.primaryColor.withValues(alpha: .1),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}

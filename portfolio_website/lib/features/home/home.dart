import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/navabar.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? homeData;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Load home.json
      final homeString = await rootBundle.loadString('assets/data/home.json');
      final homeJson = jsonDecode(homeString);

      setState(() {
        homeData = homeJson;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      log('Error loading home data: $e');
      // If home.json doesn't exist, create default data
      setState(() {
        homeData = {
          "name": "Aman Gupta",
          "tagline": "AI/ML and Flutter App developer",
          "intro":
              "Building beautiful cross-platform applications with Flutter and exploring the frontiers of AI.",
          "resumeUrl": "#",
          "profileImage":
              "https://raw.githubusercontent.com/Aman071106/IITApp/main2/ContributorImages/profilePicAman.jpg",
        };
        isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _submitContactForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate form submission
      await Future.delayed(const Duration(seconds: 2));

      // Reset form
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();

      setState(() {
        _isSubmitting = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message sent successfully!'),
            backgroundColor: AppColors.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
            ),
          ),
        );
      }
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
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                    : homeData == null
                    ? const Center(child: Text('Failed to load data'))
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHeroSection(isDesktop),
                          _buildContactSection(isDesktop),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop) {
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
            child: isDesktop ? _buildDesktopHero() : _buildMobileHero(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHero() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left content
        Expanded(
          flex: 3,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: child,
                ),
              );
            },
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
                  homeData!['name'],
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
                    homeData!['tagline'],
                    style: TextStyle(
                      fontSize: AppDimensions.fontSizeL,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLightColor,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                Text(
                  homeData!['intro'],
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeM,
                    height: 1.6,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                ElevatedButton(
                  onPressed: () {
                    if (homeData!['resumeUrl'] != null) {
                      _launchUrl(homeData!['resumeUrl']);
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
        ),

        const SizedBox(width: AppDimensions.paddingXXL),

        // Right profile image
        Expanded(
          flex: 2,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(_slideAnimation.value * -1, 0),
                  child: child,
                ),
              );
            },
            child: _buildProfileImage(400),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHero() {
    return Column(
      children: [
        // Profile image
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(opacity: _fadeAnimation.value, child: child);
          },
          child: _buildProfileImage(AppDimensions.profileImageSizeMobile * 1.2),
        ),
        const SizedBox(height: AppDimensions.paddingXL),

        // Content
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              ),
            );
          },
          child: Column(
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
                homeData!['name'],
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
                  homeData!['tagline'],
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
                homeData!['intro'],
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
                  if (homeData!['resumeUrl'] != null) {
                    _launchUrl(homeData!['resumeUrl']);
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
        ),
      ],
    );
  }

  Widget _buildProfileImage(double size) {
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
                    "https://raw.githubusercontent.com/Aman071106/IITApp/main2/ContributorImages/profilePicAman.jpg",
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

  Widget _buildContactSection(bool isDesktop) {
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
                  child: _buildContactForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          _buildInputLabel("Name"),
          const SizedBox(height: AppDimensions.paddingXS),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration(
              "Enter your name",
              Icons.person_outline,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Email Field
          _buildInputLabel("Email"),
          const SizedBox(height: AppDimensions.paddingXS),
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration(
              "Enter your email",
              Icons.email_outlined,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Message Field
          _buildInputLabel("Message"),
          const SizedBox(height: AppDimensions.paddingXS),
          TextFormField(
            controller: _messageController,
            decoration: _inputDecoration(
              "Write your message here...",
              Icons.message_outlined,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your message';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.paddingXL),

          // Submit Button
          Center(
            child: SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitContactForm,
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
                    _isSubmitting
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


// Send message button implementation
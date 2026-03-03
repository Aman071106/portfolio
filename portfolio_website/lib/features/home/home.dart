import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
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
      final homeString = await rootBundle.loadString('assets/data/home.json');
      final homeJson = jsonDecode(homeString);
      setState(() {
        homeData = homeJson;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      log('Error loading home data: $e');
      setState(() {
        homeData = {
          "name": "Aman Gupta",
          "tagline": "AI/ML & Deep Learning Engineer",
          "intro": "Building AI-powered systems.",
          "resumeUrl": "#",
          "profileImage": "assets/profile.jpeg",
        };
        isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> _launchUrl(String url, {bool newTab = false}) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, webOnlyWindowName: newTab ? '_blank' : '_self')) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _submitContactForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      await Future.delayed(const Duration(seconds: 2));
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Message sent successfully!',
              style: GoogleFonts.inter(),
            ),
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
      drawer: isDesktop ? null : NavDrawer(currentPath: '/'),
      body: Column(
        children: [
          NavBar(currentPath: '/'),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentColor,
                        strokeWidth: 2,
                      ),
                    )
                    : homeData == null
                    ? const Center(child: Text('Failed to load data'))
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHeroSection(isDesktop, screenSize),
                          _buildStatsBar(isDesktop),
                          _buildContactSection(isDesktop),
                          _buildFooter(),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop, Size screenSize) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: screenSize.height - AppDimensions.navBarHeight,
      ),
      color: AppColors.backgroundColor,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical:
              isDesktop ? AppDimensions.paddingHero : AppDimensions.paddingXXL,
          horizontal: AppDimensions.paddingXL,
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
    return AnimatedBuilder(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hello, I'm",
                  style: GoogleFonts.inter(
                    fontSize: AppDimensions.fontSizeL,
                    color: AppColors.textSecondaryColor,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Text(
                  homeData!['name'],
                  style: GoogleFonts.spaceMono(
                    fontSize: AppDimensions.fontSizeHero,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                    height: 1.1,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingM,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accentColor, width: 1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusCircular,
                    ),
                  ),
                  child: Text(
                    homeData!['tagline'],
                    style: GoogleFonts.inter(
                      fontSize: AppDimensions.fontSizeM,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                Text(
                  homeData!['intro'],
                  style: GoogleFonts.inter(
                    fontSize: AppDimensions.fontSizeM,
                    height: 1.7,
                    color: AppColors.textSecondaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                Row(
                  children: [
                    _buildHeroButton(
                      "Download Resume",
                      Icons.download_rounded,
                      true,
                      () {
                        if (homeData!['resumeUrl'] != null) {
                          _launchUrl(homeData!['resumeUrl'], newTab: true);
                        }
                      },
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    _buildHeroButton(
                      "View Projects",
                      Icons.arrow_forward_rounded,
                      false,
                      () => context.go('/projects'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.paddingXXXL),
          _buildProfileImage(300),
        ],
      ),
    );
  }

  Widget _buildMobileHero() {
    return AnimatedBuilder(
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
          _buildProfileImage(180),
          const SizedBox(height: AppDimensions.paddingXL),
          Text(
            "Hello, I'm",
            style: GoogleFonts.inter(
              fontSize: AppDimensions.fontSizeM,
              color: AppColors.textSecondaryColor,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Text(
            homeData!['name'],
            style: GoogleFonts.spaceMono(
              fontSize: AppDimensions.fontSizeXXL * 1.2,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accentColor, width: 1),
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusCircular,
              ),
            ),
            child: Text(
              homeData!['tagline'],
              style: GoogleFonts.inter(
                fontSize: AppDimensions.fontSizeS,
                fontWeight: FontWeight.w500,
                color: AppColors.accentColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            homeData!['intro'],
            style: GoogleFonts.inter(
              fontSize: AppDimensions.fontSizeM,
              height: 1.7,
              color: AppColors.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildHeroButton("Download Resume", Icons.download_rounded, true, () {
            if (homeData!['resumeUrl'] != null) {
              _launchUrl(homeData!['resumeUrl'], newTab: true);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildHeroButton(
    String label,
    IconData icon,
    bool filled,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXL,
          vertical: AppDimensions.paddingM,
        ),
        decoration: BoxDecoration(
          color: filled ? AppColors.accentColor : Colors.transparent,
          border: Border.all(
            color: filled ? AppColors.accentColor : AppColors.borderColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(
            AppDimensions.borderRadiusCircular,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  filled
                      ? AppColors.backgroundColor
                      : AppColors.textSecondaryColor,
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppDimensions.fontSizeS,
                fontWeight: FontWeight.w600,
                color:
                    filled
                        ? AppColors.backgroundColor
                        : AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accentColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            homeData!['profileImage'] ?? 'assets/profile.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.surfaceColor,
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: size * 0.4,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar(bool isDesktop) {
    final stats = [
      {'value': '4', 'label': 'OSS Orgs'},
      {'value': '14+', 'label': 'Merged PRs'},
      {'value': '2', 'label': 'Hackathon Wins'},
      {'value': '1500+', 'label': 'CF Rating'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXL),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderColor, width: 1),
          bottom: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                isDesktop
                    ? AppDimensions.maxContentWidthDesktop
                    : AppDimensions.maxContentWidthMobile,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing:
                isDesktop ? AppDimensions.paddingXXXL : AppDimensions.paddingXL,
            runSpacing: AppDimensions.paddingL,
            children:
                stats.map((stat) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stat['value']!,
                        style: GoogleFonts.spaceMono(
                          fontSize:
                              isDesktop
                                  ? AppDimensions.fontSizeXXL
                                  : AppDimensions.fontSizeXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentColor,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        stat['label']!,
                        style: GoogleFonts.inter(
                          fontSize: AppDimensions.fontSizeS,
                          color: AppColors.textSecondaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical:
            isDesktop ? AppDimensions.paddingXXXL : AppDimensions.paddingXXL,
        horizontal: AppDimensions.paddingXL,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 700 : AppDimensions.maxContentWidthMobile,
          ),
          child: Column(
            children: [
              Text(
                "Get In Touch",
                style: GoogleFonts.spaceMono(
                  fontSize: AppDimensions.fontSizeXXL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Container(width: 60, height: 2, color: AppColors.accentColor),
              const SizedBox(height: AppDimensions.paddingL),
              Text(
                "Have a question or want to work together?",
                style: GoogleFonts.inter(
                  fontSize: AppDimensions.fontSizeM,
                  color: AppColors.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXXL),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingXL),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusL,
                  ),
                  border: Border.all(color: AppColors.borderColor, width: 1),
                ),
                child: _buildContactForm(),
              ),
            ],
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
          _buildInputLabel("Name"),
          const SizedBox(height: AppDimensions.paddingXS),
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.inter(color: AppColors.textPrimaryColor),
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
          _buildInputLabel("Email"),
          const SizedBox(height: AppDimensions.paddingXS),
          TextFormField(
            controller: _emailController,
            style: GoogleFonts.inter(color: AppColors.textPrimaryColor),
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
          _buildInputLabel("Message"),
          const SizedBox(height: AppDimensions.paddingXS),
          TextFormField(
            controller: _messageController,
            style: GoogleFonts.inter(color: AppColors.textPrimaryColor),
            decoration: _inputDecoration(
              "Write your message...",
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
          Center(
            child: InkWell(
              onTap: _isSubmitting ? null : _submitContactForm,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusCircular,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXXL,
                  vertical: AppDimensions.paddingM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusCircular,
                  ),
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.backgroundColor,
                            strokeWidth: 2,
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.send_rounded,
                              size: 18,
                              color: AppColors.backgroundColor,
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            Text(
                              "Send Message",
                              style: GoogleFonts.inter(
                                fontSize: AppDimensions.fontSizeM,
                                fontWeight: FontWeight.w600,
                                color: AppColors.backgroundColor,
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
      style: GoogleFonts.inter(
        fontSize: AppDimensions.fontSizeS,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: AppColors.textMutedColor,
        fontSize: AppDimensions.fontSizeM,
      ),
      prefixIcon: Icon(icon, color: AppColors.textMutedColor, size: 20),
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        borderSide: BorderSide(color: AppColors.accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXL),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 1)),
      ),
      child: Center(
        child: Text(
          "© 2025 Aman Gupta. Built with Flutter.",
          style: GoogleFonts.inter(
            fontSize: AppDimensions.fontSizeS,
            color: AppColors.textMutedColor,
          ),
        ),
      ),
    );
  }
}

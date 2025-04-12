import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/strings.dart';
import '../../widgets/navabar.dart';
import 'package:url_launcher/url_launcher.dart';

// Enhanced About Page
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? aboutData;
  Map<String, dynamic>? skillsData;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Load about.json
      final aboutString = await rootBundle.loadString('assets/data/about.json');
      final aboutJson = jsonDecode(aboutString);

      // Load skills.json
      final skillsString = await rootBundle.loadString(
        'assets/data/skills.json',
      );
      final skillsJson = jsonDecode(skillsString);

      setState(() {
        aboutData = aboutJson;
        skillsData = skillsJson;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      log('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      endDrawer: isDesktop ? null : NavDrawer(currentPath: '/about'),
      body: Column(
        children: [
          NavBar(currentPath: '/about'),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                    : aboutData == null || skillsData == null
                    ? const Center(child: Text('Failed to load data'))
                    : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    isDesktop
                                        ? AppDimensions.maxContentWidthDesktop
                                        : AppDimensions.maxContentWidthMobile,
                              ),
                              child:
                                  isDesktop
                                      ? _buildDesktopLayout()
                                      : _buildMobileLayout(),
                            ),
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page title with animated underline
        Center(
          child: Column(
            children: [
              Text(
                "About Me",
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeXXL * 1.2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Container(
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXXL),
        // About section with profile in a row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image with animations
            _buildProfileImage(AppDimensions.profileImageSizeDesktop),
            const SizedBox(width: AppDimensions.paddingXL),
            // Bio information
            Expanded(child: _buildBioSection()),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingXXL),
        // Skills section with card layout
        _buildSkillsSection(isDesktop: true),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Page title with animated underline
        Column(
          children: [
            Text(
              "About Me",
              style: TextStyle(
                fontSize: AppDimensions.fontSizeXL,
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
          ],
        ),
        const SizedBox(height: AppDimensions.paddingXL),
        // Profile image centered with animations
        _buildProfileImage(AppDimensions.profileImageSizeMobile),
        const SizedBox(height: AppDimensions.paddingL),
        // Bio information
        _buildBioSection(),
        const SizedBox(height: AppDimensions.paddingXL),
        // Skills section with card layout
        _buildSkillsSection(isDesktop: false),
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
          colors: [AppColors.primaryColor, AppColors.accentColor],
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
        child: ClipOval(
          child: Image.network(
            aboutData!['profileImage'],
            fit: BoxFit.cover,
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
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          aboutData!['name'],
          style: TextStyle(
            fontSize: AppDimensions.fontSizeXXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        Text(
          aboutData!['displayName'],
          style: TextStyle(
            fontSize: AppDimensions.fontSizeL,
            fontWeight: FontWeight.w500,
            color: AppColors.accentColor,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: .3),
            ),
          ),
          child: Text(
            aboutData!['title'] ?? '',
            style: TextStyle(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            aboutData!['bio'] ?? '',
            style: TextStyle(
              fontSize: AppDimensions.fontSizeM,
              color: AppColors.textSecondaryColor,
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        _buildContactInfo(),
        const SizedBox(height: AppDimensions.paddingL),
        _buildSocialLinks(),
        const SizedBox(height: AppDimensions.paddingL),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Me",
            style: TextStyle(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          // Location
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusS,
                  ),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Text(
                  '${MyAppStrings.locationLabel}: ${aboutData!['location'] ?? ''}',
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeM,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          // Email
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusS,
                  ),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Text(
                  '${MyAppStrings.emailLabel}: ${aboutData!['email'] ?? ''}',
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeM,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MyAppStrings.socialsLabel,
            style: TextStyle(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (aboutData!['socials']?['github'] != null)
                  _buildSocialButton(
                    icon: aboutData!['socials']['github']['icon'],
                    label: MyAppStrings.githubLabel,
                    url: aboutData!['socials']['github']['url'],
                  ),
                const SizedBox(width: AppDimensions.paddingM),
                if (aboutData!['socials']?['linkedin'] != null)
                  _buildSocialButton(
                    icon: aboutData!['socials']['linkedin']['icon'],
                    label: MyAppStrings.linkedinLabel,
                    url: aboutData!['socials']['linkedin']['url'],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required String url,
  }) {
    return InkWell(
      onTap: () {
        _launchUrl(url);
      },
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryColor, AppColors.primaryDarkColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: .3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusS),
              child: Image.network(
                icon,
                width: AppDimensions.socialIconSize,
                height: AppDimensions.socialIconSize,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: AppDimensions.socialIconSize,
                    height: AppDimensions.socialIconSize,
                    color: Colors.white,
                    child: const Icon(Icons.image_not_supported, size: 16),
                  );
                },
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Text(
              label,
              style: TextStyle(
                fontSize: AppDimensions.fontSizeS,
                fontWeight: FontWeight.w500,
                color: AppColors.textLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Download CV logic
            if (aboutData!['cvUrl'] != null) {
              _launchUrl(aboutData!['cvUrl']);
            }
          },
          icon: const Icon(Icons.download_rounded),
          label: Text(MyAppStrings.downloadCVButton),
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.textLightColor,
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            elevation: 5,
            shadowColor: AppColors.primaryColor.withValues(alpha: .5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
      ],
    );
  }

  Widget _buildSkillsSection({required bool isDesktop}) {
    final skills = skillsData!['skills'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                MyAppStrings.skillsTitle,
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeXL,
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
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXL),
        ...skills.map((category) => _buildSkillCategory(category, isDesktop)),
      ],
    );
  }

  Widget _buildSkillCategory(Map<String, dynamic> category, bool isDesktop) {
    final items = category['items'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingL),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryColor, AppColors.accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: .3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            category['category'],
            style: TextStyle(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.bold,
              color: AppColors.textLightColor,
            ),
          ),
        ),
        isDesktop
            ? Wrap(
              spacing: AppDimensions.paddingL,
              runSpacing: AppDimensions.paddingL,
              children:
                  items.map<Widget>((item) => _buildSkillItem(item)).toList(),
            )
            : Column(
              children:
                  items
                      .map<Widget>(
                        (item) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingL,
                          ),
                          child: _buildSkillItem(item),
                        ),
                      )
                      .toList(),
            ),
        const SizedBox(height: AppDimensions.paddingXL),
      ],
    );
  }

  Widget _buildSkillItem(Map<String, dynamic> item) {
    return Container(
      width: AppDimensions.skillCardWidth,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.skillItemBackground,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: .1),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: .05),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
            ),
            child: Image.network(
              item['logo'],
              width: AppDimensions.skillIconSize,
              height: AppDimensions.skillIconSize,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: AppDimensions.skillIconSize,
                  height: AppDimensions.skillIconSize,
                  color: AppColors.cardBackground,
                  child: const Icon(Icons.code, color: AppColors.primaryColor),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            item['name'],
            style: TextStyle(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryAccentColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


// -hire button
// -download cv button
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/navabar.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final aboutString = await rootBundle.loadString('assets/data/about.json');
      final skillsString = await rootBundle.loadString(
        'assets/data/skills.json',
      );
      setState(() {
        aboutData = jsonDecode(aboutString);
        skillsData = jsonDecode(skillsString);
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      log('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _launchUrl(String url, {bool newTab = false}) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, webOnlyWindowName: newTab ? '_blank' : '_self')) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: isDesktop ? null : NavDrawer(currentPath: '/about'),
      body: Column(
        children: [
          NavBar(currentPath: '/about'),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentColor,
                        strokeWidth: 2,
                      ),
                    )
                    : aboutData == null || skillsData == null
                    ? const Center(child: Text('Failed to load data'))
                    : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingXL,
                            vertical:
                                isDesktop
                                    ? AppDimensions.paddingXXL
                                    : AppDimensions.paddingL,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXXL,
                                  ),
                                  isDesktop
                                      ? _buildDesktopBio()
                                      : _buildMobileBio(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXXXL,
                                  ),
                                  _buildPORsSection(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXXXL,
                                  ),
                                  _buildAchievementsSection(isDesktop),
                                  const SizedBox(
                                    height: AppDimensions.paddingXXXL,
                                  ),
                                  _buildSkillsSection(isDesktop),
                                  const SizedBox(
                                    height: AppDimensions.paddingXXL,
                                  ),
                                ],
                              ),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About Me",
          style: GoogleFonts.spaceMono(
            fontSize: AppDimensions.fontSizeXXL * 1.2,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Container(width: 60, height: 2, color: AppColors.accentColor),
      ],
    );
  }

  Widget _buildDesktopBio() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileImage(AppDimensions.profileImageSizeDesktop),
        const SizedBox(width: AppDimensions.paddingXXL),
        Expanded(child: _buildBioContent()),
      ],
    );
  }

  Widget _buildMobileBio() {
    return Column(
      children: [
        _buildProfileImage(AppDimensions.profileImageSizeMobile),
        const SizedBox(height: AppDimensions.paddingXL),
        _buildBioContent(),
      ],
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
            aboutData!['profileImage'] ?? 'assets/profile.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.surfaceColor,
                child: Icon(
                  Icons.person,
                  size: size * 0.4,
                  color: AppColors.textSecondaryColor,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBioContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          aboutData!['name'] ?? '',
          style: GoogleFonts.spaceMono(
            fontSize: AppDimensions.fontSizeXXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        Text(
          aboutData!['displayName'] ?? '',
          style: GoogleFonts.spaceMono(
            fontSize: AppDimensions.fontSizeL,
            fontWeight: FontWeight.w400,
            color: AppColors.accentColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusCircular,
            ),
          ),
          child: Text(
            aboutData!['title'] ?? '',
            style: GoogleFonts.inter(
              fontSize: AppDimensions.fontSizeS,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryColor,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        Text(
          aboutData!['bio'] ?? '',
          style: GoogleFonts.inter(
            fontSize: AppDimensions.fontSizeM,
            color: AppColors.textSecondaryColor,
            height: 1.7,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXL),
        _buildContactInfo(),
        const SizedBox(height: AppDimensions.paddingL),
        _buildSocialLinks(),
        const SizedBox(height: AppDimensions.paddingL),
        _buildCVButton(),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.location_on_outlined, aboutData!['location'] ?? ''),
        const SizedBox(height: AppDimensions.paddingM),
        _buildInfoRow(Icons.email_outlined, aboutData!['email'] ?? ''),
        if (aboutData!['phone'] != null) ...[
          const SizedBox(height: AppDimensions.paddingM),
          _buildInfoRow(Icons.phone_outlined, aboutData!['phone']),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accentColor),
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: AppDimensions.fontSizeM,
              color: AppColors.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinks() {
    final socials = aboutData!['socials'] as Map<String, dynamic>? ?? {};
    return Wrap(
      spacing: AppDimensions.paddingM,
      runSpacing: AppDimensions.paddingM,
      children:
          socials.entries.map((entry) {
            final social = entry.value as Map<String, dynamic>;
            return InkWell(
              onTap: () => _launchUrl(social['url']),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusM,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusS,
                      ),
                      child: Image.network(
                        social['icon'] ?? '',
                        width: 20,
                        height: 20,
                        errorBuilder:
                            (c, e, s) => const Icon(
                              Icons.link,
                              size: 20,
                              color: AppColors.textSecondaryColor,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    Text(
                      entry.key.substring(0, 1).toUpperCase() +
                          entry.key.substring(1),
                      style: GoogleFonts.inter(
                        fontSize: AppDimensions.fontSizeS,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCVButton() {
    return InkWell(
      onTap: () {
        if (aboutData!['cvUrl'] != null) _launchUrl(aboutData!['cvUrl']);
      },
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXL,
          vertical: AppDimensions.paddingM,
        ),
        decoration: BoxDecoration(
          color: AppColors.accentColor,
          borderRadius: BorderRadius.circular(
            AppDimensions.borderRadiusCircular,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.download_rounded,
              size: 18,
              color: AppColors.backgroundColor,
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Text(
              "Download CV",
              style: GoogleFonts.inter(
                fontSize: AppDimensions.fontSizeS,
                fontWeight: FontWeight.w600,
                color: AppColors.backgroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPORsSection() {
    final pors = aboutData!['pors'] as List<dynamic>? ?? [];
    if (pors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Positions of Responsibility"),
        const SizedBox(height: AppDimensions.paddingXL),
        ...pors.map(
          (por) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentColor,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Text(
                    por,
                    style: GoogleFonts.inter(
                      fontSize: AppDimensions.fontSizeM,
                      color: AppColors.textSecondaryColor,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(bool isDesktop) {
    final achievements = aboutData!['achievements'] as List<dynamic>? ?? [];
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Achievements"),
        const SizedBox(height: AppDimensions.paddingXL),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : 1,
            crossAxisSpacing: AppDimensions.paddingL,
            mainAxisSpacing: AppDimensions.paddingL,
            childAspectRatio: isDesktop ? 1.6 : 2.2,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementCard(achievement);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final hasImage = achievement['image'] != null;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        border: Border.all(color: AppColors.borderColor),
        color: AppColors.surfaceColor,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            Image.asset(
              achievement['image'],
              fit: BoxFit.cover,
              errorBuilder:
                  (c, e, s) => Container(color: AppColors.surfaceColor),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: hasImage ? 0.7 : 0.0),
                  Colors.black.withValues(alpha: hasImage ? 0.9 : 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                Text(
                  achievement['subtitle'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: AppDimensions.fontSizeS,
                    color: AppColors.textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(bool isDesktop) {
    final skills = skillsData!['skills'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Skills & Tools"),
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
        Text(
          category['category'],
          style: GoogleFonts.spaceMono(
            fontSize: AppDimensions.fontSizeM,
            fontWeight: FontWeight.w700,
            color: AppColors.accentColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Wrap(
          spacing: AppDimensions.paddingM,
          runSpacing: AppDimensions.paddingM,
          children: items.map<Widget>((item) => _buildSkillChip(item)).toList(),
        ),
        const SizedBox(height: AppDimensions.paddingXL),
      ],
    );
  }

  Widget _buildSkillChip(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        color: AppColors.surfaceColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusS),
            child: Image.network(
              item['logo'] ?? '',
              width: 22,
              height: 22,
              errorBuilder:
                  (c, e, s) => const Icon(
                    Icons.code,
                    size: 22,
                    color: AppColors.textSecondaryColor,
                  ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Text(
            item['name'],
            style: GoogleFonts.inter(
              fontSize: AppDimensions.fontSizeS,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceMono(
            fontSize: AppDimensions.fontSizeXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Container(width: 40, height: 2, color: AppColors.accentColor),
      ],
    );
  }
}

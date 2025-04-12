import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/navabar.dart';

class ExperiencePage extends StatefulWidget {
  const ExperiencePage({super.key});

  @override
  createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage>
    with SingleTickerProviderStateMixin {
  List<dynamic>? experienceData;
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
      // Load experience.json
      final experienceString = await rootBundle.loadString(
        'assets/data/experience.json',
      );
      final experienceJson = jsonDecode(experienceString);

      setState(() {
        experienceData = experienceJson;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      log('Error loading experience data: $e');
      setState(() {
        isLoading = false;
      });
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
      endDrawer: isDesktop ? null : NavDrawer(currentPath: '/experience'),
      body: Column(
        children: [
          NavBar(currentPath: '/experience'),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                    : experienceData == null
                    ? const Center(
                      child: Text('Failed to load experience data'),
                    )
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
                              child: _buildExperienceContent(isDesktop),
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

  Widget _buildExperienceContent(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Page title with animated underline
        _buildPageTitle(),
        const SizedBox(height: AppDimensions.paddingXXL),

        // Experience timeline
        _buildExperienceTimeline(isDesktop),
      ],
    );
  }

  Widget _buildPageTitle() {
    return Column(
      children: [
        Text(
          "My Experience",
          style: TextStyle(
            fontSize: AppDimensions.fontSizeXXL * 1.2,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Container(
          width: 120,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceTimeline(bool isDesktop) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: experienceData!.length,
      itemBuilder: (context, index) {
        final experience = experienceData![index];
        // Create staggered animation effect
        final staggeredDelay = Duration(milliseconds: 200 * index);
        Future.delayed(staggeredDelay, () {
          if (mounted) setState(() {});
        });

        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingXL),
          child: _buildExperienceCard(experience, index, isDesktop),
        );
      },
    );
  }

  Widget _buildExperienceCard(
    Map<String, dynamic> experience,
    int index,
    bool isDesktop,
  ) {
    final isEven = index % 2 == 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
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
      child: Column(
        children: [
          // Header with company and duration
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isEven ? AppColors.primaryColor : AppColors.accentColor,
                  isEven ? AppColors.accentColor : AppColors.primaryDarkColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.borderRadiusL),
                topRight: Radius.circular(AppDimensions.borderRadiusL),
              ),
            ),
            child:
                isDesktop
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            experience['company'],
                            style: TextStyle(
                              fontSize: AppDimensions.fontSizeL,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLightColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusL,
                            ),
                          ),
                          child: Text(
                            experience['duration'],
                            style: TextStyle(
                              fontSize: AppDimensions.fontSizeS,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textLightColor,
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          experience['company'],
                          style: TextStyle(
                            fontSize: AppDimensions.fontSizeL,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLightColor,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusL,
                            ),
                          ),
                          child: Text(
                            experience['duration'],
                            style: TextStyle(
                              fontSize: AppDimensions.fontSizeS,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textLightColor,
                            ),
                          ),
                        ),
                      ],
                    ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Position and location
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
                      child: Icon(
                        Icons.work_outline,
                        color:
                            isEven
                                ? AppColors.primaryColor
                                : AppColors.accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Text(
                        experience['position'],
                        style: TextStyle(
                          fontSize: AppDimensions.fontSizeM,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingM),
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
                      child: Icon(
                        Icons.location_on_outlined,
                        color:
                            isEven
                                ? AppColors.primaryColor
                                : AppColors.accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Text(
                        experience['location'],
                        style: TextStyle(
                          fontSize: AppDimensions.fontSizeM,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Description
                Text(
                  "Responsibilities:",
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),

                ..._buildDescriptionItems(experience['description'], isEven),

                const SizedBox(height: AppDimensions.paddingL),

                // Technologies
                Text(
                  "Technologies:",
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                _buildTechnologiesList(experience['technologies'], isEven),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDescriptionItems(List<dynamic> descriptions, bool isEven) {
    return descriptions.map<Widget>((description) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEven ? AppColors.primaryColor : AppColors.accentColor,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeM,
                  color: AppColors.textSecondaryColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildTechnologiesList(List<dynamic> technologies, bool isEven) {
    return Wrap(
      spacing: AppDimensions.paddingM,
      runSpacing: AppDimensions.paddingM,
      children:
          technologies.map<Widget>((tech) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingXS,
              ),
              decoration: BoxDecoration(
                color: (isEven ? AppColors.primaryColor : AppColors.accentColor)
                    .withValues(alpha: .1),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusM,
                ),
                border: Border.all(
                  color: (isEven
                          ? AppColors.primaryColor
                          : AppColors.accentColor)
                      .withValues(alpha: .3),
                  width: 1,
                ),
              ),
              child: Text(
                tech,
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeS,
                  fontWeight: FontWeight.w500,
                  color:
                      isEven ? AppColors.primaryColor : AppColors.accentColor,
                ),
              ),
            );
          }).toList(),
    );
  }
}

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
      final experienceString = await rootBundle.loadString(
        'assets/data/experience.json',
      );
      setState(() {
        experienceData = jsonDecode(experienceString);
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      log('Error loading experience data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: isDesktop ? null : NavDrawer(currentPath: '/experiences'),
      body: Column(
        children: [
          NavBar(currentPath: '/experiences'),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentColor,
                        strokeWidth: 2,
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
                                  _buildTimeline(isDesktop),
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
          "Experience",
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

  Widget _buildTimeline(bool isDesktop) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: experienceData!.length,
      itemBuilder: (context, index) {
        final experience = experienceData![index];
        final isLast = index == experienceData!.length - 1;
        return _buildTimelineItem(experience, index, isLast, isDesktop);
      },
    );
  }

  Widget _buildTimelineItem(
    Map<String, dynamic> experience,
    int index,
    bool isLast,
    bool isDesktop,
  ) {
    final hasLogo =
        experience['logoUrl'] != null &&
        experience['logoUrl'].toString().isNotEmpty;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        index == 0
                            ? AppColors.accentColor
                            : AppColors.surfaceColor,
                    border: Border.all(
                      color:
                          index == 0
                              ? AppColors.accentColor
                              : AppColors.borderColor,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 1, color: AppColors.borderColor),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          // Card content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingXL),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingXL),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusL,
                  ),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo + Company + Duration
                    Row(
                      children: [
                        if (hasLogo)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: AppDimensions.paddingM,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusM,
                              ),
                              child: Image.asset(
                                experience['logoUrl'],
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (c, e, s) => Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.cardBackground,
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.borderRadiusM,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.work_outline,
                                        size: 20,
                                        color: AppColors.textSecondaryColor,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Wrap(
                            spacing: AppDimensions.paddingM,
                            runSpacing: AppDimensions.paddingS,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                experience['company'],
                                style: GoogleFonts.spaceMono(
                                  fontSize:
                                      isDesktop
                                          ? AppDimensions.fontSizeL
                                          : AppDimensions.fontSizeM,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingM,
                                  vertical: AppDimensions.paddingXS,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.borderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusCircular,
                                  ),
                                ),
                                child: Text(
                                  experience['duration'],
                                  style: GoogleFonts.inter(
                                    fontSize: AppDimensions.fontSizeXS,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    // Position
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 16,
                          color: AppColors.accentColor,
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: Text(
                            experience['position'],
                            style: GoogleFonts.inter(
                              fontSize: AppDimensions.fontSizeM,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textMutedColor,
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Text(
                          experience['location'],
                          style: GoogleFonts.inter(
                            fontSize: AppDimensions.fontSizeS,
                            color: AppColors.textMutedColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    // Description bullets
                    ...((experience['description'] as List<dynamic>).map(
                      (desc) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingM,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 7),
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingM),
                            Expanded(
                              child: Text(
                                desc,
                                style: GoogleFonts.inter(
                                  fontSize: AppDimensions.fontSizeS,
                                  color: AppColors.textSecondaryColor,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: AppDimensions.paddingS),
                    // Tech tags
                    Wrap(
                      spacing: AppDimensions.paddingS,
                      runSpacing: AppDimensions.paddingS,
                      children:
                          ((experience['technologies'] as List<dynamic>)
                              .map<Widget>(
                                (tech) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingM,
                                    vertical: AppDimensions.paddingXS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentColor.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.borderRadiusCircular,
                                    ),
                                    border: Border.all(
                                      color: AppColors.accentColor.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    tech,
                                    style: GoogleFonts.inter(
                                      fontSize: AppDimensions.fontSizeXS,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.accentColor,
                                    ),
                                  ),
                                ),
                              )
                              .toList()),
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
}

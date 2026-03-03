import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio_website/features/projects/project_model.dart';
import 'package:portfolio_website/features/projects/project_service.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/navabar.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage>
    with SingleTickerProviderStateMixin {
  Map<String, List<Project>>? projectsData;
  bool isLoading = true;
  String selectedTab = 'major';
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
      final service = ProjectService();
      final data = await service.fetchProjects();
      setState(() {
        projectsData = data;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      log('Error loading projects: $e');
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
      drawer: isDesktop ? null : NavDrawer(currentPath: '/projects'),
      body: Column(
        children: [
          NavBar(currentPath: '/projects'),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentColor,
                        strokeWidth: 2,
                      ),
                    )
                    : projectsData == null
                    ? const Center(child: Text('Failed to load projects'))
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
                                    height: AppDimensions.paddingXL,
                                  ),
                                  _buildTabSelector(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXXL,
                                  ),
                                  selectedTab == 'major'
                                      ? _buildMajorProjects(isDesktop)
                                      : _buildLearningProjects(isDesktop),
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
          "Projects",
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

  Widget _buildTabSelector() {
    return Row(
      children: [
        Expanded(child: _buildTab('Major Projects', 'major')),
        const SizedBox(width: AppDimensions.paddingS),
        Expanded(child: _buildTab('Learning Projects', 'learning')),
      ],
    );
  }

  Widget _buildTab(String label, String tab) {
    final isActive = selectedTab == tab;
    return InkWell(
      onTap: () => setState(() => selectedTab = tab),
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingM,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentColor : Colors.transparent,
          border: Border.all(
            color: isActive ? AppColors.accentColor : AppColors.borderColor,
          ),
          borderRadius: BorderRadius.circular(
            AppDimensions.borderRadiusCircular,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppDimensions.fontSizeS,
            fontWeight: FontWeight.w600,
            color:
                isActive
                    ? AppColors.backgroundColor
                    : AppColors.textSecondaryColor,
          ),
        ),
      ),
    );
  }

  // ── Major Projects ────────────────────────────────────────────
  Widget _buildMajorProjects(bool isDesktop) {
    final projects = projectsData!['major'] ?? [];
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      separatorBuilder:
          (_, __) => const SizedBox(height: AppDimensions.paddingXL),
      itemBuilder:
          (context, index) =>
              _buildMajorProjectCard(projects[index], isDesktop),
    );
  }

  Widget _buildMajorProjectCard(Project project, bool isDesktop) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
        border: Border.all(color: AppColors.borderColor),
        color: AppColors.surfaceColor,
      ),
      child:
          isDesktop
              ? _buildDesktopMajorCard(project)
              : _buildMobileMajorCard(project),
    );
  }

  Widget _buildDesktopMajorCard(Project project) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image side
        if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
          SizedBox(
            width: 420,
            height: 320,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  project.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (c, e, s) => Container(color: AppColors.cardBackground),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Content side
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: _buildProjectContent(project),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMajorCard(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              project.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder:
                  (c, e, s) => Container(color: AppColors.cardBackground),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: _buildProjectContent(project),
        ),
      ],
    );
  }

  Widget _buildProjectContent(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.title,
          style: GoogleFonts.spaceMono(
            fontSize: AppDimensions.fontSizeL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Text(
          project.description,
          style: GoogleFonts.inter(
            fontSize: AppDimensions.fontSizeS,
            color: AppColors.textSecondaryColor,
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        // Bullets
        ...project.bullets
            .take(3)
            .map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentColor,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    Expanded(
                      child: Text(
                        bullet,
                        style: GoogleFonts.inter(
                          fontSize: AppDimensions.fontSizeXS,
                          color: AppColors.textSecondaryColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: AppDimensions.paddingL),
        // Tech stack
        Text(
          project.techStack,
          style: GoogleFonts.inter(
            fontSize: AppDimensions.fontSizeXS,
            color: AppColors.accentColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        // Links
        Wrap(
          spacing: AppDimensions.paddingM,
          runSpacing: AppDimensions.paddingS,
          children: [
            _buildLinkButton("GitHub", Icons.code, project.githubUrl),
            if (project.liveUrl != null && project.liveUrl!.isNotEmpty)
              _buildLinkButton(
                "Live Demo",
                Icons.open_in_new,
                project.liveUrl!,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLinkButton(String label, IconData icon, String url) {
    return InkWell(
      onTap: () => _launchUrl(url, newTab: true),
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondaryColor),
            const SizedBox(width: AppDimensions.paddingS),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppDimensions.fontSizeXS,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Learning Projects ─────────────────────────────────────────
  Widget _buildLearningProjects(bool isDesktop) {
    final projects = projectsData!['learning'] ?? [];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        crossAxisSpacing: AppDimensions.paddingL,
        mainAxisSpacing: AppDimensions.paddingL,
        childAspectRatio: isDesktop ? 1.4 : 2.2,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) => _buildLearningCard(projects[index]),
    );
  }

  Widget _buildLearningCard(Project project) {
    return InkWell(
      onTap: () => _launchUrl(project.githubUrl, newTab: true),
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.folder_outlined,
                  size: 20,
                  color: AppColors.accentColor,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: Text(
                    project.title,
                    style: GoogleFonts.spaceMono(
                      fontSize: AppDimensions.fontSizeM,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: AppColors.textMutedColor,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Expanded(
              child: Text(
                project.description,
                style: GoogleFonts.inter(
                  fontSize: AppDimensions.fontSizeS,
                  color: AppColors.textSecondaryColor,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              project.techStack,
              style: GoogleFonts.inter(
                fontSize: AppDimensions.fontSizeXS,
                color: AppColors.accentColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

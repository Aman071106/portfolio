import 'package:flutter/material.dart';
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
  List<dynamic>? projectsData;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  Future<List<Project>> fetchProject() async {
    ProjectService service = ProjectService();
    return await service.fetchProjects();
  }

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
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      List<Project> projects = await fetchProject();

      setState(() {
        projectsData = projects;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      // print("Error fetching projects: $e");
      setState(() {
        isLoading = false;
        projectsData = List.empty();
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
      endDrawer: isDesktop ? null : NavDrawer(currentPath: '/projects'),
      body: Column(
        children: [
          NavBar(currentPath: '/projects'),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                    : projectsData == null
                    ? const Center(child: Text('Failed to load data'))
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildProjectsHeader(isDesktop),
                          _buildProjectsGrid(isDesktop),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsHeader(bool isDesktop) {
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
              isDesktop ? AppDimensions.paddingXL : AppDimensions.paddingL,
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
                        "My Projects",
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
                        "Here are some of my recent projects. Each represents a unique challenge and learning experience.",
                        style: TextStyle(
                          fontSize: AppDimensions.fontSizeM,
                          color: AppColors.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsGrid(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical:
            isDesktop ? AppDimensions.paddingXXL : AppDimensions.paddingXL,
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
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(opacity: _fadeAnimation.value, child: child);
            },
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 2 : 1,
                crossAxisSpacing: AppDimensions.paddingL,
                mainAxisSpacing: AppDimensions.paddingL,
                childAspectRatio: isDesktop ? 1.3 : 1.1,
              ),
              itemCount: projectsData!.length,
              itemBuilder: (context, index) {
                final project = projectsData![index];
                return _buildProjectCard(project, index);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final startTime = delay;
        final endTime = startTime + 0.6;

        final curvedAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(startTime, endTime, curve: Curves.easeOut),
        );

        final fadeValue = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(curvedAnimation);
        final slideValue = Tween<double>(
          begin: 50.0,
          end: 0.0,
        ).animate(curvedAnimation);

        return Opacity(
          opacity: fadeValue.value,
          child: Transform.translate(
            offset: Offset(0, slideValue.value),
            child: child,
          ),
        );
      },
      child: Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Image
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withValues(alpha: .5),
                        AppColors.accentColor.withValues(alpha: .5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child:
                      // project.imageUrl != null
                           Image.network(
                            project.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  color: AppColors.textLightColor,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.code,
                                  size: 60,
                                  color: AppColors.textLightColor,
                                ),
                              );
                            },
                          )
                          ,
                ),
              ),

              // Project Info
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        project.title,
                        style: TextStyle(
                          fontSize: AppDimensions.fontSizeL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.paddingS),

                      
                        Wrap(
                          spacing: AppDimensions.paddingXS,
                          runSpacing: AppDimensions.paddingXS,
                          children:
                              (project.technologies as List<dynamic>).map((
                                tech,
                              ) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingS,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: .1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.borderRadiusS,
                                    ),
                                  ),
                                  child: Text(
                                    tech,
                                    style: TextStyle(
                                      fontSize: AppDimensions.fontSizeS,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      const SizedBox(height: AppDimensions.paddingS),

                      // Description
                      Expanded(
                        child: Text(
                          project.description,
                          style: TextStyle(
                            fontSize: AppDimensions.fontSizeS,
                            color: AppColors.textSecondaryColor,
                            height: 1.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),

                      // GitHub Button
                      
                        ElevatedButton(
                          onPressed: () => _launchUrl(project.githubUrl),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.textLightColor,
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingL,
                              vertical: AppDimensions.paddingS,
                            ),
                            elevation: 3,
                            shadowColor: AppColors.primaryColor.withValues(
                              alpha: .3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusM,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.open_in_new, size: 16),
                              const SizedBox(width: AppDimensions.paddingS),
                              Text(
                                "Visit Project",
                                style: TextStyle(
                                  fontSize: AppDimensions.fontSizeS,
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
            ],
          ),
        ),
      ),
    );
  }
}

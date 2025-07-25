import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_website/features/projects/project_model.dart';
import 'package:portfolio_website/features/projects/project_service.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/navabar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bloc/project_bloc.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

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
            child: BlocProvider(
              create: (context) => ProjectBloc(ProjectService())..add(LoadProjects()),
              child: BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  } else if (state is ProjectLoaded) {
                    final projectsData = state.projects;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildProjectsHeader(isDesktop),
                          _buildProjectsGrid(projectsData, isDesktop, _launchUrl),
                        ],
                      ),
                    );
                  } else if (state is ProjectError) {
                    return Center(child: Text('Failed to load projects: ${state.message}'));
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
        ),
      ),
    );
  }

  Widget _buildProjectsGrid(List<Project> projectsData, bool isDesktop, Function(String) launchUrl) {
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
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 1,
              crossAxisSpacing: AppDimensions.paddingL,
              mainAxisSpacing: AppDimensions.paddingL,
              childAspectRatio: isDesktop ? 1.3 : 1.1,
            ),
            itemCount: projectsData.length,
            itemBuilder: (context, index) {
              final project = projectsData[index];
              return _buildProjectCard(project, launchUrl);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project, Function(String) launchUrl) {
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
                        onPressed: () => launchUrl(project.githubUrl),
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
    );
  }
}

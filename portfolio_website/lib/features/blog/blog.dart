import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_website/features/blog/blog_model.dart';
import 'package:portfolio_website/features/blog/blog_service.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/navabar.dart';

import 'bloc/blog_bloc.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

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
      endDrawer: isDesktop ? null : NavDrawer(currentPath: '/blog'),
      body: Column(
        children: [
          NavBar(currentPath: '/blog'),
          Expanded(
            child: BlocProvider(
              create: (context) => BlogBloc(Blogservice())..add(LoadBlogs()),
              child: BlocBuilder<BlogBloc, BlogState>(
                builder: (context, state) {
                  if (state is BlogLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  } else if (state is BlogLoaded) {
                    final blogs = state.blogs;
                    final expandedBlogs = state.expandedBlogs;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildBlogHeader(isDesktop),
                          _buildBlogList(blogs, expandedBlogs, isDesktop, context),
                        ],
                      ),
                    );
                  } else if (state is BlogError) {
                    return Center(child: Text('Failed to load blogs: ${state.message}'));
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

  Widget _buildBlogHeader(bool isDesktop) {
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
                  "My Blog",
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
                  "Thoughts, learnings, and insights from my journey in software development.",
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

  Widget _buildBlogList(List<Blogmodel> blogs, Set<int> expandedBlogs, bool isDesktop, BuildContext context) {
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
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index];
              final isExpanded = expandedBlogs.contains(index);

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingL,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusM,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusM,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Blog Image
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            blog.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (
                              context,
                              child,
                              loadingProgress,
                            ) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.error_outline, size: 40),
                                ),
                              );
                            },
                          ),
                        ),

                        // Blog Content
                        Padding(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingL,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tags row
                              Wrap(
                                spacing: AppDimensions.paddingXS,
                                children:
                                    (blog.tags as List<dynamic>).map((tag) {
                                      return Chip(
                                        label: Text(
                                          tag,
                                          style: const TextStyle(
                                            fontSize:
                                                AppDimensions.fontSizeXS,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        backgroundColor: AppColors
                                            .primaryColor
                                            .withValues(alpha: 0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.borderRadiusS,
                                          ),
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                      );
                                    }).toList(),
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              // Title
                              Text(
                                blog.title,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSizeL,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryColor,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingS),

                              // Date
                              Text(
                                blog.date,
                                style: TextStyle(
                                  fontSize: AppDimensions.fontSizeS,
                                  color: AppColors.textSecondaryColor
                                      .withValues(alpha: 0.7),
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              // Summary
                              Text(
                                blog.summary,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSizeM,
                                  color: AppColors.textSecondaryColor,
                                ),
                              ),

                              // Expandable content
                              if (isExpanded) ...[
                                const SizedBox(
                                  height: AppDimensions.paddingL,
                                ),
                                Text(
                                  blog.content,
                                  style: const TextStyle(
                                    fontSize: AppDimensions.fontSizeM,
                                    color: AppColors.textSecondaryColor,
                                    height: 1.6,
                                  ),
                                ),
                              ],

                              const SizedBox(height: AppDimensions.paddingM),

                              // Read more / Show less button
                              GestureDetector(
                                onTap: () => context.read<BlogBloc>().add(ToggleBlogExpansion(index: index)),
                                child: Row(
                                  children: [
                                    Text(
                                      isExpanded ? "Show less" : "Read more",
                                      style: const TextStyle(
                                        color: AppColors.accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: AppDimensions.paddingXS,
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: AppColors.accentColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

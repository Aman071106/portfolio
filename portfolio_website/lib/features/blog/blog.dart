import 'package:flutter/material.dart';
import 'package:portfolio_website/features/blog/blog_model.dart';
import 'package:portfolio_website/features/blog/blog_service.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/navabar.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage>
    with SingleTickerProviderStateMixin {
  List<Blogmodel>? blogsData;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Track expanded blog posts
  Set<int> expandedBlogs = {};

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
      Blogservice service = Blogservice();
      dynamic blogs = await service.fetchBlogservices();

      setState(() {
        blogsData = blogs;
        isLoading = false;  
      });
      _animationController.forward();
    } catch (e) {
      // print("Error loading blogs");
      // If blogs.json doesn't exist, create default data
      setState(() {
        isLoading = false;
      });
      _animationController.forward();
    }
  }

  void _toggleBlogExpansion(int index) {
    setState(() {
      if (expandedBlogs.contains(index)) {
        expandedBlogs.remove(index);
      } else {
        expandedBlogs.add(index);
      }
    });
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
      endDrawer: isDesktop ? null : NavDrawer(currentPath: '/blog'),
      body: Column(
        children: [
          NavBar(currentPath: '/blog'),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                    : blogsData == null
                    ? const Center(child: Text('Failed to load data'))
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildBlogHeader(isDesktop),
                          _buildBlogList(isDesktop),
                        ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlogList(bool isDesktop) {
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
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blogsData!.length,
              itemBuilder: (context, index) {
                final blog = blogsData![index];
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
                                  onTap: () => _toggleBlogExpansion(index),
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
      ),
    );
  }
}

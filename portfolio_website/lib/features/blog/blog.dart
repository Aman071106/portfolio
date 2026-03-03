import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Set<int> expandedBlogs = {};

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
      Blogservice service = Blogservice();
      dynamic blogs = await service.fetchBlogservices();

      setState(() {
        blogsData = blogs;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > AppDimensions.tabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: isDesktop ? null : NavDrawer(currentPath: '/blog'),
      body: Column(
        children: [
          NavBar(currentPath: '/blog'),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentColor,
                        strokeWidth: 2,
                      ),
                    )
                    : blogsData == null || blogsData!.isEmpty
                    ? _buildEmptyState()
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
                                  _buildBlogList(isDesktop),
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
          "Blog",
          style: GoogleFonts.spaceMono(
            fontSize: AppDimensions.fontSizeXXL * 1.2,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Container(width: 60, height: 2, color: AppColors.accentColor),
        const SizedBox(height: AppDimensions.paddingL),
        Text(
          "Thoughts, learnings, and insights from my journey in software development.",
          style: GoogleFonts.inter(
            fontSize: AppDimensions.fontSizeM,
            color: AppColors.textSecondaryColor,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: AppColors.textMutedColor,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            "No blog posts yet",
            style: GoogleFonts.spaceMono(
              fontSize: AppDimensions.fontSizeL,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            "Check back soon for new content!",
            style: GoogleFonts.inter(
              fontSize: AppDimensions.fontSizeM,
              color: AppColors.textMutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogList(bool isDesktop) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: blogsData!.length,
      separatorBuilder:
          (_, __) => const SizedBox(height: AppDimensions.paddingXL),
      itemBuilder: (context, index) {
        final blog = blogsData![index];
        final isExpanded = expandedBlogs.contains(index);
        return _buildBlogCard(blog, index, isExpanded, isDesktop);
      },
    );
  }

  Widget _buildBlogCard(
    Blogmodel blog,
    int index,
    bool isExpanded,
    bool isDesktop,
  ) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        border: Border.all(color: AppColors.borderColor),
      ),
      child:
          isDesktop
              ? _buildDesktopBlogCard(blog, index, isExpanded)
              : _buildMobileBlogCard(blog, index, isExpanded),
    );
  }

  Widget _buildDesktopBlogCard(Blogmodel blog, int index, bool isExpanded) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image side
        if (blog.imageUrl.isNotEmpty)
          SizedBox(
            width: 360,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    blog.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.cardBackground,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder:
                        (c, e, s) => Container(
                          color: AppColors.cardBackground,
                          child: const Center(
                            child: Icon(
                              Icons.article_outlined,
                              size: 40,
                              color: AppColors.textMutedColor,
                            ),
                          ),
                        ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Content side
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: _buildBlogContent(blog, index, isExpanded),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBlogCard(Blogmodel blog, int index, bool isExpanded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (blog.imageUrl.isNotEmpty)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              blog.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.cardBackground,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentColor,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder:
                  (c, e, s) => Container(
                    color: AppColors.cardBackground,
                    child: const Center(
                      child: Icon(
                        Icons.article_outlined,
                        size: 40,
                        color: AppColors.textMutedColor,
                      ),
                    ),
                  ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: _buildBlogContent(blog, index, isExpanded),
        ),
      ],
    );
  }

  Widget _buildBlogContent(Blogmodel blog, int index, bool isExpanded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags
        if (blog.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
            child: Wrap(
              spacing: AppDimensions.paddingS,
              runSpacing: AppDimensions.paddingS,
              children:
                  blog.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusCircular,
                        ),
                        border: Border.all(
                          color: AppColors.accentColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.inter(
                          fontSize: AppDimensions.fontSizeXS,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accentColor,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

        // Title
        Text(
          blog.title,
          style: GoogleFonts.spaceMono(
            fontSize: AppDimensions.fontSizeL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),

        // Date
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: AppColors.textMutedColor,
            ),
            const SizedBox(width: AppDimensions.paddingXS),
            Text(
              blog.date,
              style: GoogleFonts.inter(
                fontSize: AppDimensions.fontSizeXS,
                color: AppColors.textMutedColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingL),

        // Summary
        Text(
          blog.summary,
          style: GoogleFonts.inter(
            fontSize: AppDimensions.fontSizeM,
            color: AppColors.textSecondaryColor,
            height: 1.6,
          ),
        ),

        // Expandable content
        if (isExpanded) ...[
          const SizedBox(height: AppDimensions.paddingL),
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.borderColor,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            blog.content,
            style: GoogleFonts.inter(
              fontSize: AppDimensions.fontSizeM,
              color: AppColors.textSecondaryColor,
              height: 1.7,
            ),
          ),
        ],

        const SizedBox(height: AppDimensions.paddingL),

        // Read more / Show less
        InkWell(
          onTap: () => _toggleBlogExpansion(index),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isExpanded ? "Show less" : "Read more",
                style: GoogleFonts.inter(
                  fontSize: AppDimensions.fontSizeS,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingXS),
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
    );
  }
}

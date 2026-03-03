import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/navabar.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenSourcePage extends StatefulWidget {
  const OpenSourcePage({super.key});

  @override
  createState() => _OpenSourcePageState();
}

class _OpenSourcePageState extends State<OpenSourcePage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? ossData;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Set<int> expandedOrgs = {};

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
      final jsonString = await rootBundle.loadString(
        'assets/data/opensource.json',
      );
      setState(() {
        ossData = jsonDecode(jsonString);
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      log('Error loading opensource data: $e');
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
      drawer: isDesktop ? null : NavDrawer(currentPath: '/opensource'),
      body: Column(
        children: [
          NavBar(currentPath: '/opensource'),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentColor,
                        strokeWidth: 2,
                      ),
                    )
                    : ossData == null
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
                                    height: AppDimensions.paddingL,
                                  ),
                                  _buildSummaryStats(isDesktop),
                                  const SizedBox(
                                    height: AppDimensions.paddingXXL,
                                  ),
                                  _buildOrganizations(isDesktop),
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
          "Open Source",
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
          ossData!['summary']?['highlight'] ?? '',
          style: GoogleFonts.inter(
            fontSize: AppDimensions.fontSizeM,
            color: AppColors.textSecondaryColor,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(bool isDesktop) {
    final summary = ossData!['summary'] as Map<String, dynamic>?;
    if (summary == null) return const SizedBox.shrink();

    final stats = [
      {
        'value': summary['totalMergedPRs']?.toString() ?? '0',
        'label': 'Merged PRs',
      },
      {
        'value': summary['totalOrgs']?.toString() ?? '0',
        'label': 'Organizations',
      },
    ];

    return Row(
      children:
          stats.map((stat) {
            return Padding(
              padding: const EdgeInsets.only(right: AppDimensions.paddingXXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat['value']!,
                    style: GoogleFonts.spaceMono(
                      fontSize:
                          isDesktop
                              ? AppDimensions.fontSizeXXL
                              : AppDimensions.fontSizeXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentColor,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    stat['label']!,
                    style: GoogleFonts.inter(
                      fontSize: AppDimensions.fontSizeS,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildOrganizations(bool isDesktop) {
    final orgs = ossData!['organizations'] as List<dynamic>;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orgs.length,
      separatorBuilder:
          (_, __) => const SizedBox(height: AppDimensions.paddingL),
      itemBuilder:
          (context, index) => _buildOrgCard(orgs[index], index, isDesktop),
    );
  }

  Widget _buildOrgCard(Map<String, dynamic> org, int index, bool isDesktop) {
    final isExpanded = expandedOrgs.contains(index);
    final contributions = org['contributions'] as List<dynamic>;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          // Header — always visible
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  expandedOrgs.remove(index);
                } else {
                  expandedOrgs.add(index);
                }
              });
            },
            borderRadius:
                isExpanded
                    ? const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.borderRadiusL),
                    )
                    : BorderRadius.circular(AppDimensions.borderRadiusL),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              child: Row(
                children: [
                  // Org logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusM,
                    ),
                    child: _buildOrgLogo(org['logoUrl'] ?? ''),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          org['name'],
                          style: GoogleFonts.spaceMono(
                            fontSize: AppDimensions.fontSizeM,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          '${org['mergedCount']} merged contributions',
                          style: GoogleFonts.inter(
                            fontSize: AppDimensions.fontSizeS,
                            color: AppColors.mergedColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondaryColor,
                  ),
                ],
              ),
            ),
          ),
          // Expandable contributions
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderColor, width: 1),
                ),
              ),
              child: Column(
                children:
                    contributions
                        .map<Widget>(
                          (contribution) =>
                              _buildContributionItem(contribution),
                        )
                        .toList(),
              ),
            ),
            crossFadeState:
                isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildOrgLogo(String logoUrl) {
    final placeholder = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
      ),
      child: const Icon(
        Icons.code,
        size: 20,
        color: AppColors.textSecondaryColor,
      ),
    );

    if (logoUrl.isEmpty || logoUrl.endsWith('.svg')) {
      return placeholder;
    }

    return Image.asset(
      logoUrl,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => placeholder,
    );
  }

  Widget _buildContributionItem(Map<String, dynamic> contribution) {
    final isMerged = contribution['status'] == 'merged';
    return InkWell(
      onTap: () => _launchUrl(contribution['url'] ?? '', newTab: true),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXL,
          vertical: AppDimensions.paddingM,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isMerged
                        ? AppColors.mergedColor.withValues(alpha: 0.15)
                        : AppColors.openColor.withValues(alpha: 0.15),
              ),
              child: Icon(
                isMerged ? Icons.merge_type : Icons.pending_outlined,
                size: 14,
                color: isMerged ? AppColors.mergedColor : AppColors.openColor,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contribution['description'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: AppDimensions.fontSizeS,
                      color: AppColors.textSecondaryColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    contribution['url'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: AppDimensions.fontSizeXS,
                      color: AppColors.textMutedColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingS,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusS,
                ),
                color:
                    isMerged
                        ? AppColors.mergedColor.withValues(alpha: 0.1)
                        : AppColors.openColor.withValues(alpha: 0.1),
              ),
              child: Text(
                isMerged ? 'merged' : 'open',
                style: GoogleFonts.inter(
                  fontSize: AppDimensions.fontSizeXS,
                  fontWeight: FontWeight.w600,
                  color: isMerged ? AppColors.mergedColor : AppColors.openColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

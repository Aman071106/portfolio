import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/dimensions.dart';
import '../utils/constants/strings.dart';

class NavBar extends StatelessWidget {
  final String currentPath;
  const NavBar({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > AppDimensions.tabletBreakpoint;

    return Container(
      height: AppDimensions.navBarHeight,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
      child: isDesktop ? _buildDesktopNav(context) : _buildMobileNav(context),
    );
  }

  Widget _buildDesktopNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_logoWidget(), Row(children: _buildNavItems(context))],
    );
  }

  Widget _buildMobileNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _logoWidget(),
        IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimaryColor),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ],
    );
  }

  Widget _logoWidget() {
    return Text(
      MyAppStrings.appName,
      style: GoogleFonts.spaceMono(
        fontSize: AppDimensions.fontSizeL,
        fontWeight: FontWeight.bold,
        color: AppColors.accentColor,
        letterSpacing: -0.5,
      ),
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    final navItems = [
      {'label': MyAppStrings.homeNavLabel, 'path': '/'},
      {'label': MyAppStrings.aboutNavLabel, 'path': '/about'},
      {'label': MyAppStrings.experienceNavLabel, 'path': '/experiences'},
      {'label': MyAppStrings.projectsNavLabel, 'path': '/projects'},
      {'label': MyAppStrings.opensourceNavLabel, 'path': '/opensource'},
      {'label': MyAppStrings.blogNavLabel, 'path': '/blogs'},
    ];

    return navItems.map((item) {
      final isActive = currentPath == item['path'];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS),
        child: InkWell(
          onTap: () {
            if (!isActive) {
              context.go(item['path']!);
            }
          },
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusS),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isActive ? AppColors.accentColor : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              item['label']!,
              style: GoogleFonts.inter(
                fontSize: AppDimensions.fontSizeS,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color:
                    isActive
                        ? AppColors.textPrimaryColor
                        : AppColors.textSecondaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

// Drawer for Mobile
class NavDrawer extends StatelessWidget {
  final String currentPath;
  const NavDrawer({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingXL,
              AppDimensions.paddingXXXL,
              AppDimensions.paddingXL,
              AppDimensions.paddingXL,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderColor, width: 1),
              ),
            ),
            child: Text(
              MyAppStrings.appName,
              style: GoogleFonts.spaceMono(
                fontSize: AppDimensions.fontSizeXL,
                fontWeight: FontWeight.bold,
                color: AppColors.accentColor,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          ..._buildDrawerItems(context),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    final navItems = [
      {
        'label': MyAppStrings.homeNavLabel,
        'path': '/',
        'icon': Icons.home_outlined,
      },
      {
        'label': MyAppStrings.aboutNavLabel,
        'path': '/about',
        'icon': Icons.person_outline,
      },
      {
        'label': MyAppStrings.experienceNavLabel,
        'path': '/experiences',
        'icon': Icons.work_outline,
      },
      {
        'label': MyAppStrings.projectsNavLabel,
        'path': '/projects',
        'icon': Icons.code_outlined,
      },
      {
        'label': MyAppStrings.opensourceNavLabel,
        'path': '/opensource',
        'icon': Icons.merge_type_outlined,
      },
      {
        'label': MyAppStrings.blogNavLabel,
        'path': '/blogs',
        'icon': Icons.article_outlined,
      },
    ];

    return navItems.map((item) {
      final isActive = currentPath == item['path'];
      return ListTile(
        leading: Icon(
          item['icon'] as IconData,
          color:
              isActive ? AppColors.accentColor : AppColors.textSecondaryColor,
          size: 22,
        ),
        title: Text(
          item['label'].toString(),
          style: GoogleFonts.inter(
            fontSize: AppDimensions.fontSizeM,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color:
                isActive
                    ? AppColors.textPrimaryColor
                    : AppColors.textSecondaryColor,
          ),
        ),
        selected: isActive,
        selectedTileColor: AppColors.accentColor.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXL,
          vertical: AppDimensions.paddingXS,
        ),
        onTap: () {
          Navigator.pop(context);
          if (!isActive) {
            context.go(item['path'].toString());
          }
        },
      );
    }).toList();
  }
}

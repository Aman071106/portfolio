import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/strings.dart';

// Common Navigation Bar Widget
class NavBar extends StatelessWidget {
  final String currentPath;

  const NavBar({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > AppDimensions.tabletBreakpoint;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXL,
        vertical: AppDimensions.paddingM,
      ),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _logoWidget(),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _logoWidget() {
    return Text(
      MyAppStrings.appName,
      style: TextStyle(
        fontSize: AppDimensions.fontSizeXL,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    final navItems = [
      {'label': MyAppStrings.homeNavLabel, 'path': '/'},
      {'label': MyAppStrings.aboutNavLabel, 'path': '/about'},
      {'label': MyAppStrings.experienceNavLabel, 'path': '/experiences'},
      {'label': MyAppStrings.projectsNavLabel, 'path': '/projects'},
      {'label': MyAppStrings.blogNavLabel, 'path': '/blogs'},
    ];

    return navItems.map((item) {
      final isActive = currentPath == item['path'];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
        child: InkWell(
          onTap: () {
            if (!isActive) {
              context.go(item['path']!);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? AppColors.primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
              border: Border.all(
                color: isActive ? AppColors.primaryColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              item['label']!,
              style: TextStyle(
                fontSize: AppDimensions.fontSizeM,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color:
                    isActive
                        ? AppColors.primaryColor
                        : AppColors.textSecondaryColor,
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
      child: Container(
        color: AppColors.backgroundColor,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primaryColor),
              child: Center(
                child: Text(
                  MyAppStrings.appName,
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeXXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLightColor,
                  ),
                ),
              ),
            ),
            ..._buildDrawerItems(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    final navItems = [
      {'label': MyAppStrings.homeNavLabel, 'path': '/', 'icon': Icons.home},
      {
        'label': MyAppStrings.aboutNavLabel,
        'path': '/about',
        'icon': Icons.person,
      },
      {
        'label': MyAppStrings.experienceNavLabel,
        'path': '/experiences',
        'icon': Icons.work,
      },
      {
        'label': MyAppStrings.projectsNavLabel,
        'path': '/projects',
        'icon': Icons.code,
      },
      {
        'label': MyAppStrings.blogNavLabel,
        'path': '/blogs',
        'icon': Icons.article,
      },
    ];

    return navItems.map((item) {
      final isActive = currentPath == item['path'];
      return ListTile(
        leading: Icon(
          item['icon'] as IconData,
          color:
              isActive ? AppColors.primaryColor : AppColors.textSecondaryColor,
        ),
        title: Text(
          item['label'].toString(),
          style: TextStyle(
            fontSize: AppDimensions.fontSizeM,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color:
                isActive
                    ? AppColors.primaryColor
                    : AppColors.textSecondaryColor,
          ),
        ),
        selected: isActive,
        selectedTileColor: AppColors.primaryColor.withValues(alpha: 0.1),
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

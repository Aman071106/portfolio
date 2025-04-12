import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio_website/features/about_skills/about.dart';
import 'package:portfolio_website/features/blog/blog.dart';
import 'package:portfolio_website/features/errorHandler/error_page.dart';
import 'package:portfolio_website/features/experience/experience.dart';
import 'package:portfolio_website/features/home/home.dart';
import 'package:portfolio_website/features/projects/project.dart';

class MyAppRouter {
  static GoRouter getRouter() {
    GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => MaterialPage(child: HomePage()),
        ),
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) => MaterialPage(child: AboutPage()),
        ),
        GoRoute(
          path: '/experiences',
          pageBuilder:
              (context, state) => MaterialPage(child: ExperiencePage()),
        ),
        GoRoute(
          path: '/blogs',
          pageBuilder: (context, state) => MaterialPage(child: BlogPage()),
        ),
        GoRoute(
          path: '/projects',
          pageBuilder: (context, state) => MaterialPage(child: ProjectsPage()),
        ),
      ],
      errorPageBuilder: (context, state) {
        return MaterialPage(child: ErrorPage());
      },
    );
    return router;
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:portfolio_website/features/projects/project_model.dart';

class ProjectService {
  Future<Map<String, List<Project>>> fetchProjects() async {
    final jsonString = await rootBundle.loadString('assets/data/projects.json');
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final majorList =
        (data['major'] as List<dynamic>)
            .map((item) => Project.fromMap(item))
            .toList();

    final learningList =
        (data['learning'] as List<dynamic>)
            .map((item) => Project.fromMap(item))
            .toList();

    return {'major': majorList, 'learning': learningList};
  }
}

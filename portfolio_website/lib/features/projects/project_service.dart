// import 'dart:developer'; // Add this for `print()`

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio_website/features/projects/project_model.dart';

class ProjectService {
  final _db = FirebaseFirestore.instance;

  Future<List<Project>> fetchProjects() async {
    final snapshot = await _db.collection('projects').get();


    // Map and print Project objects
    final projects =
        snapshot.docs.map((doc) {
          final project = Project.fromMap(doc.data());
          // print('✅ Project mapped: $project');
          return project;
        }).toList();

    return projects;
  }
}

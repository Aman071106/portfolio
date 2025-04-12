class Project {
  final String title;
  final String description;
  final String imageUrl;
  final List<String> technologies;
  final String githubUrl;

  Project({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.technologies,
    required this.githubUrl,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      technologies: List<String>.from(map['technologies'] ?? []),
      githubUrl: map['githubUrl'] ?? '',
    );
  }
}

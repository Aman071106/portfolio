class Project {
  final String title;
  final String description;
  final String techStack;
  final List<String> bullets;
  final String githubUrl;
  final String? liveUrl;
  final String? imageUrl;
  final String category;

  Project({
    required this.title,
    required this.description,
    required this.techStack,
    required this.bullets,
    required this.githubUrl,
    this.liveUrl,
    this.imageUrl,
    required this.category,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      techStack: map['techStack'] ?? '',
      bullets: List<String>.from(map['bullets'] ?? []),
      githubUrl: map['githubUrl'] ?? '',
      liveUrl: map['liveUrl'],
      imageUrl: map['imageUrl'],
      category: map['category'] ?? 'learning',
    );
  }
}

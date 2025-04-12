class Blogmodel
 {
  final String title;
  final String date;
  final String summary;
  final String content;
  final String imageUrl;
  final List<String> tags;

  Blogmodel
  ({
    required this.title,
    required this.date,
    required this.summary,
    required this.imageUrl,
    required this.tags,
    required this.content,
  });

  factory Blogmodel
  .fromMap(Map<String, dynamic> map) {
    return Blogmodel
    (
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      summary: map['summary'] ?? '',
      date: map['date'] ?? '',
    );
  }
}

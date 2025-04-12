import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio_website/features/blog/blog_model.dart';

class Blogservice {
  final _db = FirebaseFirestore.instance;

  Future<List<Blogmodel>> fetchBlogservices() async {
    final snapshot = await _db.collection('blogs').get();

  

    // Map and print Blogservice objects
    final blogs =
        snapshot.docs.map((doc) {
          final blog = Blogmodel.fromMap(doc.data());
          // print('✅ Blogservice mapped: $Blogservice');
          return blog;
        }).toList();

    return blogs;
  }
}

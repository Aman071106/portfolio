part of 'blog_bloc.dart';

@immutable
abstract class BlogEvent {}

class LoadBlogs extends BlogEvent {}

class ToggleBlogExpansion extends BlogEvent {
  final int index;

  ToggleBlogExpansion({required this.index});

  @override
  List<Object> get props => [index];
}
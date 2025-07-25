part of 'blog_bloc.dart';

@immutable
abstract class BlogState {}

class BlogInitial extends BlogState {}

class BlogLoading extends BlogState {}

class BlogLoaded extends BlogState {
  final List<Blogmodel> blogs;
  final Set<int> expandedBlogs;

  BlogLoaded({required this.blogs, required this.expandedBlogs});

  BlogLoaded copyWith({
    List<Blogmodel>? blogs,
    Set<int>? expandedBlogs,
  }) {
    return BlogLoaded(
      blogs: blogs ?? this.blogs,
      expandedBlogs: expandedBlogs ?? this.expandedBlogs,
    );
  }

  @override
  List<Object> get props => [blogs, expandedBlogs];
}

class BlogError extends BlogState {
  final String message;

  BlogError({required this.message});

  @override
  List<Object> get props => [message];
}
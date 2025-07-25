import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:portfolio_website/features/blog/blog_model.dart';
import 'package:portfolio_website/features/blog/blog_service.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final Blogservice _blogservice;

  BlogBloc(this._blogservice) : super(BlogInitial()) {
    on<LoadBlogs>(_onLoadBlogs);
    on<ToggleBlogExpansion>(_onToggleBlogExpansion);
  }

  Future<void> _onLoadBlogs(LoadBlogs event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    try {
      final blogs = await _blogservice.fetchBlogservices();
      emit(BlogLoaded(blogs: blogs, expandedBlogs: {}));
    } catch (e) {
      emit(BlogError(message: 'Failed to load blogs'));
    }
  }

  void _onToggleBlogExpansion(
      ToggleBlogExpansion event, Emitter<BlogState> emit) {
    if (state is BlogLoaded) {
      final currentState = state as BlogLoaded;
      final expandedBlogs = Set<int>.from(currentState.expandedBlogs);
      if (expandedBlogs.contains(event.index)) {
        expandedBlogs.remove(event.index);
      } else {
        expandedBlogs.add(event.index);
      }
      emit(currentState.copyWith(expandedBlogs: expandedBlogs));
    }
  }
}
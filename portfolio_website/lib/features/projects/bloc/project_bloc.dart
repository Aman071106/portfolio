import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:portfolio_website/features/projects/project_model.dart';
import 'package:portfolio_website/features/projects/project_service.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectService _projectService;

  ProjectBloc(this._projectService) : super(ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
  }

  Future<void> _onLoadProjects(
      LoadProjects event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final projects = await _projectService.fetchProjects();
      emit(ProjectLoaded(projects: projects));
    } catch (e) {
      emit(ProjectError(message: 'Failed to load projects'));
    }
  }
}
part of 'project_bloc.dart';

@immutable
abstract class ProjectState {}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;

  ProjectLoaded({required this.projects});

  @override
  List<Object> get props => [projects];
}

class ProjectError extends ProjectState {
  final String message;

  ProjectError({required this.message});

  @override
  List<Object> get props => [message];
}
part of 'experience_bloc.dart';

@immutable
abstract class ExperienceState {}

class ExperienceInitial extends ExperienceState {}

class ExperienceLoading extends ExperienceState {}

class ExperienceLoaded extends ExperienceState {
  final List<dynamic> experienceData;

  ExperienceLoaded({required this.experienceData});

  @override
  List<Object> get props => [experienceData];
}

class ExperienceError extends ExperienceState {
  final String message;

  ExperienceError({required this.message});

  @override
  List<Object> get props => [message];
}
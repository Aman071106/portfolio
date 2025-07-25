part of 'about_bloc.dart';

@immutable
abstract class AboutState {}

class AboutInitial extends AboutState {}

class AboutLoading extends AboutState {}

class AboutLoaded extends AboutState {
  final Map<String, dynamic> aboutData;
  final Map<String, dynamic> skillsData;

  AboutLoaded({required this.aboutData, required this.skillsData});

  @override
  List<Object> get props => [aboutData, skillsData];
}

class AboutError extends AboutState {
  final String message;

  AboutError({required this.message});

  @override
  List<Object> get props => [message];
}
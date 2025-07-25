part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class LoadHomeData extends HomeEvent {}

class NameChanged extends HomeEvent {
  final String name;

  NameChanged({required this.name});

  @override
  List<Object> get props => [name];
}

class EmailChanged extends HomeEvent {
  final String email;

  EmailChanged({required this.email});

  @override
  List<Object> get props => [email];
}

class MessageChanged extends HomeEvent {
  final String message;

  MessageChanged({required this.message});

  @override
  List<Object> get props => [message];
}

class SubmitContactForm extends HomeEvent {}
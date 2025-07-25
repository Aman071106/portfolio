part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final Map<String, dynamic> homeData;
  final String name;
  final String email;
  final String message;
  final bool isSubmitting;
  final bool formSuccess;
  final String formError;

  HomeLoaded({
    required this.homeData,
    this.name = '',
    this.email = '',
    this.message = '',
    this.isSubmitting = false,
    this.formSuccess = false,
    this.formError = '',
  });

  HomeLoaded copyWith({
    Map<String, dynamic>? homeData,
    String? name,
    String? email,
    String? message,
    bool? isSubmitting,
    bool? formSuccess,
    String? formError,
  }) {
    return HomeLoaded(
      homeData: homeData ?? this.homeData,
      name: name ?? this.name,
      email: email ?? this.email,
      message: message ?? this.message,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      formSuccess: formSuccess ?? this.formSuccess,
      formError: formError ?? this.formError,
    );
  }

  @override
  List<Object> get props =>
      [homeData, name, email, message, isSubmitting, formSuccess, formError];
}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});

  @override
  List<Object> get props => [message];
}
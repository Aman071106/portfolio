import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:developer';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<NameChanged>(_onNameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<MessageChanged>(_onMessageChanged);
    on<SubmitContactForm>(_onSubmitContactForm);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // Load home.json
      final homeString = await rootBundle.loadString('assets/data/home.json');
      final homeJson = jsonDecode(homeString);

      emit(HomeLoaded(homeData: homeJson));
    } catch (e) {
      log('Error loading home data: $e');
      // If home.json doesn't exist, create default data
      emit(HomeLoaded(homeData: {
        "name": "Aman Gupta",
        "tagline": "AI/ML and Flutter App developer",
        "intro":
            "Building beautiful cross-platform applications with Flutter and exploring the frontiers of AI.",
        "resumeUrl": "#",
        "profileImage":
            "https://raw.githubusercontent.com/Aman071106/IITApp/main2/ContributorImages/profilePicAman.jpg",
      }));
    }
  }

  void _onNameChanged(NameChanged event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(name: event.name, formSuccess: false, formError: ''));
    }
  }

  void _onEmailChanged(EmailChanged event, Emitter<HomeState> emit) {
     if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(email: event.email, formSuccess: false, formError: ''));
    }
  }

  void _onMessageChanged(MessageChanged event, Emitter<HomeState> emit) {
     if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(message: event.message, formSuccess: false, formError: ''));
    }
  }

  Future<void> _onSubmitContactForm(
      SubmitContactForm event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      // Basic validation (can be expanded)
      if (currentState.name.isEmpty ||
          currentState.email.isEmpty ||
          currentState.message.isEmpty) {
             emit(currentState.copyWith(formError: 'Please fill in all fields'));
             return;
          }

      emit(currentState.copyWith(isSubmitting: true, formError: ''));

      try {
        // Simulate form submission
        await Future.delayed(const Duration(seconds: 2));

        // Here you would typically send the data to a backend service
        // For now, we'll just simulate success

        emit(currentState.copyWith(
          isSubmitting: false,
          formSuccess: true,
          name: '', // Clear form fields on success
          email: '',
          message: '',
        ));
      } catch (e) {
        log('Error submitting form: $e');
        emit(currentState.copyWith(
          isSubmitting: false,
          formSuccess: false,
          formError: 'Failed to submit form',
        ));
      }
    }
  }
}
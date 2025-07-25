import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:developer';

part 'experience_event.dart';
part 'experience_state.dart';

class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  ExperienceBloc() : super(ExperienceInitial()) {
    on<LoadExperience>(_onLoadExperience);
  }

  Future<void> _onLoadExperience(
      LoadExperience event, Emitter<ExperienceState> emit) async {
    emit(ExperienceLoading());
    try {
      // Load experience.json
      final experienceString = await rootBundle.loadString(
        'assets/data/experience.json',
      );
      final experienceJson = jsonDecode(experienceString);

      emit(ExperienceLoaded(experienceData: experienceJson));
    } catch (e) {
      log('Error loading experience data: $e');
      emit(ExperienceError(message: 'Failed to load experience data'));
    }
  }
}
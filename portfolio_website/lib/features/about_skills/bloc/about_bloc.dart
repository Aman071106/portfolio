import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:developer';

part 'about_event.dart';
part 'about_state.dart';

class AboutBloc extends Bloc<AboutEvent, AboutState> {
  AboutBloc() : super(AboutInitial()) {
    on<LoadAboutData>(_onLoadAboutData);
  }

  Future<void> _onLoadAboutData(
      LoadAboutData event, Emitter<AboutState> emit) async {
    emit(AboutLoading());
    try {
      // Load about.json
      final aboutString = await rootBundle.loadString('assets/data/about.json');
      final aboutJson = jsonDecode(aboutString);

      // Load skills.json
      final skillsString = await rootBundle.loadString(
        'assets/data/skills.json',
      );
      final skillsJson = jsonDecode(skillsString);

      emit(AboutLoaded(aboutData: aboutJson, skillsData: skillsJson));
    } catch (e) {
      log('Error loading data: $e');
      emit(AboutError(message: 'Failed to load data'));
    }
  }
}
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:afrivoyage/data/repositories/experience_repository.dart'; // Role 4
import 'package:afrivoyage/domain/entities/experience.dart';

part 'experience/experience_event.dart';
part 'experience/experience_state.dart';

class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  final ExperienceRepository experienceRepository;

  ExperienceBloc({required this.experienceRepository})
      : super(ExperienceInitial()) {
    on<LoadExperiences>(_onLoadExperiences);
    on<SearchExperiences>(_onSearchExperiences);
  }

  Future<void> _onLoadExperiences(
    LoadExperiences event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      final experiences = await experienceRepository.getExperiences(
        filters: event.filters,
      );
      emit(ExperienceLoaded(experiences));
    } catch (e) {
      emit(ExperienceError(e.toString()));
    }
  }

  Future<void> _onSearchExperiences(
    SearchExperiences event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      final experiences =
          await experienceRepository.searchExperiences(event.query);
      emit(ExperienceLoaded(experiences));
    } catch (e) {
      emit(ExperienceError(e.toString()));
    }
  }
}

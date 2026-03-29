part of 'experience_bloc.dart';

abstract class ExperienceEvent extends Equatable {
  const ExperienceEvent();
  @override
  List<Object?> get props => [];
}

class LoadExperiences extends ExperienceEvent {
  final Map<String, dynamic>? filters;
  const LoadExperiences({this.filters});
  @override
  List<Object?> get props => [filters];
}

class SearchExperiences extends ExperienceEvent {
  final String query;
  const SearchExperiences(this.query);
  @override
  List<Object> get props => [query];
}
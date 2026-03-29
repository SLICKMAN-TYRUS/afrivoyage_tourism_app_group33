part of 'impact_bloc.dart';

abstract class ImpactEvent extends Equatable {
  const ImpactEvent();
  @override
  List<Object?> get props => [];
}

class LoadImpact extends ImpactEvent {}
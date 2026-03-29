part of 'impact_bloc.dart';

class ImpactState extends Equatable {
  final int totalSpent;
  final int familiesSupported;
  final List<Booking> recentBookings;
  final bool isLoading;
  final String? error;

  const ImpactState({
    this.totalSpent = 0,
    this.familiesSupported = 0,
    this.recentBookings = const [],
    this.isLoading = false,
    this.error,
  });

  ImpactState copyWith({
    int? totalSpent,
    int? familiesSupported,
    List<Booking>? recentBookings,
    bool? isLoading,
    String? error,
  }) {
    return ImpactState(
      totalSpent: totalSpent ?? this.totalSpent,
      familiesSupported: familiesSupported ?? this.familiesSupported,
      recentBookings: recentBookings ?? this.recentBookings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [totalSpent, familiesSupported, recentBookings, isLoading, error];
}
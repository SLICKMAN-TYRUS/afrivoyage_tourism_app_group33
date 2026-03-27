import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/experience_repository.dart';

// Events
abstract class ProviderEvent extends Equatable {
  const ProviderEvent();
  @override
  List<Object?> get props => [];
}

class LoadProviderBookings extends ProviderEvent {
  final String providerId;
  const LoadProviderBookings(this.providerId);
  @override
  List<Object?> get props => [providerId];
}

class LoadProviderExperiences extends ProviderEvent {
  final String providerId;
  const LoadProviderExperiences(this.providerId);
  @override
  List<Object?> get props => [providerId];
}

class UpdateBookingStatus extends ProviderEvent {
  final String bookingId;
  final String status;
  const UpdateBookingStatus(this.bookingId, this.status);
  @override
  List<Object?> get props => [bookingId, status];
}

class ToggleExperienceAvailability extends ProviderEvent {
  final String experienceId;
  final bool isAvailable;
  const ToggleExperienceAvailability(this.experienceId, this.isAvailable);
  @override
  List<Object?> get props => [experienceId, isAvailable];
}

// States
abstract class ProviderState extends Equatable {
  const ProviderState();
  @override
  List<Object?> get props => [];
}

class ProviderInitial extends ProviderState {}

class ProviderLoading extends ProviderState {}

class ProviderLoaded extends ProviderState {
  final List<QueryDocumentSnapshot> bookings;
  final List<QueryDocumentSnapshot> experiences;
  const ProviderLoaded(this.bookings, this.experiences);
  @override
  List<Object?> get props => [bookings, experiences];
}

class ProviderError extends ProviderState {
  final String message;
  const ProviderError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ProviderBloc extends Bloc<ProviderEvent, ProviderState> {
  final BookingRepository _bookingRepository;
  final ExperienceRepository _experienceRepository;

  ProviderBloc({
    required BookingRepository bookingRepository,
    required ExperienceRepository experienceRepository,
  })  : _bookingRepository = bookingRepository,
        _experienceRepository = experienceRepository,
        super(ProviderInitial()) {
    on<LoadProviderBookings>(_onLoadProviderBookings);
    on<LoadProviderExperiences>(_onLoadProviderExperiences);
    on<UpdateBookingStatus>(_onUpdateBookingStatus);
    on<ToggleExperienceAvailability>(_onToggleExperienceAvailability);
  }

  Future<void> _onLoadProviderBookings(
    LoadProviderBookings event,
    Emitter<ProviderState> emit,
  ) async {
    emit(ProviderLoading());
    try {
      await emit.forEach(
        _bookingRepository.getProviderBookings(event.providerId),
        onData: (snapshot) {
          // Also load experiences for complete state
          _experienceRepository
              .getProviderExperiences(event.providerId)
              .first
              .then((expSnapshot) {
            // This is a simplification - in real app, combine streams properly
          });
          return ProviderLoaded(snapshot.docs, []);
        },
        onError: (_, __) => const ProviderError('Failed to load bookings'),
      );
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }

  Future<void> _onLoadProviderExperiences(
    LoadProviderExperiences event,
    Emitter<ProviderState> emit,
  ) async {
    // Implementation similar to above
  }

  Future<void> _onUpdateBookingStatus(
    UpdateBookingStatus event,
    Emitter<ProviderState> emit,
  ) async {
    try {
      await _bookingRepository.updateBookingStatus(
          event.bookingId, event.status);
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }

  Future<void> _onToggleExperienceAvailability(
    ToggleExperienceAvailability event,
    Emitter<ProviderState> emit,
  ) async {
    try {
      await _experienceRepository.updateExperience(
        event.experienceId,
        {'isAvailable': event.isAvailable},
      );
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }
}

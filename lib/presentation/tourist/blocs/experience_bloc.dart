import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADD THIS
import '../../../data/repositories/experience_repository.dart';
import '../../../data/repositories/booking_repository.dart';

// Events
abstract class ExperienceEvent extends Equatable {
  const ExperienceEvent();
  @override
  List<Object?> get props => [];
}

class LoadExperiences extends ExperienceEvent {
  final String? category;
  final double? maxPrice;
  const LoadExperiences({this.category, this.maxPrice});
  @override
  List<Object?> get props => [category, maxPrice];
}

class CreateBooking extends ExperienceEvent {
  final String experienceId;
  final String providerId;
  final DateTime experienceDate;
  final int groupSize;
  final double totalPrice;
  final String paymentMethod;

  const CreateBooking({
    required this.experienceId,
    required this.providerId,
    required this.experienceDate,
    required this.groupSize,
    required this.totalPrice,
    required this.paymentMethod,
  });
  @override
  List<Object?> get props => [
        experienceId,
        providerId,
        experienceDate,
        groupSize,
        totalPrice,
        paymentMethod,
      ];
}

// States
abstract class ExperienceState extends Equatable {
  const ExperienceState();
  @override
  List<Object?> get props => [];
}

class ExperienceInitial extends ExperienceState {}

class ExperienceLoading extends ExperienceState {}

class ExperiencesLoaded extends ExperienceState {
  final List<QueryDocumentSnapshot> experiences;
  const ExperiencesLoaded(this.experiences);
  @override
  List<Object?> get props => [experiences];
}

class BookingCreated extends ExperienceState {
  final String bookingId;
  const BookingCreated(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class ExperienceError extends ExperienceState {
  final String message;
  const ExperienceError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  final ExperienceRepository _experienceRepository;
  final BookingRepository _bookingRepository;

  ExperienceBloc({
    required ExperienceRepository experienceRepository,
    required BookingRepository bookingRepository,
  })  : _experienceRepository = experienceRepository,
        _bookingRepository = bookingRepository,
        super(ExperienceInitial()) {
    on<LoadExperiences>(_onLoadExperiences);
    on<CreateBooking>(_onCreateBooking);
  }

  Future<void> _onLoadExperiences(
    LoadExperiences event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      await emit.forEach(
        _experienceRepository.getExperiences(
          category: event.category,
          maxPrice: event.maxPrice,
        ),
        onData: (snapshot) => ExperiencesLoaded(snapshot.docs),
        onError: (_, __) => const ExperienceError('Failed to load experiences'),
      );
    } catch (e) {
      emit(ExperienceError(e.toString()));
    }
  }

  Future<void> _onCreateBooking(
    CreateBooking event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      // ✅ FIX: Get actual user ID from Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(const ExperienceError('You must be logged in to book'));
        return;
      }

      final bookingId = await _bookingRepository.createBooking(
        touristId: currentUser.uid, // ✅ Real user ID!
        experienceId: event.experienceId,
        providerId: event.providerId,
        experienceDate: event.experienceDate,
        groupSize: event.groupSize,
        totalPrice: event.totalPrice,
        paymentMethod: event.paymentMethod,
      );
      emit(BookingCreated(bookingId));
    } catch (e) {
      emit(ExperienceError(e.toString()));
    }
  }
}

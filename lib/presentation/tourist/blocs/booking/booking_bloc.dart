import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:afrivoyage/data/repositories/booking_repository.dart';
import 'package:afrivoyage/domain/entities/booking.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;

  BookingBloc({required this.bookingRepository}) : super(BookingInitial()) {
    on<CreateBooking>(_onCreateBooking);
    on<FetchBookings>(_onFetchBookings);
  }

  Future<void> _onCreateBooking(
    CreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final booking = await bookingRepository.createBooking(
        experienceId: event.experienceId,
        date: event.date,
        participants: event.participants,
        paymentMethod: event.paymentMethod,
      );
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onFetchBookings(
    FetchBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final bookings = await bookingRepository.getBookings();
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
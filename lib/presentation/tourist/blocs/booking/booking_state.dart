part of 'booking_bloc.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final Booking booking;
  const BookingSuccess(this.booking);
  @override
  List<Object> get props => [booking];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
  @override
  List<Object> get props => [message];
}

class BookingsLoaded extends BookingState {
  final List<Booking> bookings;
  const BookingsLoaded(this.bookings);
  @override
  List<Object> get props => [bookings];
}
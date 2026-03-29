part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class CreateBooking extends BookingEvent {
  final String experienceId;
  final DateTime date;
  final int participants;
  final String paymentMethod; // 'mtn' or 'airtel'
  const CreateBooking({
    required this.experienceId,
    required this.date,
    required this.participants,
    required this.paymentMethod,
  });
  @override
  List<Object> get props => [experienceId, date, participants, paymentMethod];
}

class FetchBookings extends BookingEvent {}
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:afrivoyage/data/repositories/booking_repository.dart';
import 'package:afrivoyage/domain/entities/booking.dart';

part 'impact_event.dart';
part 'impact_state.dart';

class ImpactBloc extends Bloc<ImpactEvent, ImpactState> {
  final BookingRepository bookingRepository;

  ImpactBloc({required this.bookingRepository}) : super(const ImpactState()) {
    on<LoadImpact>(_onLoadImpact);
  }

  Future<void> _onLoadImpact(
    LoadImpact event,
    Emitter<ImpactState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final bookings = await bookingRepository.getBookings();
      final totalSpent = bookings.fold<int>(0, (sum, b) => sum + b.totalPrice);
      // Estimate families supported: each booking might support at least one family.
      // Could be improved by tracking distinct hosts.
      final familiesSupported = bookings.length; // simplistic
      emit(state.copyWith(
        isLoading: false,
        totalSpent: totalSpent,
        familiesSupported: familiesSupported,
        recentBookings: bookings.take(5).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
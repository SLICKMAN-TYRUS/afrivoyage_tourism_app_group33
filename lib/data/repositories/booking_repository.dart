import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final String _collection = 'bookings';

  // CREATE - Create new booking (CRUD: Create)
  Future<String> createBooking({
    required String touristId,
    required String experienceId,
    required String providerId,
    required DateTime experienceDate,
    required int groupSize,
    required double totalPrice,
    required String paymentMethod,
  }) async {
    try {
      print('📝 Creating booking for tourist: $touristId');
      print('📦 Experience: $experienceId, Provider: $providerId');

      final docRef = await _firestore.collection(_collection).add({
        'touristId': touristId,
        'experienceId': experienceId,
        'providerId': providerId,
        'status': 'pending',
        'bookingDate': Timestamp.now(),
        'experienceDate': Timestamp.fromDate(experienceDate),
        'groupSize': groupSize,
        'totalPrice': totalPrice,
        'paymentMethod': paymentMethod,
        'paymentStatus': 'pending',
        'offlineSyncStatus': 'synced',
        'createdAt': Timestamp.now(),
      });

      print('✅ Booking created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Failed to create booking: $e');
      throw Exception('Failed to create booking: ${e.toString()}');
    }
  }

  // READ - Get tourist's bookings (CRUD: Read)
  Stream<QuerySnapshot> getTouristBookings(String touristId) {
    print('🔍 Getting bookings for tourist: $touristId');
    return _firestore
        .collection(_collection)
        .where('touristId', isEqualTo: touristId)
        .orderBy('experienceDate', descending: true)
        .snapshots();
  }

  // READ - Get provider's bookings (CRUD: Read)
  Stream<QuerySnapshot> getProviderBookings(String providerId) {
    return _firestore
        .collection(_collection)
        .where('providerId', isEqualTo: providerId)
        .where('status', whereIn: ['pending', 'confirmed']).snapshots();
  }

  // READ - Get single booking by ID
  Future<DocumentSnapshot> getBookingById(String bookingId) async {
    return await _firestore.collection(_collection).doc(bookingId).get();
  }

  // UPDATE - Update booking status (CRUD: Update)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
      print('✅ Booking $bookingId updated to $status');
    } catch (e) {
      print('❌ Failed to update booking: $e');
      throw Exception('Failed to update booking: ${e.toString()}');
    }
  }

  // UPDATE - Confirm payment
  Future<void> confirmPayment(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'paymentStatus': 'paid',
        'status': 'confirmed',
        'updatedAt': Timestamp.now(),
      });
      print('✅ Payment confirmed for booking: $bookingId');
    } catch (e) {
      print('❌ Failed to confirm payment: $e');
      throw Exception('Failed to confirm payment: ${e.toString()}');
    }
  }

  // DELETE - Cancel booking (CRUD: Delete)
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': Timestamp.now(),
      });
      print('✅ Booking $bookingId cancelled');
    } catch (e) {
      print('❌ Failed to cancel booking: $e');
      throw Exception('Failed to cancel booking: ${e.toString()}');
    }
  }

  // For Video Demo: Get all bookings (to show in Firebase Console)
  Stream<QuerySnapshot> getAllBookings() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

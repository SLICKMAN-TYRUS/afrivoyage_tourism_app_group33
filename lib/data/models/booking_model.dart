import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String experienceId;
  final String experienceTitle;
  final DateTime date;
  final int participants;
  final int totalPrice; // price * participants
  final String status; // 'confirmed', 'pending', 'cancelled'
  final String paymentMethod; // 'mtn', 'airtel'

  Booking({
    required this.id,
    required this.experienceId,
    required this.experienceTitle,
    required this.date,
    required this.participants,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      experienceId: json['experienceId'] ?? '',
      experienceTitle: json['experienceTitle'] ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participants: json['participants'] ?? 1,
      totalPrice: (json['totalPrice'] as num?)?.toInt() ?? 0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'mtn',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'experienceId': experienceId,
    'experienceTitle': experienceTitle,
    'date': Timestamp.fromDate(date),
    'participants': participants,
    'totalPrice': totalPrice,
    'status': status,
    'paymentMethod': paymentMethod,
  };
}
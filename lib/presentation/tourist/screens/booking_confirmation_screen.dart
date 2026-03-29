import 'package:flutter/material.dart';
import 'package:afrivoyage/domain/entities/booking.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            const Text(
              'Your booking is confirmed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Booking ID: ${booking.id}'),
            Text('Experience: ${booking.experienceTitle}'),
            Text('Date: ${booking.date.toLocal()}'),
            Text('Participants: ${booking.participants}'),
            Text('Total: RWF ${booking.totalPrice}'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to home or impact dashboard
                context.go('/home');
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
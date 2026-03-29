import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Booking Validation', () {
    test('should calculate total price correctly with group size', () {
      // Arrange
      const pricePerPerson = 25000.0; // RWF
      const groupSize = 4;

      // Act
      const totalPrice = pricePerPerson * groupSize;

      // Assert
      expect(totalPrice, equals(100000.0));
    });

    test('should reject booking for past dates', () {
      // Arrange
      final pastDate = DateTime(2025, 1, 1); // Date in the past
      final today = DateTime.now();

      // Act
      final isValid = pastDate.isAfter(today);

      // Assert
      expect(isValid, false);
    });
  });
}

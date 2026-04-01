import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date Utilities', () {
    test('should format date to readable string', () {
      // Arrange
      final date = DateTime(2026, 3, 29);

      // Act
      final formatted = '${date.day}/${date.month}/${date.year}';

      // Assert
      expect(formatted, equals('29/3/2026'));
    });

    test('should calculate days until experience correctly', () {
      // Arrange
      final today = DateTime(2026, 3, 29);
      final experienceDate = DateTime(2026, 4, 3);

      // Act
      final daysUntil = experienceDate.difference(today).inDays;

      // Assert
      expect(daysUntil, equals(5));
    });
  });
}

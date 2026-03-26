import 'package:flutter_test/flutter_test.dart';
import 'package:afrivoyage/data/repositories/payment_repository.dart';

void main() {
  group('PaymentRepository', () {
    late PaymentRepository paymentRepository;

    setUp(() {
      paymentRepository = PaymentRepository();
    });

    test('calculatePaymentBreakdown should correctly compute 8% platform fee', () {
      // Arrange
      const totalAmount = 100000.0; // RWF 100,000
      
      // Act
      final breakdown = paymentRepository.calculatePaymentBreakdown(totalAmount);
      
      // Assert
      expect(breakdown['totalAmount'], equals(100000.0));
      expect(breakdown['platformFeePercent'], equals(8.0));
      expect(breakdown['platformFee'], equals(8000.0)); // 8% of 100k
      expect(breakdown['providerEarnings'], equals(92000.0)); // 92% of 100k
    });

    test('calculatePaymentBreakdown should handle zero amount', () {
      final breakdown = paymentRepository.calculatePaymentBreakdown(0.0);
      
      expect(breakdown['totalAmount'], equals(0.0));
      expect(breakdown['platformFee'], equals(0.0));
      expect(breakdown['providerEarnings'], equals(0.0));
    });
  });
}

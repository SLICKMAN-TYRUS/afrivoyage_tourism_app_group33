import 'package:flutter/material.dart';

class ProviderEarnings extends StatelessWidget {
  const ProviderEarnings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Earnings Card
            Card(
              color: Colors.green[900],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Earnings',
                      style: TextStyle(color: Colors.green[100]),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'RWF 2,450,000',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '+15% from last month',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Breakdown
            Text(
              'Monthly Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildMonthCard('March 2026', 'RWF 680,000', 12),
            _buildMonthCard('February 2026', 'RWF 590,000', 10),
            _buildMonthCard('January 2026', 'RWF 520,000', 8),

            const SizedBox(height: 24),
            // Commission Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Commission Structure',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildCommissionRow('Platform fee', '8%', 'RWF 196,000'),
                    const Divider(),
                    _buildCommissionRow(
                        'Your earnings', '92%', 'RWF 2,254,000'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard(String month, String amount, int bookings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(month, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$bookings bookings'),
        trailing: Text(
          amount,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionRow(String label, String percent, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(label),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                percent,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

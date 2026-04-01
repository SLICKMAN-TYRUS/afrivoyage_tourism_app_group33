import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ProviderEarnings extends StatelessWidget {
  const ProviderEarnings({super.key});

  static const _months = [
    {'label': 'March 2026', 'amount': 680000, 'bookings': 12},
    {'label': 'February 2026', 'amount': 590000, 'bookings': 10},
    {'label': 'January 2026', 'amount': 520000, 'bookings': 9},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.earnings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Total earnings card ──────────────────────
            Card(
              color: Colors.green[900],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.totalEarnings,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text(
                      'RWF 2,450,000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.trending_up,
                            color: Colors.greenAccent, size: 18),
                        SizedBox(width: 6),
                        Text('+15% from last month',
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Monthly breakdown ────────────────────────
            Text(l10n.monthlyBreakdown,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._months.map((m) => _monthCard(context, m)),
            const SizedBox(height: 24),

            // ── Commission structure ─────────────────────
            Text(l10n.commissionStructure,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _commissionRow(l10n.platformFee, '8%',
                        Colors.orange),
                    const SizedBox(height: 10),
                    _commissionRow(l10n.yourEarnings, '92%',
                        Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthCard(BuildContext context, Map<String, Object> m) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['label'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  '${m['bookings']} ${l10n.bookingsCount}',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            Text(
              'RWF ${_fmt((m['amount'] as int).toDouble())}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commissionRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 14)),
        ),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16)),
      ],
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(1)}M';
    }
    if (v >= 1000) {
      final k = v / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}K';
    }
    return v.toStringAsFixed(0);
  }
}

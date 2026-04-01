import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';

// Static bookings for demo
final _kBookings = <Map<String, dynamic>>[
  {
    'id': 'BKP001',
    'title': 'Gorilla Trekking Experience',
    'touristName': 'Alice M.',
    'date': 'Apr 15, 2026',
    'groupSize': 2,
    'paymentMethod': 'MTN MoMo',
    'total': 190000,
    'status': 'confirmed',
  },
  {
    'id': 'BKP002',
    'title': 'Coffee Farm Tour & Tasting',
    'touristName': 'Jean P.',
    'date': 'Apr 10, 2026',
    'groupSize': 4,
    'paymentMethod': 'Airtel Money',
    'total': 80000,
    'status': 'pending',
  },
  {
    'id': 'BKP003',
    'title': 'Gorilla Trekking Experience',
    'touristName': 'Emma K.',
    'date': 'Mar 30, 2026',
    'groupSize': 1,
    'paymentMethod': 'MTN MoMo',
    'total': 95000,
    'status': 'completed',
  },
];

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  // Local copy so status updates reflect in UI
  late final List<Map<String, dynamic>> _bookings =
      _kBookings.map((b) => Map<String, dynamic>.from(b)).toList();

  int get _pendingCount =>
      _bookings.where((b) => b['status'] == 'pending').length;
  int get _confirmedCount =>
      _bookings.where((b) => b['status'] == 'confirmed').length;
  int get _completedCount =>
      _bookings.where((b) => b['status'] == 'completed').length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.providerDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome card ─────────────────────────────
            Card(
              color: Colors.green[900],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person,
                              size: 32, color: Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(l10n.welcomeBack,
                                  style: TextStyle(
                                      color: Colors.green[100])),
                              const Text(
                                'Jean-Baptiste R.',
                                style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(l10n.verifiedGuideBadge,
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Earnings summary ─────────────────────────
            Row(
              children: [
                Expanded(
                    child: _summaryCard(l10n.thisMonth,
                        'RWF 680K', Icons.trending_up,
                        Colors.green)),
                const SizedBox(width: 12),
                Expanded(
                    child: _summaryCard(l10n.today,
                        '${_bookings.length} ${l10n.bookings}',
                        Icons.calendar_today, Colors.blue)),
              ],
            ),
            const SizedBox(height: 20),

            // ── Quick stats ──────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [
                    _statCol(l10n.pending,
                        '$_pendingCount', Colors.orange),
                    _divider(),
                    _statCol(l10n.confirmed,
                        '$_confirmedCount', Colors.blue),
                    _divider(),
                    _statCol(l10n.completed,
                        '$_completedCount', Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Recent bookings ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.recentBookings,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text(l10n.viewAll)),
              ],
            ),
            const SizedBox(height: 10),
            ..._bookings.map((b) => _bookingCard(context, b)),

            const SizedBox(height: 20),
            // ── Quick actions ────────────────────────────
            Text(l10n.quickActions,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _actionCard(
                        Icons.add, l10n.addExperience,
                        () => context.push('/provider/listings'))),
                const SizedBox(width: 12),
                Expanded(
                    child: _actionCard(
                        Icons.calendar_today, l10n.availability,
                        () => _showAvailabilityDialog(context))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _actionCard(
                        Icons.analytics, l10n.analytics,
                        () => context.push('/provider/earnings'))),
                const SizedBox(width: 12),
                Expanded(
                    child: _actionCard(
                        Icons.support_agent, l10n.support,
                        () => _showSupportDialog(context))),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) context.push('/provider/listings');
          if (i == 3) context.push('/provider/earnings');
        },
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: l10n.dashboard),
          BottomNavigationBarItem(
              icon: const Icon(Icons.list_alt_outlined),
              activeIcon: const Icon(Icons.list_alt),
              label: l10n.listings),
          BottomNavigationBarItem(
              icon: const Icon(Icons.message_outlined),
              activeIcon: const Icon(Icons.message),
              label: l10n.messages),
          BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              activeIcon: const Icon(Icons.account_balance_wallet),
              label: l10n.earnings),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.navProfile),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────

  Widget _summaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                    color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _statCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _divider() => Container(
      height: 40, width: 1, color: Colors.grey.withValues(alpha: 0.3));

  Widget _bookingCard(
      BuildContext context, Map<String, dynamic> b) {
    final l10n = AppLocalizations.of(context)!;
    final status = b['status'] as String;
    final sc = _statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: sc.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_statusIcon(status), color: sc),
        ),
        title: Text(
          '${b['touristName']} · ${b['title']}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              '${b['date']} · ${b['groupSize']} people · ${b['paymentMethod']}',
              style: TextStyle(
                  color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(status.toUpperCase(),
                      style: TextStyle(
                          color: sc,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(
                  'RWF ${_fmt((b['total'] as int).toDouble())}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) => setState(() => b['status'] = v),
          itemBuilder: (_) => [
            PopupMenuItem(
                value: 'confirmed',
                child: Text(l10n.confirmBooking)),
            PopupMenuItem(
                value: 'completed',
                child: Text(l10n.markComplete)),
            PopupMenuItem(
              value: 'cancelled',
              child: Text(l10n.cancelBooking,
                  style:
                      TextStyle(color: Colors.red[700])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
      IconData icon, String label, VoidCallback onTap) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 30, color: Colors.green),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String? s) {
    switch (s) {
      case 'confirmed':
        return Icons.check;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.close;
      default:
        return Icons.pending;
    }
  }

  String _fmt(double v) {
    if (v >= 1000) {
      final k = v / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}K';
    }
    return v.toStringAsFixed(0);
  }

  void _showNotifications(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.notifications,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                  backgroundColor:
                      Colors.blue.withValues(alpha: 0.15),
                  child: const Icon(Icons.book_online,
                      color: Colors.blue, size: 20)),
              title: Text(l10n.newBookingNotif,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: const Text(
                  'Alice M. booked Gorilla Trekking for Apr 15.',
                  style: TextStyle(fontSize: 12)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                  backgroundColor:
                      Colors.green.withValues(alpha: 0.15),
                  child: const Icon(Icons.payment,
                      color: Colors.green, size: 20)),
              title: Text(l10n.paymentReceived,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: const Text('RWF 95,000 received via MTN MoMo.',
                  style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvailabilityDialog(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.setAvailability),
        content: Text(l10n.availabilityComingSoon),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.ok))
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.providerSupport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.contactUs,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('📧  providers@afrivoyage.rw'),
            const SizedBox(height: 4),
            const Text('📞  +250 788 999 000'),
            const SizedBox(height: 4),
            const Text('⏰  Mon–Fri  8 am – 6 pm (CAT)'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.close))
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/experience_repository.dart';
import '../blocs/provider_bloc.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthRepository().currentUser;
    final providerId = currentUser?.uid ?? 'test_provider';

    return BlocProvider(
      create: (context) => ProviderBloc(
        bookingRepository: BookingRepository(),
        experienceRepository: ExperienceRepository(),
      )..add(LoadProviderBookings(providerId)),
      child: const _ProviderDashboardView(),
    );
  }
}

class _ProviderDashboardView extends StatelessWidget {
  const _ProviderDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
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
                          child:
                              Icon(Icons.person, size: 32, color: Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(color: Colors.green[100]),
                              ),
                              const Text(
                                'Provider Name',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.verified, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Verified Guide - RDB Certified',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Earnings Summary
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'This Month',
                    'RWF 680K',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Today',
                    '3 Bookings',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Pending', '3', Colors.orange),
                    _buildStatColumn('Confirmed', '8', Colors.blue),
                    _buildStatColumn('Completed', '12', Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Today's Bookings Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Bookings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bookings List
            BlocBuilder<ProviderBloc, ProviderState>(
              builder: (context, state) {
                if (state is ProviderLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProviderError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: ${state.message}'),
                    ),
                  );
                }
                if (state is ProviderLoaded) {
                  if (state.bookings.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No bookings yet')),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.bookings.length,
                    itemBuilder: (context, index) {
                      final booking =
                          state.bookings[index].data() as Map<String, dynamic>;
                      return _buildBookingCard(
                          context, booking, state.bookings[index].id);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    Icons.add,
                    'Add Experience',
                    () => context.push('/provider/listings'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    Icons.calendar_today,
                    'Availability',
                    () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    Icons.analytics,
                    'Analytics',
                    () => context.push('/provider/earnings'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    Icons.support,
                    'Support',
                    () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.push('/provider/listings');
          if (index == 3) context.push('/provider/earnings');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBookingCard(
      BuildContext context, Map<String, dynamic> booking, String id) {
    final status = booking['status'] as String? ?? 'pending';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getStatusIcon(status), color: statusColor),
        ),
        title: Text(
          'Booking #${id.substring(0, 6)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
                '${booking['groupSize']} people • ${booking['paymentMethod']}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'confirm') {
              context
                  .read<ProviderBloc>()
                  .add(UpdateBookingStatus(id, 'confirmed'));
            } else if (value == 'complete') {
              context
                  .read<ProviderBloc>()
                  .add(UpdateBookingStatus(id, 'completed'));
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'confirm',
              child: Text('Confirm Booking'),
            ),
            const PopupMenuItem(
              value: 'complete',
              child: Text('Mark Complete'),
            ),
            const PopupMenuItem(
              value: 'cancel',
              child:
                  Text('Cancel Booking', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
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

  IconData _getStatusIcon(String? status) {
    switch (status) {
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

  Widget _buildActionCard(IconData icon, String label, VoidCallback onTap) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.green),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

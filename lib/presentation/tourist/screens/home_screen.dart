import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/cubits/settings_cubit.dart';
import '../../../core/routes/route_names.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../shared/theme/theme_cubit.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Static experience data
// ─────────────────────────────────────────────────────────────────────────────
final _kExperiences = <Map<String, dynamic>>[
  {
    'id': 'exp1',
    'title': 'Gorilla Trekking Experience',
    'category': 'Adventure',
    'description':
        'Trek through lush rainforests to encounter endangered mountain gorillas in their natural habitat. Led by expert RDB-certified guides.',
    'priceRWF': 95000.0,
    'rating': 4.9,
    'reviewCount': 127,
    'location': 'Volcanoes National Park',
    'duration': '6–8 hours',
    'verified': true,
    'color': 0xFF1B5E20,
  },
  {
    'id': 'exp2',
    'title': 'Traditional Intore Dance Workshop',
    'category': 'Culture',
    'description':
        'Learn the powerful Intore dance — a UNESCO-recognised cultural heritage of Rwanda — performed by skilled local artists.',
    'priceRWF': 15000.0,
    'rating': 4.8,
    'reviewCount': 89,
    'location': 'Kigali Cultural Center',
    'duration': '2 hours',
    'verified': true,
    'color': 0xFF4A148C,
  },
  {
    'id': 'exp3',
    'title': 'Coffee Farm Tour & Tasting',
    'category': 'Food & Drink',
    'description':
        "Visit a local coffee cooperative and learn about Rwanda's famous single-origin coffee, from bean to cup.",
    'priceRWF': 20000.0,
    'rating': 4.7,
    'reviewCount': 56,
    'location': 'Huye District',
    'duration': '3 hours',
    'verified': false,
    'color': 0xFF4E342E,
  },
  {
    'id': 'exp4',
    'title': 'Nyungwe Forest Canopy Walk',
    'category': 'Nature',
    'description':
        "Walk 70 m above the ground on a suspension bridge through one of Africa's oldest rainforests, full of primates and birds.",
    'priceRWF': 25000.0,
    'rating': 4.6,
    'reviewCount': 203,
    'location': 'Nyungwe National Park',
    'duration': '4 hours',
    'verified': true,
    'color': 0xFF2E7D32,
  },
  {
    'id': 'exp5',
    'title': 'Lake Kivu Sunset Cruise',
    'category': 'Nature',
    'description':
        'Sail on beautiful Lake Kivu while watching the sunset over the Congo Nile Trail mountains with local fishermen.',
    'priceRWF': 18000.0,
    'rating': 4.5,
    'reviewCount': 78,
    'location': 'Gisenyi, Lake Kivu',
    'duration': '2 hours',
    'verified': false,
    'color': 0xFF01579B,
  },
  {
    'id': 'exp6',
    'title': 'Kigali City Heritage Tour',
    'category': 'Culture',
    'description':
        "Explore Kigali's transformation — from the Genocide Memorial to bustling Kimironko Market — with knowledgeable local guides.",
    'priceRWF': 12000.0,
    'rating': 4.7,
    'reviewCount': 145,
    'location': 'Kigali City',
    'duration': '3 hours',
    'verified': true,
    'color': 0xFFE65100,
  },
];

// Static past / upcoming bookings shown on the Bookings tab
final _kBookings = <Map<String, dynamic>>[
  {
    'id': 'BK-001',
    'title': 'Gorilla Trekking Experience',
    'date': 'April 15, 2026',
    'participants': 2,
    'total': 190000,
    'status': 'confirmed',
  },
  {
    'id': 'BK-002',
    'title': 'Coffee Farm Tour & Tasting',
    'date': 'March 28, 2026',
    'participants': 3,
    'total': 60000,
    'status': 'completed',
  },
  {
    'id': 'BK-003',
    'title': 'Lake Kivu Sunset Cruise',
    'date': 'April 22, 2026',
    'participants': 4,
    'total': 72000,
    'status': 'pending',
  },
];

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — 5-tab shell
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  // Internal filter key stays in English to match experience data
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  List<String> _tabTitles(AppLocalizations l10n) => [
        l10n.discoverRwanda,
        l10n.explore,
        l10n.myBookings,
        l10n.yourImpact,
        l10n.profileTab,
      ];

  // Maps internal English key -> localized display label
  Map<String, String> _categoryLabels(AppLocalizations l10n) => {
        'All': l10n.categoryAll,
        'Nature': l10n.categoryNature,
        'Culture': l10n.categoryCulture,
        'Food & Drink': l10n.categoryFoodDrink,
        'Adventure': l10n.categoryAdventure,
      };

  @override
  void initState() {
    super.initState();
    _redirectProviderOnRestart();
  }

  Future<void> _redirectProviderOnRestart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final profile = await AuthRepository().getUserProfile(user.uid);
    final role = (profile?['accountType'] as String?) ?? 'tourist';
    if (role == 'provider' && mounted) {
      context.go(RouteNames.provider);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    return _kExperiences.where((exp) {
      final matchSearch = _searchQuery.isEmpty ||
          (exp['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (exp['description'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCat =
          _selectedCategory == 'All' || exp['category'] == _selectedCategory;
      return matchSearch && matchCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles(l10n)[_selectedIndex]),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () => _showNotifications(context),
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildExploreTab(),
          _buildBookingsTab(),
          _buildImpactTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.homeTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: l10n.exploreTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_online),
            label: l10n.bookingsTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_nature),
            label: l10n.impactTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profileTab,
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Notifications bottom sheet
  // ════════════════════════════════════════════════════════════════════════════
  void _showNotifications(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.notifications, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _notifTile(Icons.check_circle, Colors.green, l10n.bookingConfirmed, l10n.bookingConfirmedMsg),
            _notifTile(Icons.info_outline, Colors.blue, l10n.newExperience, l10n.newExperienceMsg),
            _notifTile(Icons.warning_amber_rounded, Colors.orange, l10n.paymentPending, l10n.paymentPendingMsg),
          ],
        ),
      ),
    );
  }

  Widget _notifTile(IconData icon, Color color, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB 0 — Home
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildHomeTab() {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filtered;
    final catLabels = _categoryLabels(l10n);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchExperiences,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: catLabels.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildCategoryChip(e.key, e.value),
            )).toList(),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(l10n.noExperiencesFound))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _buildExperienceCard(ctx, filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String key, String displayLabel) {
    final selected = _selectedCategory == key;
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.12) : Colors.grey[200],
          border: Border.all(color: selected ? primary : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(_categoryIcon(key), size: 16, color: selected ? primary : Colors.grey[600]),
            const SizedBox(width: 6),
            Text(displayLabel, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? primary : Colors.grey[800])),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context, Map<String, dynamic> exp) {
    final l10n = AppLocalizations.of(context)!;
    final price = exp['priceRWF'] as double;
    final isVerified = exp['verified'] as bool;
    final bg = Color(exp['color'] as int);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            width: double.infinity,
            color: bg.withOpacity(0.08),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.landscape, size: 48, color: bg.withOpacity(0.3)),
                ),
                if (isVerified)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.verified, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Verified', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(exp['description'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: bg),
                    const SizedBox(width: 4),
                    Text(exp['location'], style: const TextStyle(fontSize: 12)),
                    const Spacer(),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Text('${exp['rating']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(' (${exp['reviewCount']})', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${l10n.price}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('RWF ${price.toStringAsFixed(0)}', style: TextStyle(color: bg, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(exp['duration'], style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String key) {
    switch (key) {
      case 'Nature':
        return Icons.emoji_nature;
      case 'Culture':
        return Icons.museum;
      case 'Food & Drink':
        return Icons.local_cafe;
      case 'Adventure':
        return Icons.hiking;
      default:
        return Icons.category;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB 1 — Explore (placeholder)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildExploreTab() {
    final l10n = AppLocalizations.of(context)!;
    return Center(child: Text(l10n.exploreTab));
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB 2 — Bookings
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildBookingsTab() {
    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _kBookings.length,
      itemBuilder: (ctx, i) {
        final booking = _kBookings[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(booking['title']),
            subtitle: Text('${booking['date']} • ${booking['participants']} ${l10n.participants}'),
            trailing: Text('${booking['total']} RWF', style: const TextStyle(fontWeight: FontWeight.bold)),
            leading: Icon(
              booking['status'] == 'confirmed'
                  ? Icons.check_circle
                  : booking['status'] == 'completed'
                      ? Icons.done_all
                      : Icons.hourglass_empty,
              color: booking['status'] == 'confirmed'
                  ? Colors.green
                  : booking['status'] == 'completed'
                      ? Colors.blue
                      : Colors.orange,
            ),
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB 3 — Impact (placeholder)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildImpactTab() {
    final l10n = AppLocalizations.of(context)!;
    return Center(child: Text(l10n.impactTab));
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB 4 — Profile (placeholder)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildProfileTab() {
    final l10n = AppLocalizations.of(context)!;
    return Center(child: Text(l10n.profileTab));
  }
}
              ),
            ),
          ),
        ),

        // Categories
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip('All', true),
              _buildCategoryChip('Nature', false),
              _buildCategoryChip('Culture', false),
              _buildCategoryChip('Food & Drink', false),
              _buildCategoryChip('Adventure', false),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Experiences List
        Expanded(
          child: BlocBuilder<ExperienceBloc, ExperienceState>(
            builder: (context, state) {
              if (state is ExperienceLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ExperienceError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<ExperienceBloc>()
                              .add(const LoadExperiences());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (state is ExperiencesLoaded) {
                if (state.experiences.isEmpty) {
                  return const Center(child: Text('No experiences available'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.experiences.length,
                  itemBuilder: (context, index) {
                    final exp =
                        state.experiences[index].data() as Map<String, dynamic>;
                    return _buildExperienceCard(
                        context, exp, state.experiences[index].id);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
        backgroundColor: Colors.grey[800],
        selectedColor: Colors.green,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(
      BuildContext context, Map<String, dynamic> exp, String id) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[700],
                child:
                    const Icon(Icons.landscape, size: 64, color: Colors.grey),
              ),
              if (exp['verificationBadges']?.isNotEmpty ?? false)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified,
                            size: 16, color: Colors.white),
                        import 'package:firebase_auth/firebase_auth.dart';
                        import 'package:flutter/material.dart';
                        import 'package:flutter_bloc/flutter_bloc.dart';
                        import 'package:go_router/go_router.dart';
                        import '../../../core/cubits/settings_cubit.dart';
                        import '../../../core/routes/route_names.dart';
                        import '../../../data/repositories/auth_repository.dart';
                        import '../../shared/theme/theme_cubit.dart';
                        import '../../../l10n/app_localizations.dart';

                        // ─────────────────────────────────────────────
                        // Static experience data
                        // ─────────────────────────────────────────────
                        final _kExperiences = <Map<String, dynamic>>[
                          {
                            'id': 'exp1',
                            'title': 'Gorilla Trekking Experience',
                            'category': 'Adventure',
                            'description':
                                'Trek through lush rainforests to encounter endangered mountain gorillas in their natural habitat. Led by expert RDB-certified guides.',
                            'priceRWF': 95000.0,
                            'rating': 4.9,
                            'reviewCount': 127,
                            'location': 'Volcanoes National Park',
                            'duration': '6–8 hours',
                            'verified': true,
                            'color': 0xFF1B5E20,
                          },
                          {
                            'id': 'exp2',
                            'title': 'Traditional Intore Dance Workshop',
                            'category': 'Culture',
                            'description':
                                'Learn the powerful Intore dance — a UNESCO-recognised cultural heritage of Rwanda — performed by skilled local artists.',
                            'priceRWF': 15000.0,
                            'rating': 4.8,
                            'reviewCount': 89,
                            'location': 'Kigali Cultural Center',
                            'duration': '2 hours',
                            'verified': true,
                            'color': 0xFF4A148C,
                          },
                          {
                            'id': 'exp3',
                            'title': 'Coffee Farm Tour & Tasting',
                            'category': 'Food & Drink',
                            'description':
                                "Visit a local coffee cooperative and learn about Rwanda's famous single-origin coffee, from bean to cup.",
                            'priceRWF': 20000.0,
                            'rating': 4.7,
                            'reviewCount': 56,
                            'location': 'Huye District',
                            'duration': '3 hours',
                            'verified': false,
                            'color': 0xFF4E342E,
                          },
                          {
                            'id': 'exp4',
                            'title': 'Nyungwe Forest Canopy Walk',
                            'category': 'Nature',
                            'description':
                                "Walk 70 m above the ground on a suspension bridge through one of Africa's oldest rainforests, full of primates and birds.",
                            'priceRWF': 25000.0,
                            'rating': 4.6,
                            'reviewCount': 203,
                            'location': 'Nyungwe National Park',
                            'duration': '4 hours',
                            'verified': true,
                            'color': 0xFF2E7D32,
                          },
                          {
                            'id': 'exp5',
                            'title': 'Lake Kivu Sunset Cruise',
                            'category': 'Nature',
                            'description':
                                'Sail on beautiful Lake Kivu while watching the sunset over the Congo Nile Trail mountains with local fishermen.',
                            'priceRWF': 18000.0,
                            'rating': 4.5,
                            'reviewCount': 78,
                            'location': 'Gisenyi, Lake Kivu',
                            'duration': '2 hours',
                            'verified': false,
                            'color': 0xFF01579B,
                          },
                          {
                            'id': 'exp6',
                            'title': 'Kigali City Heritage Tour',
                            'category': 'Culture',
                            'description':
                                "Explore Kigali's transformation — from the Genocide Memorial to bustling Kimironko Market — with knowledgeable local guides.",
                            'priceRWF': 12000.0,
                            'rating': 4.7,
                            'reviewCount': 145,
                            'location': 'Kigali City',
                            'duration': '3 hours',
                            'verified': true,
                            'color': 0xFFE65100,
                          },
                        ];

                        // Static past / upcoming bookings shown on the Bookings tab
                        final _kBookings = <Map<String, dynamic>>[
                          {
                            'id': 'BK-001',
                            'title': 'Gorilla Trekking Experience',
                            'date': 'April 15, 2026',
                            'participants': 2,
                            'total': 190000,
                            'status': 'confirmed',
                          },
                          {
                            'id': 'BK-002',
                            'title': 'Coffee Farm Tour & Tasting',
                            'date': 'March 28, 2026',
                            'participants': 3,
                            'total': 60000,
                            'status': 'completed',
                          },
                          {
                            'id': 'BK-003',
                            'title': 'Lake Kivu Sunset Cruise',
                            'date': 'April 22, 2026',
                            'participants': 4,
                            'total': 72000,
                            'status': 'pending',
                          },
                        ];

                        // ─────────────────────────────────────────────
                        // HomeScreen — 5-tab shell
                        // ─────────────────────────────────────────────
                        class HomeScreen extends StatefulWidget {
                          const HomeScreen({super.key});

                          @override
                          State<HomeScreen> createState() => _HomeScreenState();
                        }

                        class _HomeScreenState extends State<HomeScreen> {
                          int _selectedIndex = 0;
                          String _searchQuery = '';
                          // Internal filter key stays in English to match experience data
                          String _selectedCategory = 'All';
                          final _searchController = TextEditingController();

                          List<String> _tabTitles(AppLocalizations l10n) => [
                                l10n.discoverRwanda,
                                l10n.explore,
                                l10n.myBookings,
                                l10n.yourImpact,
                                l10n.profileTab,
                              ];

                          // Maps internal English key -> localized display label
                          Map<String, String> _categoryLabels(AppLocalizations l10n) => {
                                'All': l10n.categoryAll,
                                'Nature': l10n.categoryNature,
                                'Culture': l10n.categoryCulture,
                                'Food & Drink': l10n.categoryFoodDrink,
                                'Adventure': l10n.categoryAdventure,
                              };

                          @override
                          void initState() {
                            super.initState();
                            _redirectProviderOnRestart();
                          }

                          Future<void> _redirectProviderOnRestart() async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;
                            final profile = await AuthRepository().getUserProfile(user.uid);
                            final role = (profile?['accountType'] as String?) ?? 'tourist';
                            if (role == 'provider' && mounted) {
                              context.go(RouteNames.provider);
                            }
                          }

                          @override
                          void dispose() {
                            _searchController.dispose();
                            super.dispose();
                          }

                          List<Map<String, dynamic>> get _filtered {
                            return _kExperiences.where((exp) {
                              final matchSearch = _searchQuery.isEmpty ||
                                  (exp['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                  (exp['description'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
                              final matchCat =
                                  _selectedCategory == 'All' || exp['category'] == _selectedCategory;
                              return matchSearch && matchCat;
                            }).toList();
                          }

                          @override
                          Widget build(BuildContext context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Scaffold(
                              appBar: AppBar(
                                title: Text(_tabTitles(l10n)[_selectedIndex]),
                                actions: [
                                  if (_selectedIndex == 0)
                                    IconButton(
                                      icon: const Icon(Icons.notifications_none),
                                      onPressed: () => _showNotifications(context),
                                    ),
                                ],
                              ),
                              body: IndexedStack(
                                index: _selectedIndex,
                                children: [
                                  _buildHomeTab(),
                                  _buildExploreTab(),
                                  _buildBookingsTab(),
                                  _buildImpactTab(),
                                  _buildProfileTab(),
                                ],
                              ),
                              bottomNavigationBar: BottomNavigationBar(
                                currentIndex: _selectedIndex,
                                onTap: (i) => setState(() => _selectedIndex = i),
                                items: [
                                  BottomNavigationBarItem(
                                    icon: const Icon(Icons.home),
                                    label: l10n.homeTab,
                                  ),
                                  BottomNavigationBarItem(
                                    icon: const Icon(Icons.explore),
                                    label: l10n.exploreTab,
                                  ),
                                  BottomNavigationBarItem(
                                    icon: const Icon(Icons.book_online),
                                    label: l10n.bookingsTab,
                                  ),
                                  BottomNavigationBarItem(
                                    icon: const Icon(Icons.emoji_nature),
                                    label: l10n.impactTab,
                                  ),
                                  BottomNavigationBarItem(
                                    icon: const Icon(Icons.person),
                                    label: l10n.profileTab,
                                  ),
                                ],
                              ),
                            );
                          }

                          // ══════════════════════════════════════════════════════════
                          // Notifications bottom sheet
                          // ══════════════════════════════════════════════════════════

                          void _showNotifications(BuildContext context) {
                            final l10n = AppLocalizations.of(context)!;
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (_) => Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.notifications, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(height: 16),
                                    _notifTile(Icons.check_circle, Colors.green, l10n.bookingConfirmed, l10n.bookingConfirmedMsg),
                                    _notifTile(Icons.info_outline, Colors.blue, l10n.newExperience, l10n.newExperienceMsg),
                                    _notifTile(Icons.warning_amber_rounded, Colors.orange, l10n.paymentPending, l10n.paymentPendingMsg),
                                  ],
                                ),
                              ),
                            );
                          }

                          Widget _notifTile(IconData icon, Color color, String title, String subtitle) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.15),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(subtitle),
                            );
                          }

                          // ══════════════════════════════════════════════════════════
                          // TAB 0 — Home
                          // ══════════════════════════════════════════════════════════

                          Widget _buildHomeTab() {
                            final l10n = AppLocalizations.of(context)!;
                            final filtered = _filtered;
                            final catLabels = _categoryLabels(l10n);
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: l10n.searchExperiences,
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      isDense: true,
                                    ),
                                    onChanged: (v) => setState(() => _searchQuery = v),
                                  ),
                                ),
                                SizedBox(
                                  height: 44,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    children: catLabels.entries.map((e) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: _buildCategoryChip(e.key, e.value),
                                    )).toList(),
                                  ),
                                ),
                                Expanded(
                                  child: filtered.isEmpty
                                      ? Center(child: Text(l10n.noExperiencesFound))
                                      : ListView.builder(
                                          padding: const EdgeInsets.all(16),
                                          itemCount: filtered.length,
                                          itemBuilder: (ctx, i) => _buildExperienceCard(ctx, filtered[i]),
                                        ),
                                ),
                              ],
                            );
                          }

                          Widget _buildCategoryChip(String key, String displayLabel) {
                            final selected = _selectedCategory == key;
                            final primary = Theme.of(context).colorScheme.primary;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedCategory = key),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected ? primary.withOpacity(0.12) : Colors.grey[200],
                                  border: Border.all(color: selected ? primary : Colors.transparent, width: 2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(_categoryIcon(key), size: 16, color: selected ? primary : Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Text(displayLabel, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? primary : Colors.grey[800])),
                                  ],
                                ),
                              ),
                            );
                          }

                          Widget _buildExperienceCard(BuildContext context, Map<String, dynamic> exp) {
                            final l10n = AppLocalizations.of(context)!;
                            final price = exp['priceRWF'] as double;
                            final isVerified = exp['verified'] as bool;
                            final bg = Color(exp['color'] as int);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 90,
                                    width: double.infinity,
                                    color: bg,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: 12,
                                          top: 12,
                                          child: _badge(l10n.verified, Colors.green, icon: Icons.verified),
                                        ),
                                        Positioned(
                                          left: 12,
                                          bottom: 12,
                                          child: Text(exp['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(exp['description'] as String, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(exp['location'] as String, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                            const SizedBox(width: 14),
                                            Icon(Icons.timer_outlined, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(exp['duration'] as String, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('RWF ${_fmt(price)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            if (isVerified) _badge(l10n.verified, Colors.green, icon: Icons.verified),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          Widget _badge(String text, Color bg, {IconData? icon}) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: bg.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (icon != null) ...[
                                    Icon(icon, size: 14, color: bg),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(text, style: TextStyle(color: bg, fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            );
                          }

                          IconData _categoryIcon(String cat) {
                            switch (cat) {
                              case 'Adventure':
                                return Icons.hiking;
                              case 'Culture':
                                return Icons.museum;
                              case 'Food & Drink':
                                return Icons.coffee;
                              case 'Nature':
                                return Icons.forest;
                              default:
                                return Icons.category;
                            }
                          }

                          String _fmt(double price) {
                            if (price >= 1000) {
                              final k = price / 1000;
                              return ' {k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}K';
                            }
                            return price.toStringAsFixed(0);
                          }

                          // ══════════════════════════════════════════════════════════
                          // TAB 1 — Explore
                          // ══════════════════════════════════════════════════════════

                          Widget _buildExploreTab() {
                            final l10n = AppLocalizations.of(context)!;
                            final topRated = _kExperiences
                                .where((e) => (e['rating'] as double) >= 4.7)
                                .toList();

                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionHeader(l10n.topRated, null, l10n),
                                  SizedBox(
                                    height: 220,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: topRated.length,
                                      itemBuilder: (ctx, i) => _featuredCard(ctx, topRated[i]),
                                    ),
                                  ),
                                  // ... add more sections as needed
                                ],
                              ),
                            );
                          }

                          Widget _statPill(IconData icon, String value, String label) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(icon, size: 16, color: Colors.grey[700]),
                                  const SizedBox(width: 6),
                                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  Text(label, style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            );
                          }

                          Widget _sectionHeader(String title, VoidCallback? onSeeAll, AppLocalizations l10n) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  if (onSeeAll != null)
                                    TextButton(onPressed: onSeeAll, child: Text(l10n.seeAll)),
                                ],
                              ),
                            );
                          }

                          Widget _featuredCard(BuildContext context, Map<String, dynamic> exp) {
                            return GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 180,
                                margin: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
                                decoration: BoxDecoration(
                                  color: Color(exp['color'] as int).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Color(exp['color'] as int),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(exp['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text('RWF ${_fmt(exp['priceRWF'] as double)}', style: const TextStyle(color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          Widget _destTile(String name, IconData icon, int color, String sub) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(color).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(icon, color: Color(color), size: 28),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(sub, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }

                          Widget _tipCard(IconData icon, String title, String body) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: ListTile(
                                leading: Icon(icon, color: Colors.blue),
                                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(body),
                              ),
                            );
                          }

                          // ══════════════════════════════════════════════════════════
                          // TAB 2 — Bookings
                          // ══════════════════════════════════════════════════════════

                          Widget _buildBookingsTab() {
                            final l10n = AppLocalizations.of(context)!;
                            return ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                Row(
                                  children: [
                                    _bookingStat(l10n.upcoming, '1', Colors.blue),
                                    _bookingStat(l10n.completed, '1', Colors.green),
                                    _bookingStat(l10n.pending, '1', Colors.orange),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ..._kBookings.map(_buildBookingCard).toList(),
                              ],
                            );
                          }

                          Widget _bookingStat(String label, String count, Color color) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(count, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Text(label, style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          }

                          Widget _buildBookingCard(Map<String, dynamic> b) {
                            final status = b['status'] as String;
                            final colorMap = {
                              'confirmed': Colors.blue,
                              'completed': Colors.green,
                              'pending': Colors.orange,
                            };
                            final iconMap = {
                              'confirmed': Icons.check_circle,
                              'completed': Icons.verified,
                              'pending': Icons.hourglass_bottom,
                            };
                            final sc = colorMap[status] ?? Colors.grey;
                            final si = iconMap[status] ?? Icons.info;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              child: ListTile(
                                leading: Icon(si, color: sc),
                                title: Text(b['title'] as String),
                                subtitle: Text('${b['date']} · ${b['participants']} people'),
                                trailing: Text('RWF ${_fmt(b['total'].toDouble())}', style: TextStyle(color: sc, fontWeight: FontWeight.bold)),
                              ),
                            );
                          }

                          // ══════════════════════════════════════════════════════════
                          // TAB 3 — Impact
                          // ══════════════════════════════════════════════════════════

                          Widget _buildImpactTab() {
                            final l10n = AppLocalizations.of(context)!;
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _statCard(Icons.eco, '12', l10n.treesPlanted, Colors.green),
                                  _statCard(Icons.people, '48', l10n.localJobs, Colors.blue),
                                  _statCard(Icons.volunteer_activism, '5', l10n.ngoSupported, Colors.orange),
                                  const SizedBox(height: 24),
                                  Text(l10n.impactBreakdown, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  _impactBar(l10n.environment, 0.5, Colors.green),
                                  _impactBar(l10n.community, 0.3, Colors.blue),
                                  _impactBar(l10n.economy, 0.2, Colors.orange),
                                ],
                              ),
                            );
                          }

                          Widget _statCard(IconData icon, String value, String label, Color color) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Icon(icon, color: color),
                                title: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                                subtitle: Text(label),
                              ),
                            );
                          }

                          Widget _impactBar(String label, double pct, Color color) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  SizedBox(width: 80, child: Text(label)),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: pct,
                                          child: Container(
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // ══════════════════════════════════════════════════════════
                          // TAB 4 — Profile
                          // ══════════════════════════════════════════════════════════

                          Widget _buildProfileTab() {
                            final l10n = AppLocalizations.of(context)!;
                            final firebaseUser = FirebaseAuth.instance.currentUser;
                            final displayName = firebaseUser?.displayName ?? 'User';
                            final email = firebaseUser?.email ?? '';

                            final isDark =
                                context.watch<ThemeCubit>().state == ThemeMode.dark;
                            return BlocBuilder<SettingsCubit, SettingsState>(
                              builder: (context, state) {
                                return ListView(
                                  padding: const EdgeInsets.all(16),
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        child: Text(displayName.isNotEmpty ? displayName[0] : 'U'),
                                      ),
                                      title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(email),
                                    ),
                                    const SizedBox(height: 16),
                                    _groupLabel(l10n.account),
                                    ListTile(
                                      leading: const Icon(Icons.person),
                                      title: Text(l10n.profile),
                                      onTap: () => _showProfileDialog(context),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.support_agent),
                                      title: Text(l10n.support),
                                      onTap: () => _showSupportDialog(context),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.info_outline),
                                      title: Text(l10n.about),
                                      onTap: () => _showAboutDialog(context),
                                    ),
                                    const SizedBox(height: 16),
                                    _groupLabel(l10n.settings),
                                    SwitchListTile(
                                      value: isDark,
                                      onChanged: (v) => context.read<ThemeCubit>().toggleTheme(),
                                      title: Text(l10n.darkMode),
                                      secondary: const Icon(Icons.dark_mode),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.logout),
                                      title: Text(l10n.logout),
                                      onTap: () => _confirmLogout(context),
                                    ),
                                  ],
                                );
                              },
                            );
                          }

                          Widget _groupLabel(String label) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            );
                          }

                          void _showProfileDialog(BuildContext ctx) {
                            final l10n = AppLocalizations.of(ctx)!;
                            final user = FirebaseAuth.instance.currentUser;
                            final name = user?.displayName?.isNotEmpty == true
                                ? user!.displayName!
                                : 'User';
                            final email = user?.email ?? '—';

                            showDialog(
                              context: ctx,
                              builder: (_) => AlertDialog(
                                title: Text(l10n.profile),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Name: $name'),
                                    Text('Email: $email'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(l10n.close),
                                  ),
                                ],
                              ),
                            );
                          }

                          void _showSupportDialog(BuildContext ctx) {
                            final l10n = AppLocalizations.of(ctx)!;
                            showDialog(
                              context: ctx,
                              builder: (_) => AlertDialog(
                                title: Text(l10n.support),
                                content: Text(l10n.supportMsg),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(l10n.close),
                                  ),
                                ],
                              ),
                            );
                          }

                          void _showAboutDialog(BuildContext ctx) {
                            showAboutDialog(
                              context: ctx,
                              applicationName: 'Afrivoyage',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2026 Afrivoyage',
                            );
                          }

                          void _confirmLogout(BuildContext ctx) {
                            final l10n = AppLocalizations.of(ctx)!;
                            showDialog(
                              context: ctx,
                              builder: (_) => AlertDialog(
                                title: Text(l10n.logout),
                                content: Text(l10n.logoutConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(l10n.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      if (ctx.mounted) Navigator.pop(ctx);
                                    },
                                    child: Text(l10n.logout),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                        ),
                        Text(
                          'per person',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/booking/$id');
                      },
                      child: const Text('Book Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Text('Coming Soon', style: TextStyle(fontSize: 24)),
    );
  }
}
=======
import 'package:flutter/material.dart';
import '../../data/seed/seed_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/experience_repository.dart';
import '../blocs/experience_bloc.dart';
// If you want to add static demo data, you can add it here, but the Bloc-based dynamic loading is preferred for production/demo.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExperienceBloc(
        experienceRepository: ExperienceRepository(),
        bookingRepository: BookingRepository(),
      )..add(const LoadExperiences()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Rwanda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildHomeContent() : _buildPlaceholder(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Impact',
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

  Widget _buildHomeContent() {
    return Column(
      children: [
        // TEMP: Seed data button for demo
        const SeedDataButton(),
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search experiences...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Categories
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip('All', true),
              _buildCategoryChip('Nature', false),
              _buildCategoryChip('Culture', false),
              _buildCategoryChip('Food & Drink', false),
              _buildCategoryChip('Adventure', false),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Experiences List
        Expanded(
          child: BlocBuilder<ExperienceBloc, ExperienceState>(
            builder: (context, state) {
              if (state is ExperienceLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ExperienceError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<ExperienceBloc>()
                              .add(const LoadExperiences());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (state is ExperiencesLoaded) {
                if (state.experiences.isEmpty) {
                  return const Center(child: Text('No experiences available'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.experiences.length,
                  itemBuilder: (context, index) {
                    final exp =
                        state.experiences[index].data() as Map<String, dynamic>;
                    return _buildExperienceCard(
                        context, exp, state.experiences[index].id);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
        backgroundColor: Colors.grey[800],
        selectedColor: Colors.green,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(
      BuildContext context, Map<String, dynamic> exp, String id) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[700],
                child:
                    const Icon(Icons.landscape, size: 64, color: Colors.grey),
              ),
              if (exp['verificationBadges']?.isNotEmpty ?? false)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exp['title'] ?? 'Experience',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${exp['rating'] ?? 0.0}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' (${exp['reviewCount'] ?? 0})',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Rwanda',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  exp['description'] ?? 'No description available',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[300]),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RWF ${exp['priceRWF']?.toStringAsFixed(0) ?? '0'}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                        ),
                        Text(
                          'per person',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/booking/$id');
                      },
                      child: const Text('Book Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Text('Coming Soon', style: TextStyle(fontSize: 24)),
    );
  }
}
=======
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/cubits/settings_cubit.dart';
import '../../../core/routes/route_names.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../shared/theme/theme_cubit.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────
// Static experience data
// ─────────────────────────────────────────────
final _kExperiences = <Map<String, dynamic>>[
  {
    'id': 'exp1',
    'title': 'Gorilla Trekking Experience',
    'category': 'Adventure',
    'description':
        'Trek through lush rainforests to encounter endangered mountain gorillas in their natural habitat. Led by expert RDB-certified guides.',
    'priceRWF': 95000.0,
    'rating': 4.9,
    'reviewCount': 127,
    'location': 'Volcanoes National Park',
    'duration': '6–8 hours',
    'verified': true,
    'color': 0xFF1B5E20,
  },
  {
    'id': 'exp2',
    'title': 'Traditional Intore Dance Workshop',
    'category': 'Culture',
    'description':
        'Learn the powerful Intore dance — a UNESCO-recognised cultural heritage of Rwanda — performed by skilled local artists.',
    'priceRWF': 15000.0,
    'rating': 4.8,
    'reviewCount': 89,
    'location': 'Kigali Cultural Center',
    'duration': '2 hours',
    'verified': true,
    'color': 0xFF4A148C,
  },
  {
    'id': 'exp3',
    'title': 'Coffee Farm Tour & Tasting',
    'category': 'Food & Drink',
    'description':
        'Visit a local coffee cooperative and learn about Rwanda\'s famous single-origin coffee, from bean to cup.',
    'priceRWF': 20000.0,
    'rating': 4.7,
    'reviewCount': 56,
    'location': 'Huye District',
    'duration': '3 hours',
    'verified': false,
    'color': 0xFF4E342E,
  },
  {
    'id': 'exp4',
    'title': 'Nyungwe Forest Canopy Walk',
    'category': 'Nature',
    'description':
        'Walk 70 m above the ground on a suspension bridge through one of Africa\'s oldest rainforests, full of primates and birds.',
    'priceRWF': 25000.0,
    'rating': 4.6,
    'reviewCount': 203,
    'location': 'Nyungwe National Park',
    'duration': '4 hours',
    'verified': true,
    'color': 0xFF2E7D32,
  },
  {
    'id': 'exp5',
    'title': 'Lake Kivu Sunset Cruise',
    'category': 'Nature',
    'description':
        'Sail on beautiful Lake Kivu while watching the sunset over the Congo Nile Trail mountains with local fishermen.',
    'priceRWF': 18000.0,
    'rating': 4.5,
    'reviewCount': 78,
    'location': 'Gisenyi, Lake Kivu',
    'duration': '2 hours',
    'verified': false,
    'color': 0xFF01579B,
  },
  {
    'id': 'exp6',
    'title': 'Kigali City Heritage Tour',
    'category': 'Culture',
    'description':
        'Explore Kigali\'s transformation — from the Genocide Memorial to bustling Kimironko Market — with knowledgeable local guides.',
    'priceRWF': 12000.0,
    'rating': 4.7,
    'reviewCount': 145,
    'location': 'Kigali City',
    'duration': '3 hours',
    'verified': true,
    'color': 0xFFE65100,
  },
];

// Static past / upcoming bookings shown on the Bookings tab
final _kBookings = <Map<String, dynamic>>[
  {
    'id': 'BK-001',
    'title': 'Gorilla Trekking Experience',
    'date': 'April 15, 2026',
    'participants': 2,
    'total': 190000,
    'status': 'confirmed',
  },
  {
    'id': 'BK-002',
    'title': 'Coffee Farm Tour & Tasting',
    'date': 'March 28, 2026',
    'participants': 3,
    'total': 60000,
    'status': 'completed',
  },
  {
    'id': 'BK-003',
    'title': 'Lake Kivu Sunset Cruise',
    'date': 'April 22, 2026',
    'participants': 4,
    'total': 72000,
    'status': 'pending',
  },
];

// ─────────────────────────────────────────────
// HomeScreen — 5-tab shell
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  // Internal filter key stays in English to match experience data
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  List<String> _tabTitles(AppLocalizations l10n) => [
        l10n.discoverRwanda,
        l10n.explore,
        l10n.myBookings,
        l10n.yourImpact,
        l10n.profileTab,
      ];

  // Maps internal English key -> localized display label
  Map<String, String> _categoryLabels(AppLocalizations l10n) => {
        'All': l10n.categoryAll,
        'Nature': l10n.categoryNature,
        'Culture': l10n.categoryCulture,
        'Food & Drink': l10n.categoryFoodDrink,
        'Adventure': l10n.categoryAdventure,
      };

  @override
  void initState() {
    super.initState();
    _redirectProviderOnRestart();
  }

  Future<void> _redirectProviderOnRestart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final profile = await AuthRepository().getUserProfile(user.uid);
    final role = (profile?['accountType'] as String?) ?? 'tourist';
    if (role == 'provider' && mounted) {
      context.go(RouteNames.provider);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    return _kExperiences.where((exp) {
      final matchSearch = _searchQuery.isEmpty ||
          (exp['title'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (exp['location'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchCat =
          _selectedCategory == 'All' || exp['category'] == _selectedCategory;
      return matchSearch && matchCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles(l10n)[_selectedIndex]),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _showNotifications(context),
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildExploreTab(),
          _buildBookingsTab(),
          _buildImpactTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore),
            label: l10n.navExplore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: l10n.navBookings,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_outline),
            activeIcon: const Icon(Icons.favorite),
            label: l10n.navImpact,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Notifications bottom sheet
  // ══════════════════════════════════════════════════════════

  void _showNotifications(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.notifications,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _notifTile(
                Icons.check_circle,
                Colors.green,
                l10n.bookingConfirmedNotif,
                'Gorilla Trekking on Apr 15 is confirmed!'),
            _notifTile(Icons.star, Colors.amber, l10n.newReview,
                'Your Coffee Farm Tour received a 5-star review.'),
            _notifTile(Icons.info_outline, Colors.blue, l10n.reminder,
                'Lake Kivu Cruise in 3 days. Don\'t forget sunscreen!'),
          ],
        ),
      ),
    );
  }

  Widget _notifTile(IconData icon, Color color, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    );
  }

  // ══════════════════════════════════════════════════════════
  // TAB 0 — Home
  // ══════════════════════════════════════════════════════════

  Widget _buildHomeTab() {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filtered;
    final catLabels = _categoryLabels(l10n);
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Category chips — internal keys stay English, display uses l10n
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              'All',
              'Nature',
              'Culture',
              'Food & Drink',
              'Adventure',
            ]
                .map((key) => _buildCategoryChip(key, catLabels[key] ?? key))
                .toList(),
          ),
        ),
        const SizedBox(height: 6),
        // Results
        if (filtered.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 56, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(l10n.noExperiencesFound,
                      style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = 'All';
                      });
                    },
                    child: Text(l10n.clearFilters),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: filtered.length,
              itemBuilder: (context, i) =>
                  _buildExperienceCard(context, filtered[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip(String key, String displayLabel) {
    final selected = _selectedCategory == key;
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          border: Border.all(color: selected ? primary : Colors.grey),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          displayLabel,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[600],
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context, Map<String, dynamic> exp) {
    final l10n = AppLocalizations.of(context)!;
    final price = exp['priceRWF'] as double;
    final isVerified = exp['verified'] as bool;
    final bg = Color(exp['color'] as int);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder with colour + icon
          Stack(
            children: [
              Container(
                height: 175,
                width: double.infinity,
                color: bg,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_categoryIcon(exp['category'] as String),
                        size: 52, color: Colors.white38),
                    const SizedBox(height: 6),
                    Text(exp['location'] as String,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              // Category tag
              Positioned(
                top: 10,
                left: 10,
                child: _badge(exp['category'] as String, Colors.black45),
              ),
              // Verified badge
              if (isVerified)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _badge(l10n.verified, Colors.green, icon: Icons.verified),
                    ],
                  ),
                ),
              // Duration tag bottom-right
              Positioned(
                bottom: 10,
                right: 10,
                child: _badge('⏱ ${exp['duration']}', Colors.black45),
              ),
            ],
          ),
          // Info section
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        exp['title'] as String,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 15),
                        const SizedBox(width: 2),
                        Text('${exp['rating']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(' (${exp['reviewCount']})',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 3),
                    Text(exp['location'] as String,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  exp['description'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RWF ${_fmt(price)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(l10n.perPerson,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/booking/${exp['id']}'),
                        icon: const Icon(Icons.calendar_month, size: 15),
                        label: Text(l10n.bookNow),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 3),
          ],
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Adventure':
        return Icons.hiking;
      case 'Culture':
        return Icons.museum;
      case 'Food & Drink':
        return Icons.coffee;
      case 'Nature':
        return Icons.forest;
      default:
        return Icons.landscape;
    }
  }

  String _fmt(double price) {
    if (price >= 1000) {
      final k = price / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}K';
    }
    return price.toStringAsFixed(0);
  }

  // ══════════════════════════════════════════════════════════
  // TAB 1 — Explore
  // ══════════════════════════════════════════════════════════

  Widget _buildExploreTab() {
    final l10n = AppLocalizations.of(context)!;
    final topRated =
        _kExperiences.where((e) => (e['rating'] as double) >= 4.7).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.exploreRwanda,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text(l10n.landOfThousandHills,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statPill(Icons.landscape, '1,000+', 'Hills'),
                    const SizedBox(width: 8),
                    _statPill(Icons.people, '14M+', 'Locals'),
                    const SizedBox(width: 8),
                    _statPill(Icons.star, '4.8', 'Avg rating'),
                  ],
                ),
              ],
            ),
          ),

          // Top Rated
          _sectionHeader(l10n.topRatedExperiences, () {
            setState(() {
              _selectedIndex = 0;
              _selectedCategory = 'All';
            });
          }, l10n),
          SizedBox(
            height: 175,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: topRated.map((e) => _featuredCard(context, e)).toList(),
            ),
          ),

          const SizedBox(height: 24),
          _sectionHeader(l10n.destinations, null, l10n),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _destTile('Kigali', Icons.location_city, 0xFF1565C0,
                    'Culture & History'),
                _destTile('Volcanoes NP', Icons.terrain, 0xFF1B5E20,
                    'Gorillas & Trekking'),
                _destTile('Nyungwe', Icons.forest, 0xFF2E7D32,
                    'Rainforest & Primates'),
                _destTile(
                    'Lake Kivu', Icons.water, 0xFF01579B, 'Scenic Beauty'),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionHeader(l10n.travelTips, null, l10n),
          _tipCard(Icons.wb_sunny_outlined, l10n.bestTimeToVisit,
              'June–September (dry season) is ideal for trekking and outdoor activities.'),
          _tipCard(Icons.health_and_safety_outlined, l10n.healthAndSafety,
              'Yellow fever vaccination required. Malaria prophylaxis recommended outside Kigali.'),
          _tipCard(Icons.attach_money, l10n.currencyTip,
              'Rwandan Franc (RWF). Cards accepted in Kigali; carry cash for rural areas.'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text('$value $label',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionHeader(
      String title, VoidCallback? onSeeAll, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: Text(l10n.seeAll)),
        ],
      ),
    );
  }

  Widget _featuredCard(BuildContext context, Map<String, dynamic> exp) {
    return GestureDetector(
      onTap: () => context.push('/booking/${exp['id']}'),
      child: Container(
        width: 145,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Color(exp['color'] as int),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(children: [
              const Icon(Icons.star, color: Colors.amber, size: 12),
              const SizedBox(width: 3),
              Text('${exp['rating']}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            Text(exp['title'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            const SizedBox(height: 2),
            Text('RWF ${_fmt(exp['priceRWF'] as double)}',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _destTile(String name, IconData icon, int color, String sub) {
    return Container(
      decoration: BoxDecoration(
        color: Color(color),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 26),
          const SizedBox(height: 5),
          Text(name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 2),
          Text(sub,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _tipCard(IconData icon, String title, String body) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(body, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // TAB 2 — Bookings
  // ══════════════════════════════════════════════════════════

  Widget _buildBookingsTab() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary row
        Row(
          children: [
            _bookingStat(l10n.upcoming, '2', Colors.blue),
            const SizedBox(width: 10),
            _bookingStat(l10n.completed, '1', Colors.green),
            const SizedBox(width: 10),
            _bookingStat(l10n.pending, '1', Colors.orange),
          ],
        ),
        const SizedBox(height: 20),
        Text(l10n.allBookings,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._kBookings.map(_buildBookingCard),
      ],
    );
  }

  Widget _bookingStat(String label, String count, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(count,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> b) {
    final status = b['status'] as String;
    final colorMap = {
      'confirmed': Colors.blue,
      'completed': Colors.green,
      'pending': Colors.orange,
    };
    final iconMap = {
      'confirmed': Icons.check_circle,
      'completed': Icons.done_all,
      'pending': Icons.hourglass_empty,
    };
    final sc = colorMap[status] ?? Colors.grey;
    final si = iconMap[status] ?? Icons.info;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: sc.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(si, color: sc),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b['title'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    '${b['date']} · ${b['participants']} people',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: sc.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                              color: sc,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'RWF ${_fmt((b['total'] as int).toDouble())}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // TAB 3 — Impact
  // ══════════════════════════════════════════════════════════

  Widget _buildImpactTab() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.green[900],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 34),
                  const SizedBox(height: 12),
                  Text(
                    l10n.yourImpact,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.seeTheDifference,
                    style: TextStyle(color: Colors.green[100]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _statCard(
                      Icons.people, '5', l10n.familiesSupported, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(
                  child: _statCard(Icons.savings, '250K', l10n.localEarnings,
                      Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _statCard(Icons.check_circle, '3',
                      l10n.verifiedBookings, Colors.green)),
              const SizedBox(width: 12),
              Expanded(
                  child: _statCard(
                      Icons.timer, '18', l10n.hoursExperienced, Colors.purple)),
            ],
          ),
          const SizedBox(height: 28),
          Text(l10n.communityImpactBreakdown,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _impactBar(l10n.conservationEfforts, 0.35, Colors.green),
          _impactBar(l10n.localGuideSupport, 0.40, Colors.orange),
          _impactBar(l10n.womensCooperatives, 0.15, Colors.purple),
          _impactBar(l10n.communityDevelopment, 0.10, Colors.blue),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _impactBar(String label, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text('${(pct * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // TAB 4 — Profile
  // ══════════════════════════════════════════════════════════

  Widget _buildProfileTab() {
    final l10n = AppLocalizations.of(context)!;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final displayName = firebaseUser?.displayName?.isNotEmpty == true
        ? firebaseUser!.displayName!
        : 'User';
    final email = firebaseUser?.email ?? '';

    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return ListView(
          children: [
            // User header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(l10n.touristAccount,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Preferences
            _groupLabel(l10n.preferences),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: Text(l10n.darkMode),
              subtitle: Text(l10n.darkModeToggle),
              value: isDark,
              onChanged: (v) => context.read<ThemeCubit>().setThemeMode(
                    v ? ThemeMode.dark : ThemeMode.light,
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text({
                    'en': 'English',
                    'fr': 'Français',
                    'rw': 'Kinyarwanda',
                  }[settings.language] ??
                  'English'),
              trailing: DropdownButton<String>(
                value: settings.language,
                underline: const SizedBox.shrink(),
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsCubit>().setLanguage(v);
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('EN')),
                  DropdownMenuItem(value: 'fr', child: Text('FR')),
                  DropdownMenuItem(value: 'rw', child: Text('RW')),
                ],
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.offline_bolt_outlined),
              title: Text(l10n.offlineMode),
              subtitle: Text(l10n.offlineModeSubtitle),
              value: settings.offlineMode,
              onChanged: (v) =>
                  context.read<SettingsCubit>().toggleOfflineMode(v),
            ),

            const Divider(height: 8),
            _groupLabel(l10n.account),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l10n.myProfile),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _showProfileDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settings),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => context.push(RouteNames.settings),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: Text(l10n.myBookings),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(l10n.helpSupport),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _showSupportDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.aboutAfriVoyage),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _showAboutDialog(context),
            ),

            const Divider(height: 8),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
                  Text(l10n.logout, style: const TextStyle(color: Colors.red)),
              onTap: () => _confirmLogout(context),
            ),

            const SizedBox(height: 24),
            Center(
              child: Text('AfriVoyage v1.0.0 · Group 33',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _groupLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 0.8),
      ),
    );
  }

  void _showProfileDialog(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;
    final user = FirebaseAuth.instance.currentUser;
    final name =
        user?.displayName?.isNotEmpty == true ? user!.displayName! : 'User';
    final email = user?.email ?? '—';

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.myProfile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person),
              title: Text(name),
              subtitle: Text(l10n.tourist),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email),
              title: Text(email),
            ),
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

  void _showSupportDialog(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.helpSupport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.contactUs,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('📧  support@afrivoyage.rw'),
            const SizedBox(height: 4),
            const Text('📞  +250 788 123 456'),
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

  void _showAboutDialog(BuildContext ctx) {
    showAboutDialog(
      context: ctx,
      applicationName: 'AfriVoyage',
      applicationVersion: '1.0.0',
      applicationLegalese:
          '© 2026 AfriVoyage Group 33\nConnecting tourists with authentic Rwanda experiences.',
    );
  }

  void _confirmLogout(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await AuthRepository().signOut();
              // Router redirect handles navigation to /login automatically
              // once Firebase reports the signed-out state.
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
>>>>>>> 29e8a2ecd0fb79f8abafa321d1f4041ac6a965e7
>>>>>>> dbb7d7d377af73e3b9b89c90579575dd55bbcb0f

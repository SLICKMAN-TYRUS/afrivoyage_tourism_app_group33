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
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _notifTile(Icons.check_circle, Colors.green,
                l10n.bookingConfirmedNotif,
                'Gorilla Trekking on Apr 15 is confirmed!'),
            _notifTile(Icons.star, Colors.amber, l10n.newReview,
                'Your Coffee Farm Tour received a 5-star review.'),
            _notifTile(Icons.info_outline, Colors.blue,
                l10n.reminder,
                'Lake Kivu Cruise in 3 days. Don\'t forget sunscreen!'),
          ],
        ),
      ),
    );
  }

  Widget _notifTile(
      IconData icon, Color color, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle:
          Text(subtitle, style: const TextStyle(fontSize: 12)),
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
                .map((key) =>
                    _buildCategoryChip(key, catLabels[key] ?? key))
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
                  Icon(Icons.search_off,
                      size: 56, color: Colors.grey[400]),
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
              padding:
                  const EdgeInsets.fromLTRB(16, 4, 16, 16),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          border:
              Border.all(color: selected ? primary : Colors.grey),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          displayLabel,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[600],
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceCard(
      BuildContext context, Map<String, dynamic> exp) {
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
                    Icon(
                        _categoryIcon(exp['category'] as String),
                        size: 52,
                        color: Colors.white38),
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
                child: _badge(
                    exp['category'] as String, Colors.black45),
              ),
              // Verified badge
              if (isVerified)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _badge(l10n.verified, Colors.green,
                          icon: Icons.verified),
                    ],
                  ),
                ),
              // Duration tag bottom-right
              Positioned(
                bottom: 10,
                right: 10,
                child: _badge(
                    '⏱ ${exp['duration']}', Colors.black45),
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
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 15),
                        const SizedBox(width: 2),
                        Text('${exp['rating']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        Text(' (${exp['reviewCount']})',
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 3),
                    Text(exp['location'] as String,
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  exp['description'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 13),
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
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                          ),
                        ),
                        Text(l10n.perPerson,
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11)),
                      ],
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: ElevatedButton.icon(
                        onPressed: () => context
                            .push('/booking/${exp['id']}'),
                        icon: const Icon(Icons.calendar_month,
                            size: 15),
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
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4),
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
    final topRated = _kExperiences
        .where((e) => (e['rating'] as double) >= 4.7)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 28),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              children: topRated
                  .map((e) => _featuredCard(context, e))
                  .toList(),
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
                _destTile('Kigali', Icons.location_city,
                    0xFF1565C0, 'Culture & History'),
                _destTile('Volcanoes NP', Icons.terrain,
                    0xFF1B5E20, 'Gorillas & Trekking'),
                _destTile('Nyungwe', Icons.forest, 0xFF2E7D32,
                    'Rainforest & Primates'),
                _destTile('Lake Kivu', Icons.water, 0xFF01579B,
                    'Scenic Beauty'),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionHeader(l10n.travelTips, null, l10n),
          _tipCard(Icons.wb_sunny_outlined, l10n.bestTimeToVisit,
              'June–September (dry season) is ideal for trekking and outdoor activities.'),
          _tipCard(Icons.health_and_safety_outlined,
              l10n.healthAndSafety,
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
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
          if (onSeeAll != null)
            TextButton(
                onPressed: onSeeAll,
                child: Text(l10n.seeAll)),
        ],
      ),
    );
  }

  Widget _featuredCard(
      BuildContext context, Map<String, dynamic> exp) {
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
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _destTile(
      String name, IconData icon, int color, String sub) {
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
              style: const TextStyle(
                  color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _tipCard(IconData icon, String title, String body) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ListTile(
        leading: Icon(icon,
            color: Theme.of(context).colorScheme.primary),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(body,
            style: const TextStyle(fontSize: 12)),
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
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold)),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color)),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    '${b['date']} · ${b['participants']} people',
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 12),
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
                            color: Theme.of(context)
                                .colorScheme
                                .primary),
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
                  const Icon(Icons.favorite,
                      color: Colors.white, size: 34),
                  const SizedBox(height: 12),
                  Text(
                    l10n.yourImpact,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
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
                  child: _statCard(Icons.people, '5',
                      l10n.familiesSupported, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(
                  child: _statCard(Icons.savings, '250K',
                      l10n.localEarnings, Colors.orange)),
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
                  child: _statCard(Icons.timer, '18',
                      l10n.hoursExperienced, Colors.purple)),
            ],
          ),
          const SizedBox(height: 28),
          Text(l10n.communityImpactBreakdown,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _impactBar(l10n.conservationEfforts, 0.35, Colors.green),
          _impactBar(l10n.localGuideSupport, 0.40, Colors.orange),
          _impactBar(l10n.womensCooperatives, 0.15, Colors.purple),
          _impactBar(l10n.communityDevelopment, 0.10, Colors.blue),
        ],
      ),
    );
  }

  Widget _statCard(
      IconData icon, String value, String label, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[500], fontSize: 11)),
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
              Text(label,
                  style: const TextStyle(fontSize: 13)),
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
              backgroundColor:
                  Colors.grey.withValues(alpha: 0.2),
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
    final displayName =
        firebaseUser?.displayName?.isNotEmpty == true
            ? firebaseUser!.displayName!
            : 'User';
    final email = firebaseUser?.email ?? '';

    final isDark =
        context.watch<ThemeCubit>().state == ThemeMode.dark;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return ListView(
          children: [
            // User header
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 28, horizontal: 20),
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
                                color: Colors.white70,
                                fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(l10n.touristAccount,
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12)),
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
              onChanged: (v) =>
                  context.read<ThemeCubit>().setThemeMode(
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
              leading: const Icon(Icons.bookmark_outline),
              title: Text(l10n.myBookings),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () =>
                  setState(() => _selectedIndex = 2),
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
              title: Text(l10n.logout,
                  style: const TextStyle(color: Colors.red)),
              onTap: () => _confirmLogout(context),
            ),

            const SizedBox(height: 24),
            Center(
              child: Text('AfriVoyage v1.0.0 · Group 33',
                  style: TextStyle(
                      color: Colors.grey[400], fontSize: 12)),
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
    final name = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : 'User';
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),
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

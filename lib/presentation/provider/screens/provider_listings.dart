import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ProviderListings extends StatefulWidget {
  const ProviderListings({super.key});

  @override
  State<ProviderListings> createState() => _ProviderListingsState();
}

class _ProviderListingsState extends State<ProviderListings> {
  final List<Map<String, dynamic>> _listings = [
    {
      'title': 'Gorilla Trekking Experience',
      'category': 'Nature',
      'price': 95000,
      'rating': 4.9,
      'reviews': 48,
      'bookings': 124,
      'isLive': true,
    },
    {
      'title': 'Coffee Farm Tour & Tasting',
      'category': 'Food & Drink',
      'price': 20000,
      'rating': 4.7,
      'reviews': 32,
      'bookings': 87,
      'isLive': true,
    },
    {
      'title': 'Kigali City Heritage Tour',
      'category': 'Culture',
      'price': 12000,
      'rating': 4.6,
      'reviews': 21,
      'bookings': 55,
      'isLive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myListings),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addExperience,
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: _listings.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.list_alt_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(l10n.noListingsYet,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddDialog(context),
                    child: Text(l10n.addExperience),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _listings.length,
              itemBuilder: (context, index) =>
                  _listingCard(context, index),
            ),
    );
  }

  Widget _listingCard(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    final item = _listings[index];
    final isLive = item['isLive'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.landscape_outlined,
                      color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(item['category'] as String,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.blue)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'RWF ${(item['price'] as int).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')} / ${l10n.person}',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Live / Hidden badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isLive ? Colors.green : Colors.grey)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isLive ? l10n.live : l10n.hidden,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isLive ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Status
            Row(
              children: [
                Icon(
                  isLive ? Icons.circle : Icons.circle_outlined,
                  size: 10,
                  color: isLive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  isLive
                      ? l10n.availableForBooking
                      : l10n.notAcceptingBookings,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLive ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditDialog(context, index),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(l10n.edit),
                ),
                TextButton.icon(
                  onPressed: () => _showStatsDialog(context, index),
                  icon: const Icon(Icons.bar_chart, size: 16),
                  label: Text(l10n.stats),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _showDeleteDialog(context, index),
                  icon: Icon(Icons.delete_outline,
                      size: 16, color: Colors.red[400]),
                  label: Text(l10n.delete,
                      style: TextStyle(color: Colors.red[400])),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedCategory = 'Nature';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.addNewExperience),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleCtrl,
                decoration:
                    InputDecoration(labelText: l10n.titleLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: l10n.priceRwf),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration:
                    InputDecoration(labelText: l10n.categoryLabel),
                items: [
                  l10n.categoryNature,
                  l10n.categoryCulture,
                  l10n.categoryFoodDrink,
                  l10n.categoryAdventure,
                ]
                    .map((c) => DropdownMenuItem(
                        value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedCategory = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty &&
                    priceCtrl.text.isNotEmpty) {
                  setState(() {
                    _listings.add({
                      'title': titleCtrl.text,
                      'category': selectedCategory,
                      'price': int.tryParse(priceCtrl.text) ?? 0,
                      'rating': 0.0,
                      'reviews': 0,
                      'bookings': 0,
                      'isLive': true,
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.experienceAdded)),
                  );
                }
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    final item = _listings[index];
    final titleCtrl =
        TextEditingController(text: item['title'] as String);
    final priceCtrl =
        TextEditingController(text: (item['price'] as int).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editListing),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration:
                  InputDecoration(labelText: l10n.titleLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(labelText: l10n.priceRwf),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                  item['isLive'] as bool ? l10n.live : l10n.hidden),
              value: item['isLive'] as bool,
              onChanged: (v) =>
                  setState(() => _listings[index]['isLive'] = v),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _listings[index]['title'] = titleCtrl.text;
                _listings[index]['price'] =
                    int.tryParse(priceCtrl.text) ?? item['price'];
              });
              Navigator.pop(ctx);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    final item = _listings[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow(l10n.ratingLabel,
                '${item['rating']} ⭐'),
            _statRow(l10n.reviewsLabel,
                '${item['reviews']}'),
            _statRow(l10n.navBookings,
                '${item['bookings']}'),
            _statRow(
              l10n.estMonthlyRevenue,
              'RWF ${((item['bookings'] as int) * (item['price'] as int) * 0.1).toStringAsFixed(0)}',
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close)),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteListing),
        content: Text(
            'Remove "${_listings[index]['title']}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _listings.removeAt(index));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.listingDeleted)),
              );
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey[600])),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

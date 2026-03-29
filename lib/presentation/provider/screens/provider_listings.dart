import 'package:flutter/material.dart';

class ProviderListings extends StatefulWidget {
  const ProviderListings({super.key});

  @override
  State<ProviderListings> createState() => _ProviderListingsState();
}

class _ProviderListingsState extends State<ProviderListings> {
  // Mutable list so toggles and edits reflect in the UI
  final _listings = <Map<String, dynamic>>[
    {
      'id': 'lst1',
      'title': 'Gorilla Trekking Experience',
      'category': 'Adventure',
      'price': '95,000',
      'priceNum': 95000,
      'rating': 4.9,
      'reviews': 127,
      'isAvailable': true,
      'color': 0xFF1B5E20,
    },
    {
      'id': 'lst2',
      'title': 'Traditional Intore Dance Workshop',
      'category': 'Culture',
      'price': '15,000',
      'priceNum': 15000,
      'rating': 4.8,
      'reviews': 89,
      'isAvailable': true,
      'color': 0xFF4A148C,
    },
    {
      'id': 'lst3',
      'title': 'Coffee Farm Tour & Tasting',
      'category': 'Food & Drink',
      'price': '20,000',
      'priceNum': 20000,
      'rating': 4.7,
      'reviews': 56,
      'isAvailable': false,
      'color': 0xFF4E342E,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Experience',
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
                  const SizedBox(height: 12),
                  Text('No listings yet.',
                      style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Experience'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _listings.length,
              itemBuilder: (context, i) =>
                  _buildCard(context, i),
            ),
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    final l = _listings[index];
    final available = l['isAvailable'] as bool;
    final bg = Color(l['color'] as int);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header with colour band ──────────────────
          Container(
            height: 80,
            width: double.infinity,
            color: bg,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l['title'] as String,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // Availability toggle
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Switch(
                      value: available,
                      onChanged: (v) => setState(
                          () => _listings[index]['isAvailable'] = v),
                      activeThumbColor: Colors.white,
                      activeTrackColor:
                          Colors.green.withValues(alpha: 0.8),
                      inactiveThumbColor: Colors.white70,
                      inactiveTrackColor:
                          Colors.grey.withValues(alpha: 0.5),
                    ),
                    Text(
                      available ? 'Live' : 'Hidden',
                      style: TextStyle(
                          color: available
                              ? Colors.greenAccent
                              : Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Details row ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                // Rating
                const Icon(Icons.star,
                    color: Colors.amber, size: 16),
                const SizedBox(width: 3),
                Text('${l['rating']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text(' (${l['reviews']} reviews)',
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 12)),
                const Spacer(),
                // Price
                Text(
                  'RWF ${l['price']} / person',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ],
            ),
          ),

          // Category chip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: bg.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l['category'] as String,
                    style: TextStyle(
                        color: bg,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                // Availability status pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: (available ? Colors.green : Colors.grey)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    available
                        ? 'Available for booking'
                        : 'Not accepting bookings',
                    style: TextStyle(
                        color:
                            available ? Colors.green : Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Action buttons ───────────────────────────
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showEditDialog(context, index),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showStatsDialog(context, l),
                  icon: const Icon(Icons.bar_chart, size: 16),
                  label: const Text('Stats'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () =>
                      _confirmDelete(context, index),
                  icon: Icon(Icons.delete_outline,
                      size: 16, color: Colors.red[400]),
                  label: Text('Delete',
                      style: TextStyle(color: Colors.red[400])),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────

  void _showAddDialog(BuildContext ctx) {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String category = 'Nature';

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add New Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Price (RWF)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                      labelText: 'Category'),
                  items: [
                    'Nature', 'Culture', 'Food & Drink',
                    'Adventure',
                  ]
                      .map((c) => DropdownMenuItem(
                          value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setS(() => category = v ?? category),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  final price = int.tryParse(
                          priceCtrl.text.replaceAll(',', '')) ??
                      10000;
                  setState(() {
                    _listings.add({
                      'id': 'lst${_listings.length + 1}',
                      'title': titleCtrl.text.trim(),
                      'category': category,
                      'price':
                          price.toString().replaceAllMapped(
                                RegExp(
                                    r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (m) => '${m[1]},',
                              ),
                      'priceNum': price,
                      'rating': 0.0,
                      'reviews': 0,
                      'isAvailable': true,
                      'color': 0xFF2E7D32,
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Experience added!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext ctx, int index) {
    final l = _listings[index];
    final titleCtrl =
        TextEditingController(text: l['title'] as String);
    final priceCtrl =
        TextEditingController(text: (l['priceNum'] as int).toString());

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Edit Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration:
                  const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Price (RWF)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final price =
                  int.tryParse(priceCtrl.text) ?? l['priceNum'];
              setState(() {
                _listings[index]['title'] = titleCtrl.text.trim();
                _listings[index]['priceNum'] = price;
                _listings[index]['price'] = price
                    .toString()
                    .replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (m) => '${m[1]},',
                    );
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(
      BuildContext ctx, Map<String, dynamic> l) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(l['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow(Icons.star, Colors.amber, 'Rating',
                '${l['rating']} / 5.0'),
            _statRow(Icons.rate_review, Colors.blue, 'Reviews',
                '${l['reviews']}'),
            _statRow(Icons.people, Colors.green, 'Bookings',
                '${l['reviews']}'),
            _statRow(
                Icons.attach_money,
                Colors.orange,
                'Est. Monthly Revenue',
                'RWF ${_fmt(((l['priceNum'] as int) * 0.92 * 8).toDouble())}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'))
        ],
      ),
    );
  }

  Widget _statRow(
      IconData icon, Color color, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 20),
      title: Text(label),
      trailing: Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _confirmDelete(BuildContext ctx, int index) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text(
            'Remove "${_listings[index]['title']}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _listings.removeAt(index));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listing deleted.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
                foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) {
      final k = v / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}K';
    }
    return v.toStringAsFixed(0);
  }
}

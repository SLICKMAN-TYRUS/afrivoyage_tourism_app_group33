import 'package:flutter/material.dart';

class ProviderListings extends StatelessWidget {
  const ProviderListings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add new experience
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildListingCard(
            title: 'Gorilla Trekking Experience',
            price: '95,000',
            rating: 4.9,
            reviews: 127,
            isAvailable: true,
          ),
          _buildListingCard(
            title: 'Traditional Intore Dance',
            price: '15,000',
            rating: 4.8,
            reviews: 89,
            isAvailable: true,
          ),
          _buildListingCard(
            title: 'Coffee Farm Tour',
            price: '20,000',
            rating: 4.7,
            reviews: 56,
            isAvailable: false,
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard({
    required String title,
    required String price,
    required double rating,
    required int reviews,
    required bool isAvailable,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, size: 40),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' $rating ($reviews reviews)'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'RWF $price per person',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: Switch(
              value: isAvailable,
              onChanged: (value) {},
              activeThumbColor: Colors.green,
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.analytics),
                  label: const Text('Stats'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
